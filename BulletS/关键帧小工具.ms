/*
 * @Description: 关键帧小工具,移动帧得筛选Biped,先暂时搁置...
 * @Author: Bullet.S
 * @Date: 2019-09-28 11:48:53
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-10-25 19:20:35
 * @Email: animator.bullet@foxmail.com
 */
-- getKeyTime $.rotation.controller 1
-- selectKeys $ (getKeyTime $.rotation.controller 1) ($.rotation.controller.keys[$.rotation.controller.keys.count].time)
-- slidertime

--$.controller.子动画数量, 若子动画.keys 不为空 则取之加入数组  参考清理无限帧递归

-- $.controller[2].keys[1].selected = true
-- SubAnim:Link_Times 移动帧特殊处理 取link帧 $.controller[2].keys
-- if (getSubanimname $.controller 2) == #Link_Times then  判断为link帧

-- movekeys $.controller 5 #selection  移动帧
-- biped.moveKeys
-- 左键+右键-
-- v0.6 针对link帧大优化,可选是否有link帧,方便操作,增加移动帧功能,有问题随时反馈~


try(destroydialog rolloutBulletKeyTools)catch()

Global mouPosX = mouse.screenpos.x  
Global mouPosY = mouse.screenpos.y  --获取鼠标位置

Global arrKeysTime = #()
Global arrLinkKeys = #()
Global arrBipedKeys = #()
Global keyFirst
Global keyEnd
Global fnAddKyes
Global fnSelectKeys
Global fnSelLinkKeys

Global BulletConfig = ((getDir #scripts) + "\\BulletConfig.ini")  --配置文件路径
Global iniPos  --位置保存记录
Global keyMovedOffset

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr)  --先提取文件中的记录
	if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
)
fn fnSaveConfig =  --引用上面方法提出需要的参数
(----提出脚本位置
	iniPos = fnGetConfig iniPos "BulletKeyToolsSet" "Pos" ([mouPosX,mouPosY] as string)
)
fnSaveConfig () --初始执行一遍
fn fnSetConfig =  --保存参数,脚本位置
(
	SetINISetting BulletConfig "BulletKeyToolsSet"  "Pos" (iniPos as string)
)

