/*
 * @Description: 关键帧小工具,移动帧得筛选Biped,先暂时搁置...
 * @Author: Bullet.S
 * @Date: 2019-09-28 11:48:53
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-10-27 22:43:17
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
-- 优化todo:只判断link子动画,不遍历所有,加快多骨骼的收集帧效率
-- 增加神器按钮,打开小数帧,拖帧更平滑

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
Global keyMovedOffset = 5

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

rollout rolloutBulletKeyTools "关键小帧工具 v0.6" width:200 height:260
(
	group ""
	(
		label lblRangeTimeText "| 起始帧 |       | 结尾帧 |" pos:[10,18] width:180
		edittext edtStartTime "" pos:[10,38] width:50 usePercentageWidth:true percentageWidth:44.0 \
		labelOnTop:true text:(animationrange.start as string) bold:true readOnly:false
		label lblTo "▃"  pos:[65,35]
		edittext edtEndTime "" pos:[80,38] width:50 usePercentageWidth:true percentageWidth:44.0 \
		labelOnTop:true text:(animationrange.end as string) bold:true readOnly:false
		button btnFnFrameTicks "✧(≖ ◡ ≖" pos:[135,20] width:55 height:35 border:false \
		tooltip:"点我点我点我~小数帧切换,\r\n方便滑条拖帧预览动画更平滑~"
		button btnClearSelKeys "清除帧选择" pos:[10,60] tooltip:"清除关键帧选择 (非删除帧)" \
		height:20 width:70
		button btnDelKeys " X" width:25 height:20 \
		pos:[80,60] toolTip:"删除所选帧"
		button btnToKeysRange "首尾帧范围" pos:[10,80] tooltip:"帧范围变成首尾帧 !\r\n小心无限帧~ 后果未知..." \
		height:20 width:70
		button btnDelOutKeys "△"  width:25 height:20 \
		pos:[80,80] toolTip:"清范围外帧"
		button btnBoneTraj "切显Bone轨迹"  width:85 height:20 \
		pos:[105,60] toolTip:"切换显示Bone轨迹,\r\n右键清除所有Bone轨迹"
		checkbutton ckbBipedTraj "单独Biped轨迹"  width:85 height:20 \
		pos:[105,80] toolTip:"给单个Biped添加轨迹,\r\n右键显示所有Biped轨迹"
	)
	group ""
	(
		edittext edtMoveKey  "  移动帧数" pos:[10,122] width:60 usePercentageWidth:true percentageWidth:44.0 \ 
		labelOnTop:true text:"5f" bold:true readOnly:false 
		button btnSet5 "5f"  pos:[85,135] width:35
		button btnSetAdd "+5f"  pos:[120,135] width:35
		button btnSetOpposite "负"  pos:[155,135] width:30
-- 		checkbox <name> [<caption>] [checked:<boolean>]
		checkBox btnJudgeLinkKey "Link?" \
		pos:[15,168] tooltip:"是否存在Link帧?" checked:false 
		button btnSelBeforeKeys " " \
		pos:[65,160] width:30 height:30 toolTip:"选择滑条前面关键帧" border:false
		button btnSelAllKeys " " \
		pos:[95,160] width:30 height:30 toolTip:"选择所有关键帧" border:false
		button btnSelAfterKeys " " \
		pos:[125,160] width:30 height:30 toolTip:"选择滑条后面关键帧" border:false
		button btnMoveKeys " " width:30 height:30 \
		pos:[155,160] toolTip:"移动关键帧" border:false
	)
	group ""
	(
		label labTips " --- 未选即处理全部, 注意无限帧! ---" \
		pos:[5,210]  height:40 width:190
		HyperLink lnkLink "------ [ Author: Bullet.S  2019.09 ] -----" pos:[7,230]
		color:(color 255 20 100) hovercolor:(color 255 0 255) visitedcolor:(color 255 20 100) \
		address:"https://space.bilibili.com/2031113"
	)
	fn fnAddKyes tempObj fnLink =
	(	
		local numObjSubs
		local numLinkSubs
		local tempSubAnim
		local tempController
		local tempLinkObj
		local tempLinkSubAnim
		local tempLinkController
		local keyTimeStartTemp
		local keyTimeEndTemp
		
		if fnLink == 1 then
		(
			if (classof tempObj != Biped_Object) then
			(
				if tempObj.controller != undefined then
				(
					if (classof tempObj.controller) == Link_Constraint then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							if ((GetSubAnimName tempObj.controller i) == #Link_Times) then
							(
								if tempObj.controller[i].keys[1] != undefined then
								(
									for i in tempObj.controller[i].keys do 
									(
										appendIfUnique arrLinkKeys i
									)
								)
							)
							if ((GetSubAnimName tempObj.controller i) == #Link_Params) then
							(
								tempLinkController = tempObj.controller[i]
								if tempLinkController[1] != undefined then
								(
									for i = 1 to tempLinkController.numsubs do 
									(
										if (((tempLinkController[i]).name == "Position") or \
										((tempLinkController[i]).name == "Rotation") or \
										((tempLinkController[i]).name == "Scale")) then
										(
											if tempLinkController[i].keys[1] != undefined then
											(
												keyTimeStartTemp = tempLinkController[i].keys[1].time
												keyTimeEndTemp = tempLinkController[i].keys[tempLinkController[i].keys.count].time
												appendIfUnique arrKeysTime keyTimeStartTemp
												appendIfUnique arrKeysTime keyTimeEndTemp
											)
										)
									)
								)
							)
						)
					)
					if (classof tempObj.controller) == prs then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							if (((tempObj.controller[i]).name == "Position") or \
							((tempObj.controller[i]).name == "Rotation") or \
							((tempObj.controller[i]).name == "Scale")) then
							(
								if tempObj.controller[i].keys[1] != undefined then
								(
									keyTimeStartTemp = tempObj.controller[i].keys[1].time
									keyTimeEndTemp = tempObj.controller[i].keys[tempObj.controller[i].keys.count].time
									appendIfUnique arrKeysTime keyTimeStartTemp
									appendIfUnique arrKeysTime keyTimeEndTemp
								)
							)
						)
					)
				)
			)
		)
		if fnLink == 0 then
		(
			if (classof tempObj != Biped_Object) then
			(
				if (classof tempObj.controller) == prs then
				(
					for i = 1 to tempObj.controller.numsubs do 
					(
						if (((tempObj.controller[i]).name == "Position") or \
						((tempObj.controller[i]).name == "Rotation") or \
						((tempObj.controller[i]).name == "Scale")) then
						(
							if tempObj.controller[i].keys[1] != undefined then
							(
								keyTimeStartTemp = tempObj.controller[i].keys[1].time
								keyTimeEndTemp = tempObj.controller[i].keys[tempObj.controller[i].keys.count].time
								appendIfUnique arrKeysTime keyTimeStartTemp
								appendIfUnique arrKeysTime keyTimeEndTemp
							)
						)
					)
				)
				if (classof tempObj.controller) == Link_Constraint then
				(
					for i = 1 to tempObj.controller.numsubs do 
					(
						if ((GetSubAnimName tempObj.controller i) == #Link_Params) then
						(
							tempLinkController = tempObj.controller[i]
							if tempLinkController[1] != undefined then
							(
								for i = 1 to tempLinkController.numsubs do 
								(
									if (((tempLinkController[i]).name == "Position") or \
									((tempLinkController[i]).name == "Rotation") or \
									((tempLinkController[i]).name == "Scale")) then
									(
										if tempLinkController[i].keys[1] != undefined then
										(
											keyTimeStartTemp = tempLinkController[i].keys[1].time
											keyTimeEndTemp = tempLinkController[i].keys[tempLinkController[i].keys.count].time
											appendIfUnique arrKeysTime keyTimeStartTemp
											appendIfUnique arrKeysTime keyTimeEndTemp
										)
									)
								)
							)
						)
					)
				)
			)
-- 			else
-- 			(
-- 				
-- 			)
		)----------------上面收集非biped的正常帧和收集link帧, 下面收集biped帧
		-- arrKeysTime = makeUniqueArray arrKeysTime  ---去除重复帧数
		sort arrKeysTime  ----帧数排序
		if ((arrKeysTime.count != 0) and (arrKeysTime.count > 1)) then
		(
			keyFirst = arrKeysTime[1]            ------找到首帧
			keyEnd = arrKeysTime[arrKeysTime.count]   -----------找到尾帧
		)
		else  --防止首尾同帧的保险
		(
			if (arrKeysTime.count == 1) then
			(
				keyFirst = arrKeysTime[1]
				keyEnd = keyFirst + 1
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
				for i in (objects as array) do 
				(
					if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i 0
					else 
					fnAddKyes i 1
				)
			)
			default:
			(
				for i in (selection as array) do 
				(
					if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i 0
					else 
					fnAddKyes i 1
				)
			)
		)
	)
	
	fn fnChangetRangeTime =   ------------关键帧数字随滑条改变
	(
		rolloutBulletKeyTools.edtStartTime.text = animationrange.start as string
		rolloutBulletKeyTools.edtEndTime.text = animationrange.end as string
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
		btnMoveKeys.images = #("ViewportNavigationControls_24i.bmp","ViewportNavigationControls_24i.bmp",46,39,39,39,39,true,true)
-- 		btnMoveAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,13,13,13,13,true,true)
		
		timeDIsTemp = timeDisplayMode
		-- iniPos = (GetDialogPos rolloutBulletKeyTools) 
		fnSaveConfig ()  ---------------脚本位置赋值
		fnSetConfig ()  ----------------保存位置信息到ini文件
		registerTimeCallback fnChangetRangeTime  -------------帧范围改变添加回调
	)
	
	on rolloutBulletKeyTools close do -- 关闭记忆浮动窗口位置
	(
		iniPos = (GetDialogPos rolloutBulletKeyTools)
		fnSetConfig ()
	)
	
	on edtStartTime entered valTime do  --------初始帧定位到输入的帧数
	(		
		local rangeStart = valTime as time
		if ((valTime != ".") and (valTime as time != undefined) and \
		(valTime != "") and (rangeStart < animationrange.end)) then
		(
			animationrange = (interval rangeStart animationrange.end)
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)

	on edtEndTime entered valTime do  --------初始帧定位到输入的帧数
	(		
		local rangEnd = valTime as time
		if ((valTime != ".") and (valTime as time != undefined) and \ 
		(valTime != "") and (rangEnd > animationrange.start)) then
		(
			animationrange = (interval animationrange.start rangEnd)
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)
	
	on btnFnFrameTicks pressed do
	(
		if timeDisplayMode != #frameTicks then 
		(
			timeDisplayMode = #frameTicks
			btnFnFrameTicks.text = "(=`▽`)"
		)
		else 
		(
			timeDisplayMode = #frames
			btnFnFrameTicks.text = "✧(≖ ◡ ≖"
		)
		slidertime -= 1
		slidertime += 1
	)

	on btnBoneTraj pressed do 
	(
		for i in (selection as array) where (classof i != Biped_Object) do
		(
			if i.showtrajectory == true then i.showtrajectory = false
			else i.showtrajectory = true
		)
	)

	on btnBoneTraj rightclick do
	(
		for i in (objects as array) where (classof i != Biped_Object) do
		(
			if i.showtrajectory == true then i.showtrajectory = false
		)
	)

	on edtMoveKey entered val do
	(
		if ((val != ".") and (val as time != undefined) and (val != "")) then
		(
			keyMovedOffset = (val as time)
			rolloutBulletKeyTools.edtMoveKey.text = keyMovedOffset as string
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)

	on btnSet5 pressed do 
	(
		edtMoveKey.text = "5f"
		keyMovedOffset = 5
	)
	on btnSetAdd pressed do 
	(
		edtMoveKey.text = "+5f"
		keyMovedOffset += 5
		edtMoveKey.text = keyMovedOffset as string + "f"
	)
	on btnSetOpposite pressed do
	(
		keyMovedOffset = - keyMovedOffset
		edtMoveKey.text = keyMovedOffset as string + "f"
	)
	on btnMoveKeys pressed do 
	(
		local rangEnd = animationrange.end
		local rangeStart = animationrange.start
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
			if keyMovedOffset > 0 then 
			(
				rangEnd = animationrange.end + keyMovedOffset
				animationrange = interval animationrange.start rangEnd
			)
			else if keyMovedOffset < 0 then 
			(
				rangeStart = animationrange.start + keyMovedOffset
				animationrange = interval rangeStart animationrange.end
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
	
	on btnJudgeLinkKey changed state do 
	(
		if btnJudgeLinkKey.state == false then
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