rollout rolloutBulletKeyTools "关键小帧工具 v0.6" width:200 height:205
(
	group ""
	(
		edittext edtSliderTime " 当前帧数"  pos:[10,20] width:55 usePercentageWidth:true percentageWidth:44.0 \
		labelOnTop:true text:(sliderTime as string) bold:true readOnly:false
		button btnClearSelKeys "清除帧选择" pos:[80,18] tooltip:"清除关键帧选择 (非删除帧)" \
		height:20 width:90
		button btnDelKeys "X" width:20 height:20 \
		pos:[170,18] toolTip:"删除帧"
		button btnToKeysRange "首尾帧范围" pos:[80,38] tooltip:"帧范围变成选中或全部物体首尾帧\r\n小心无限帧~ 后果未知..." \
		height:20 width:110
	)
	group ""
	(
		edittext edtMoveKey  " 移动帧数" pos:[10,80] width:60 usePercentageWidth:true percentageWidth:44.0 \ 
		labelOnTop:true text:"5f" bold:true readOnly:false 
		button btnSet "5f"  pos:[81,95] width:35
		button btnSet10 "10f"  pos:[118,95] width:35
		button btnSetOpposite "负"  pos:[155,95] width:35
-- 		checkbox <name> [<caption>] [checked:<boolean>]
		checkBox btnJudgeLinkKey "Link?" \
		pos:[15,128] tooltip:"是否存在Link帧?" checked:false 
		button btnSelBeforeKeys " " \
		pos:[65,120] width:30 height:30 toolTip:"选择滑条前面关键帧" border:false
		button btnSelAllKeys " " \
		pos:[95,120] width:30 height:30 toolTip:"选择所有关键帧" border:false
		button btnSelAfterKeys " " \
		pos:[125,120] width:30 height:30 toolTip:"选择滑条后面关键帧" border:false
		button btnMoveKeys " " width:30 height:30 \
		pos:[160,120] toolTip:"移动关键帧" border:false
	)
	label labTips " --- 未选即处理全部, 注意无限帧! ---" \
	pos:[5,162] style_sunkenedge:true height:35 width:190
	HyperLink lnkLink "------ [ Author: Bullet.S  2019.09 ] -----" \
	pos:[7,180] width:230 \ 
	color:(color 255 20 100) hovercolor:(color 255 0 255) visitedcolor:(color 255 20 100) \
	address:"https://space.bilibili.com/2031113"

	fn fnAddKyes tempObj Link:off =
	(	
		local numObjSubs
		local numLinkSubs
		local tempSubAnim
		local tempController
		local tempLinkObj
		local tempLinkSubAnim
		local tempLinkController
		
		if tempObj.controller != undefined then
		(
			numObjSubs = tempObj.numSubs   ---------子动画数量
			for n = 1 to numObjSubs do 
			(
				tempSubAnim = GetSubAnim tempObj n
				if tempSubAnim != undefined then
				(
					tempController = tempSubAnim.Controller
					if (classof tempController != UndefinedClass) then
					(
						if (classof tempObj != Biped_Object) then
						(
							if ((classof tempController != Link_Constraint) and (classof tempController != LinkTimeControl)) then
							(
								if tempController != undefined then 
								(
									if tempController.keys[1] != undefined then
									(
										-- arrKeysTime += for i in tempController.keys collect i.time
										for i in tempController.keys do 
										(
											appendIfUnique arrKeysTime i.time
										)
	-- 									print (n as string + ":" + arrKeysTime as string)
									)
								)
							)
							else
							(
								if Link == on then
								(
									tempLinkObj = tempController
									if tempLinkObj != undefined then
									(
										numLinkSubs = tempLinkObj.numSubs
										for n = 1 to numLinkSubs do
										(
											tempLinkSubAnim = GetSubAnim tempLinkObj n
											for n = 1 to numLinkSubs do
											(
												tempLinkSubAnim = GetSubAnim tempLinkObj n
												if (GetSubAnimName tempLinkObj n) == #Link_Times then
												(
													if tempLinkSubAnim.keys[1] != undefined then
													(
														for i in tempLinkSubAnim.keys do 
														(
															appendIfUnique arrLinkKeys i
														)
													)
												)
											)
											if tempLinkSubAnim.numSubs > 0 do (fnAddKyes tempLinkSubAnim)
										)
									)
								)
								-- else 
								-- (
								-- 	print "Link:off"
								-- )
							)
						)
						else 
						(
							if tempObj.controller != undefined then 
							(
								if tempObj.controller.keys[1] != undefined then
								(
									-- arrKeysTime += for i in tempController.keys collect i.time
									for i in tempObj.controller.keys do 
									(
										append arrKeysTime i.time
									)
-- 									print (n as string + ":" + arrKeysTime as string)
								)
							)
						)
					)----------------上面收集非biped的正常帧和收集link帧, 下面收集biped帧
				)
				if tempSubAnim.numSubs > 0 do (fnAddKyes tempSubAnim)  ----子动画递归
			)
		)
	)

	fn fnCollectKeys = ---------收集关键帧
	(
		arrKeysTime = #()
		arrBipedKeys = #() ----------------先清空数组
		arrLinkKeys = #()
		
		case of  -----------处理选中,未选中则处理全部
		(
			(selection.count == 0):
			(
				for i in objects do 
				(
					if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i
					else fnAddKyes i link:on
				)
			)
			default:(
				for i in selection do 
				(
					if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i
					else fnAddKyes i link:on
				)
			)
		)
		-- arrKeysTime = makeUniqueArray arrKeysTime  ---去除重复帧数
		sort arrKeysTime  ----帧数排序
		if ((arrKeysTime.count != 0) and (arrKeysTime.count > 1)) then
		(
			keyFirst = arrKeysTime[1]            ------找到首帧
			keyEnd = arrKeysTime[arrKeysTime.count]   -----------找到尾帧
		)
		else
		(
			if (arrKeysTime.count == 1) then
			(
				keyFirst = arrKeysTime[1]
				keyEnd = keyFirst + 1
			)
		)
	)
	
	fn fnChangeedtSliderTime =   ------------关键帧数字随滑条改变
	(
		edtSliderTime.text = slidertime as string
	)

	fn fnSelLinkKeys keyBegin KeyEnd symbol =  ---------------选择link帧方法
	(
		if arrLinkKeys.count != 0 then
		(
			for i in arrLinkKeys do   -------link帧选中
			(
				i.selected = false ---先取消之前link帧选中状态
				case of  -------------判断link帧位置,数字是随便取的方便判断情况
				(
					(symbol == 0):(if i.time <= KeyEnd then i.selected = true)
					(symbol == 1):(if i.time >= keyBegin then i.selected = true)
					(symbol == 2):(i.selected = true)
				)
			)
		)
	)

	fn fnSelKeys keyBegin KeyEnd symbol=  ---------------选择帧的方法
	(
		fn fnSelectKeys keyBegin KeyEnd symbol =  -------因为有选中和没选择状态, 所以加一个方法精简下
		(
			deselectKeys $           --清除之前选中的关键帧
			if arrKeysTime.count != 0 then
			(
				selectkeys $ keyBegin KeyEnd  -------------选中正常帧
				fnSelLinkKeys keyBegin KeyEnd symbol --------------选中link帧
			)
			else
			(
				fnSelLinkKeys keyBegin KeyEnd symbol
			)
		)
		case of 
		(
			(selection.count == 0):  ----------判断是否有选中物体
			(
				select objects    ---没有选择物体则选择所有物体
				fnSelectKeys keyBegin KeyEnd symbol
			)
			default:  ----------------
			(
				fnSelectKeys keyBegin KeyEnd symbol
			)
		)
	)
	
	mapped fn moveKeysAndLinkKeys obj offset =  ----https://forums.cgsociety.org/t/moving-keys-from-link-constraint-keys-access/1575053
	(
		moveKeys obj offset
		if rolloutBulletKeyTools.btnJudgeLinkKey.checked == true then 
		(
			if classof obj.controller == Link_Constraint do
			(
				nTargets = obj.controller.getNumTargets()
	
				if nTargets > 0 do
				(
					--SORT THE LINK CONSTRAINT TARGETS
					obj.controller.setFrameNo 1 (obj.controller.getFrameNo 1)
								
					if offset > 0 then
					(
						for i = nTargets to 1 by -1 do
						(
							fNumber = obj.controller.getFrameNo i
							obj.controller.setFrameNo i (fNumber + offset)
						)
					)
					else
					(
						for i = 1 to nTargets do
						(
							fNumber = obj.controller.getFrameNo i
							obj.controller.setFrameNo i (fNumber + offset)					
						)
					)
				)
			)
		)
	)

	on rolloutBulletKeyTools open do  ----打开脚本时操作
	(
		btnSelBeforeKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,3,3,3,3,true,true) 
		btnSelAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,11,11,11,11,true,true) 
		btnSelAllKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,26,26,26,26,true,true)
		btnMoveKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,21,21,21,21,true,true)
-- 		btnMoveAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,13,13,13,13,true,true)
		

		-- iniPos = (GetDialogPos rolloutBulletKeyTools) 
		fnSaveConfig ()  ---------------脚本位置赋值
		fnSetConfig ()  ----------------保存位置信息到ini文件
		fnChangeedtSliderTime ()
		registerTimeCallback fnChangeedtSliderTime  -------------帧数随滑条改变添加回调
	)
	
	on rolloutBulletKeyTools close do -- 关闭记忆浮动窗口位置
	(
		iniPos = (GetDialogPos rolloutBulletKeyTools)
		fnSetConfig ()
	)
	
	on edtSliderTime entered valTime do  --------滑条定位到输入的帧数
	(
		if ((valTime != ".") and (valTime as time != undefined) and (valTime != "")) then
		(
			case of  ----------判断输入帧数是否在帧栏范围外
			(
				(valTime as time > animationrange.end):
				(
					animationrange = (interval animationrange.start (valTime as time))
					slidertime = valTime as time
				)
				(valTime as time < animationrange.start):
				(
					animationrange = (interval (valTime as time) animationrange.end)
					slidertime = valTime as time
				)
				default:(slidertime = valTime as time)
			)
		)
		else messageBox "---------------\r\n请输入帧数"
	)

	on edtMoveKey entered val do
	(
		if ((val != ".") and (val as time != undefined) and (val != "")) then
		(
			keyMovedOffset = (val as time)
			rolloutBulletKeyTools.edtMoveKey.text = keyMovedOffset as string
		)
		else messageBox "---------------\r\n请输入帧数"
	)

	on btnSet pressed do 
	(
		edtMoveKey.text = "5f"
		keyMovedOffset = 5
	)
	on btnSet10 pressed do 
	(
		edtMoveKey.text = "10f"
		keyMovedOffset = 10
	)
	on btnSetOpposite pressed do
	(
		keyMovedOffset = - keyMovedOffset
		edtMoveKey.text = keyMovedOffset as string + "f"
	)
	on btnMoveKeys pressed do 
	(
		if keyMovedOffset != undefined then
		(
			if selection.count != 0 then
			(
				for i in selection do 
				(
					moveKeysAndLinkKeys i keyMovedOffset
				)
			)
			else 
			(
				for i in objects do 
				(
					moveKeysAndLinkKeys i keyMovedOffset
				)
			)
		)
	)
	on btnSelBeforeKeys pressed do  ------------选择滑条之前帧
	(
		fnCollectKeys ()
		if arrLinkKeys.count != 0 then
		(
			for i in arrLinkKeys do i.selected = false
		)
		if arrKeysTime.count != 0 then
		(
			if keyFirst <= sliderTime then 
			(
				fnSelKeys keyFirst sliderTime 0
			)
			else 
			(
				fnSelKeys sliderTime sliderTime 0
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				if arrLinkKeys[1].time <= sliderTime then 
				(
					fnSelLinkKeys arrLinkKeys[1].time sliderTime 0
				)
				else 
				(
					fnSelLinkKeys sliderTime sliderTime 0
				)
			)
		)
	)
	
	on btnSelAfterKeys pressed do  -------------选择滑条之后帧
	(
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
			if keyEnd >= sliderTime then 
			(
				fnSelKeys sliderTime keyEnd 1
			)
			else 
			(
				fnSelKeys sliderTime sliderTime 1
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				if arrLinkKeys[1].time >= sliderTime then 
				(
					fnSelLinkKeys sliderTime arrLinkKeys[1].time 1
				)
				else 
				(
					fnSelLinkKeys sliderTime sliderTime 1
				)
			)
		)
	)
	
	on btnSelAllKeys pressed do     ------------------选择所有帧
	(
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			fnSelKeys keyFirst keyEnd 2
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				fnSelLinkKeys arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time 2
			)
		)
	)

	on btnClearSelKeys pressed do  ---------------------清除帧选择
	(
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			for i in objects do deselectKeys i
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
		)
	)

	on btnToKeysRange pressed do   ---------------帧栏显示首尾帧范围
	(
		fnCollectKeys ()
		if (arrKeysTime.count != 0) then
		(
			if (arrLinkKeys.count != 0) then
			(
				case of
				(
					((arrLinkKeys[1].time >= keyFirst) and (arrLinkKeys[arrLinkKeys.count].time <= keyEnd)):
					(animationrange = (interval keyFirst keyEnd))
					((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time <= keyEnd)):
					(animationrange = (interval arrLinkKeys[1].time keyEnd))
					((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time >= keyEnd)):
					(animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time))
					((arrLinkKeys[1].time >= keyFirst) and (arrLinkKeys[arrLinkKeys.count].time > keyEnd)):
					(animationrange = (interval keyFirst arrLinkKeys[arrLinkKeys.count].time))
					((arrLinkKeys[1].time < keyFirst) and (arrLinkKeys[arrLinkKeys.count].time > keyEnd)):
					(animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time))
				)
			)
			else
			(
				animationrange = interval keyFirst keyEnd
			)
		)
		else 
		(
			if ((arrLinkKeys.count != 0) and (arrLinkKeys.count > 1)) then 
			(
				animationrange = (interval arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time)
			)
			else 
			(
				if (arrLinkKeys.count == 1) then
				(
					animationrange = (interval arrLinkKeys[1].time (arrLinkKeys[1].time + 1))
				)
			)
		)
	)
)
Createdialog rolloutBulletKeyTools fgcolor:(color 255 20 100) pos:iniPos
clearListener()  ---------清除侦听器

-- mapped fn moveKeysAndLinkConstraint obj offset =
-- (
-- 	moveKeys obj offset
-- 	
-- 	if classof obj.controller == Link_Constraint do
-- 	(
-- 		nTargets = obj.controller.getNumTargets()

-- 		if nTargets > 0 do
-- 		(
-- 			--SORT THE LINK CONSTRAINT TARGETS
-- 			obj.controller.setFrameNo 1 (obj.controller.getFrameNo 1)
-- 						
-- 			if offset > 0 then
-- 			(
-- 				for i = nTargets to 1 by -1 do
-- 				(
-- 					fNumber = obj.controller.getFrameNo i
-- 					obj.controller.setFrameNo i (fNumber + offset)
-- 				)
-- 			)
-- 			else
-- 			(
-- 				for i = 1 to nTargets do
-- 				(
-- 					fNumber = obj.controller.getFrameNo i
-- 					obj.controller.setFrameNo i (fNumber + offset)					
-- 				)
-- 			)
-- 		)
-- 	)
-- )

-- moveKeysAndLinkConstraint selection 5



-- 	fn fn_MoveKeys inputObject offsetFrame =
-- 	(
-- 		deselectKeys inputObject
-- 		selectKeys inputObject
-- 		movekeys inputObject offsetFrame  #selection
-- 	)--移动帧

-- 	fn fn_MoveBipedKeys inputObject offsetFrame =
-- 	(
-- 		biped.deselectKeys inputObject
-- 		biped.selectKeys inputObject
-- 		biped.moveKeys inputObject offsetFrame
-- 	)--移动Biped帧
