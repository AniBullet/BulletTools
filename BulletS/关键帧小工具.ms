/*
 * @Description: 关键帧小工具,逐渐丰富中
 * @Author: Bullet.S
 * @Date: 2019-09-28 11:48:53
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-11-03 02:52:50
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

Global posMouX = mouse.screenpos.x  
Global posMouY = mouse.screenpos.y  --获取鼠标位置
Global posMouMoved = [0,0]
Global fnMouseState = false

Global arrKeysTime = #()  ----------biped和bone的首尾帧
Global arrLinkKeys = #()  -----------存link帧
-- Global arrBipedKeys = #()
Global keyFirst
Global keyEnd
Global fnAddKyes
Global fnSelectKeys
Global fnSelLinkKeys
Global fnAddLinkTimesKeys
Global fnAddLinkParamsKeys
Global BulletConfig = ((getDir #scripts) + "\\BulletConfig.ini")  --配置文件路径
Global iniPos  --位置保存记录
Global keyMovedOffset = 5
Global symbol ----选择的范围判断, 0左边,1右边,2全部
Global layerTraj --轨迹辅助层
Global arrTraj = #()  ---轨迹存放数组,方便删除

------------------全局变量-------------------------------------------------------------------

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr)  --先提取文件中的记录
	if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
)
fn fnSaveConfig =  --引用上面方法提出需要的参数
(----提出脚本位置
	iniPos = fnGetConfig iniPos "BulletKeyToolsSet" "Pos" ([posMouX,posMouY] as string)
)
fnSaveConfig () --初始执行一遍
fn fnSetConfig =  --保存参数,脚本位置
(
	SetINISetting BulletConfig "BulletKeyToolsSet"  "Pos" (iniPos as string)
)
---------------配合BulletTools工具的ini文件保存位置信息-----------------
rollout rolloutBulletKeyTools "" width:200 height:210
(
	---------------------------------UI--------------------------------------
	groupbox gbxMainUI "[ K 帧工具_v0.7 ] ------ 中键关闭" pos:[5,5] width:190 height:130
	
		label lblRangeTimeText "| 起始帧 |       | 结尾帧 |" pos:[10,25] width:180
		spinner spiStartTime "" pos:[10,43] width:50 type:#integer \
		range:[-999999999,999999999,animationrange.start] scale:1
-- 		setKeyBrackets:true
		label lblTo "▃"  pos:[65,36]
		spinner spiEndTime "" pos:[80,43] width:50 type:#integer \
		range:[-999999999,999999999,animationrange.end] scale:1
-- 		setKeyBrackets:true
		button btnFnFrameTicks "✧(≖ ◡ ≖" pos:[135,30] width:55 height:30 border:false \
		tooltip:"点我点我点我~\r\n发现新世界!!!~\r\n右键切换小数帧\r\n平滑拖帧看卡顿!"
		edittext edtMoveKey "移动" width:70 usePercentageWidth:true percentageWidth:44.0 \ 
		pos:[10,72] labelOnTop:false text:"5f" bold:true readOnly:false 
		button btnSet5 "5f" width:35 pos:[90,70]
		button btnSetAdd "+5f" width:35 pos:[125,70]
		button btnSetOpposite "负" width:30 pos:[160,70]
-- 		checkbox <name> [<caption>] [checked:<boolean>]
		checkBox btnJudgeLinkKey "Link?" \
		pos:[15,102] tooltip:"是否存在Link帧?" checked:false 
		button btnSelBeforeKeys " " \
		pos:[70,95] width:30 height:30 toolTip:"选择滑条前面关键帧" border:false
		button btnSelAllKeys " " \
		pos:[100,95] width:30 height:30 toolTip:"选择所有关键帧" border:false
		button btnSelAfterKeys " " \
		pos:[130,95] width:30 height:30 toolTip:"选择滑条后面关键帧" border:false
		button btnMoveKeys " " width:30 height:30 \
		pos:[160,95] toolTip:"移动关键帧,\r\n左键带帧栏范围增减,\r\n右键范围不变~" border:false
	
	groupbox gbxMinTools "小工具" pos:[200,5] width:145 height:200
	
		button btnClearSelKeys "▲清帧" tooltip:"清除关键帧选择 (非删除帧)" \
		pos:[205,25] height:20 width:50
		button btnToKeysRange "☀卡帧" tooltip:"帧范围变成首尾帧 !\r\n小心无限帧~ 后果未知..." \
		pos:[205,45] height:20 width:50
		button btnDelOutKeys " ✖删帧" height:20 width:50 \
		pos:[205,65] toolTip:"左键清除选择帧\r\n右键清范围外帧(无限帧)"
		button btnFreezeMesh " ✲ 冻模" height:20 width:50 \
		pos:[205,85] toolTip:"冻结模型"
		button btnBoneTraj "◆ Bone轨迹"  width:80 height:20 \
		pos:[260,25] toolTip:"切换显示Bone轨迹,\r\n右键清除所有Bone轨迹"
		button btnBipedTraj "★ Biped轨迹"  width:80 height:20 \
		pos:[260,45] toolTip:"左键切换显示单个Biped轨迹,\r\n右键切换显示所有Biped轨迹~"
		button btnSelBoneBiped "☑ 选骨" height:20 width:50 \
		pos:[205,125] toolTip:"左键选择所有biped\r\n右键选择所有bone"
		button btnHideBones "☁ 藏骨" height:20 width:50 \
		pos:[205,105] toolTip:"隐藏骨骼"
	
	groupbox gbxTips "" pos:[5,135] width:190 height:70
	
		HyperLink lnkLink "---  | 2019.9  miHoYo_Bullet.S |  - ？ --"
		color:(color 255 20 100) hovercolor:(color 255 0 255) visitedcolor:(color 255 20 100) \
		pos:[7,145] address:"https://space.bilibili.com/2031113"
		label labmiHoYo "--- TECH OTAKUS SAVE THE WORLD --" \
		pos:[7,165]
		label labTips "---- 未选即处理全部, 注意无限帧! --" \
		pos:[7,185]
----------------------------------UI及作者ID------------------------------------------------
	Fn CleanOutRangeKeys inputObject =  ---清理无限帧,以前收集的,找不到来源了,大概是遍历子动画
	(
		startTime = AnimationRange.Start
		endTime = AnimationRange.End
		for i = 1 to inputObject.numSubs do
		(
			tempSubAnim = GetSubAnim inputObject i
			tempController = tempSubAnim.Controller
			
			if tempController != undefined do
			(
				tempKeyList = tempController.Keys
				
				outEndKeysIndex = for i = 1 to tempKeyList.Count where tempKeyList[i].Time > endTime collect i
				if outEndKeysIndex.Count > 0 do for i = 1 to outEndKeysIndex.Count do DeleteKey tempKeyList tempKeyList.count
				
				outStartKeysIndex = for i = 1 to tempKeyList.Count where  tempKeyList[i].Time < startTime collect i
				for i = 1 to outStartKeysIndex.Count do DeleteKey tempKeyList 1
			)
			if tempSubAnim.numSubs > 0 do CleanOutRangeKeys tempSubAnim
		)
	)

	-- fn fnAddLinkKeys tempObj =
	-- (
		fn fnAddLinkTimesKeys tempObj i=     --添加linkTimes关键帧
		(
			-- for i = 1 to tempObj.controller.numsubs do 
			-- (
				if ((GetSubAnimName tempObj.controller i) == #Link_Times) then
				(
					if tempObj.controller[i].keys[1] != undefined then
					(
						for i in tempObj.controller[i].keys do 
						(
							appendIfUnique arrLinkKeys i  ---------添加link帧到数组
						)
					)
				)
			-- )
		)
		fn fnAddLinkParamsKeys tempObj i=   ----添加LinkParams下面的Transform帧
		(
			local tempLinkController
			local keyTimeStartTemp
			local keyTimeEndTemp
			
			-- for i = 1 to tempObj.controller.numsubs do 
			-- (
				if ((GetSubAnimName tempObj.controller i) == #Link_Params) then
				(
					tempLinkController = tempObj.controller[i]
					if tempLinkController[1] != undefined then
					(
						for i = 1 to tempLinkController.numsubs do -----link属性的bone下面的prs帧------
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
			-- )
		)
		-- fnAddLinkTimesKeys tempObj
		-- fnAddLinkParamsKeys tempObj
	-- )

	fn fnAddPrsKeys tempObj i=  ---------添加正常非biped的prs帧(没加link),i是子动画ID,后面用到,提前传入减少遍历
	(
		local keyTimeStartTemp
		local keyTimeEndTemp
		
		-- for i = 1 to tempObj.controller.numsubs do 
		-- (
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
		-- )
	)

	fn fnAddBipedKeys tempObj =------收集Biped帧
	(
		local keyTimeStartTemp
		local keyTimeEndTemp
		local subanimBipedScale

		if tempObj.controller.keys[1] != undefined then --筛选出非质心的biped帧
		(
			for i in tempObj.controller.keys do 
			(
				appendIfUnique arrKeysTime i.time   ---添加到数组
			)
			subanimBipedScale = GetSubAnim tempObj.controller[1] 1
			if ((subanimBipedScale != undefined) and \
			(GetSubAnimName subanimBipedScale 1 == #ScaleXYZ)) then  ----筛选出biped的缩放帧
			(
				if subanimBipedScale[1].keys[1] != undefined then
				(
					keyTimeStartTemp = subanimBipedScale[1].keys[1].time
					keyTimeEndTemp = subanimBipedScale[1].keys[subanimBipedScale[1].keys.count].time
					appendIfUnique arrKeysTime keyTimeStartTemp
					appendIfUnique arrKeysTime keyTimeEndTemp
				)
			)
		)
		else
		(-------------------下面是收集质心的关键帧,坑在于中英文turning名字还不一样...
			if classof tempObj.controller == Vertical_Horizontal_Turn then
			(
				bipCtrl = tempObj.controller
				vertCtrl = bipCtrl.vertical.controller
				horzCtrl = bipCtrl.horizontal.controller
				if (sysinfo.GetMaxLanguage())[3]=="CHS" then 
					(turnCtrl = bipCtrl.flip.controller)
					else(turnCtrl = bipCtrl.turning.controller)
				bipCtrlTemp = #(vertCtrl,horzCtrl,turnCtrl)
				for c in bipCtrlTemp do
				(
					if c.keys[1] != undefined then
					(
						keyTimeStartTemp = c.keys[1].time
						keyTimeEndTemp = c.keys[c.keys.count].time
						appendIfUnique arrKeysTime keyTimeStartTemp
						appendIfUnique arrKeysTime keyTimeEndTemp
					)
				)
			)
		)

	)

	fn fnAddKyes tempObj fnLink =   ---添加帧(主要是首尾帧),加个判断是否勾选link
	(	
		if fnLink == 1 then ------1代表勾选了link
		(
			if (classof tempObj != Biped_Object) then
			(
				if tempObj.controller != undefined then
				(
					if (classof tempObj.controller) == prs then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							fnAddPrsKeys tempObj i        ---非biped物体的位移旋转缩放帧
						)
					)
					if (classof tempObj.controller) == Link_Constraint then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							fnAddLinkTimesKeys tempObj i         ---------link属性的物体link帧和非link帧
							fnAddLinkParamsKeys tempObj i
						)
					)
				)
			)
			else
			(
				fnAddBipedKeys tempObj   ---------biped帧
			)
		)
		if fnLink == 0 then  --------跟上面一样,区别在于没有(link属性物体的link帧)
		(
			if (classof tempObj != Biped_Object) then
			(
				if tempObj.controller != undefined then
				(
					if (classof tempObj.controller) == prs then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							fnAddPrsKeys tempObj i
						)
					)
					if (classof tempObj.controller) == Link_Constraint then
					(
						for i = 1 to tempObj.controller.numsubs do 
						(
							fnAddLinkParamsKeys tempObj i
						)
					)
				)
			)
			else
			(
				fnAddBipedKeys tempObj
			)
		)----------------收集各种帧
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
		-- arrBipedKeys = #() ----------------先清空数组
		arrLinkKeys = #()
		case of  -----------处理选中,未选中则处理全部
		(
			(selection.count == 0):
			(
				for i in (objects as array) where (i.ishidden == false) do 
				(
					if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i 0
					else 
					fnAddKyes i 1  -----------根据是否勾选link处理收集帧
				)
			)
			default:
			(
				for i in (selection as array) where (i.ishidden == false) do 
				(
					if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i 0
					else 
					fnAddKyes i 1  -----------根据是否勾选link处理收集帧
				)
			)
		)
	)
	
	fn fnChangetRangeTime =   ------------关键帧数字随滑条改变
	(
		rolloutBulletKeyTools.spiStartTime.value = animationrange.start
		rolloutBulletKeyTools.spiEndTime.value = animationrange.end
	)

	fn fnSelLinkKeys keyFirst KeyEnd symbol =  ---------------选择link帧方法
	(
		if arrLinkKeys.count != 0 then
		(
			for i in arrLinkKeys do   -------link帧选中
			(
				i.selected = false ---先取消之前link帧选中状态
				case of  -------------判断link帧位置,数字是随便取的方便判断情况
				(
					(symbol == 0):(if i.time <= KeyEnd then i.selected = true)
					(symbol == 1):(if i.time >= keyFirst then i.selected = true)
					(symbol == 2):(i.selected = true)
				)
			)
		)
	)

	fn fnSelKeys keyFirst KeyEnd symbol =  ---------------选择帧的方法
	(
		fn fnSelectKeys keyFirst KeyEnd symbol =  -------因为有选中和没选择状态, 所以加一个方法精简下
		(
			for i in objects where (i.ishidden == false) do deselectKeys i          --清除之前选中的关键帧
			if arrKeysTime.count != 0 then
			(
				selectkeys $ keyFirst KeyEnd  -------------选中正常帧
				if rolloutBulletKeyTools.btnJudgeLinkKey.checked == true then
				(
					fnSelLinkKeys keyFirst KeyEnd symbol --------------选中link帧
				)
			)
			else
			(
				if rolloutBulletKeyTools.btnJudgeLinkKey.checked == true then
				(
					fnSelLinkKeys keyFirst KeyEnd symbol
				)
			)
		)
		case of 
		(
			(selection.count == 0):  ----------判断是否有选中物体
			(
				actionMan.executeAction 0 "40021"    ---没有选择物体则选择所有物体
				fnSelectKeys keyFirst KeyEnd symbol
			)
			default:  ----------------
			(
				fnSelectKeys keyFirst KeyEnd symbol
			)
		)
	)
	
	mapped fn fnMoveKeysAndLinkKeys obj offset symbol =  ----https://forums.cgsociety.org/t/moving-keys-from-link-constraint-keys-access/1575053
	(
		moveKeys obj offset #selection  ---先移动非link帧
		if rolloutBulletKeyTools.btnJudgeLinkKey.checked == true then 
		(
			if classof obj.controller == Link_Constraint do
			(
				nTargets = obj.controller.getNumTargets()  ---得到link的帧数量
	
				if nTargets > 0 do
				(
					--SORT THE LINK CONSTRAINT TARGETS
					obj.controller.setFrameNo 1 (obj.controller.getFrameNo 1)
								
					if offset > 0 then  --------判断向前还是向后移动帧
					(
						for i = nTargets to 1 by -1 do  ------如果大于0则从第一个link帧开始移
						(
							fNumber = obj.controller.getFrameNo i
							case of  -------------判断link帧位置,数字是随便取的方便判断情况
							(
								(symbol == 0):(if fNumber <= sliderTime then (obj.controller.setFrameNo i (fNumber + offset)))
								(symbol == 1):(if fNumber >= sliderTime then (obj.controller.setFrameNo i (fNumber + offset)))
								(symbol == 2):((obj.controller.setFrameNo i (fNumber + offset)))
							)
						)
					)
					else
					(
						for i = 1 to nTargets do  ---如果移动帧小于0,从最后link帧开始移
						(
							fNumber = obj.controller.getFrameNo i
							case of  -------------判断link帧位置,数字是随便取的方便判断情况
							(
								(symbol == 0):(if fNumber <= sliderTime then (obj.controller.setFrameNo i (fNumber + offset)))
								(symbol == 1):(if fNumber >= sliderTime then (obj.controller.setFrameNo i (fNumber + offset)))
								(symbol == 2):((obj.controller.setFrameNo i (fNumber + offset)))
							)			
						)
					)
				)
			)
		)
	)

	-- fn fnSplitSelBiped = --分开选择四肢和身体,例如同一条手臂只选择最父级的(方便移动帧)
	-- (
	-- 	arrSelBiped = for i in selection where classof i.controller == BipSlave_Control collect i 

	-- )

	fn fnMoveBipedKeys offsetFrame =  -------移动Biped帧
	(
		bipedRoot = #()   -------判断选择了几个biped骨架
		for i in selection where ((classof i == Biped_Object) and (i.ishidden == false)) do  
		(
			appendIfUnique bipedRoot i.controller.rootNode  --添加到骨架数组
		)
		for c in bipedRoot do  ---按每个骨架处理
		(
			ctrlBiped = c.controller
			bipedAll = #(biped.getNode ctrlBiped #pelvis, -----四肢同帧处理,只处理他首节biped
						biped.getNode ctrlBiped #spine,
						biped.getNode ctrlBiped #neck,
						biped.getNode ctrlBiped #larm,
						biped.getNode ctrlBiped #rarm,
						biped.getNode ctrlBiped #lleg,
						biped.getNode ctrlBiped #rleg,
						biped.getNode ctrlBiped #prop1,
						biped.getNode ctrlBiped #prop2,
						biped.getNode ctrlBiped #prop3,
						biped.getNode ctrlBiped #tail)

			vertCtrl = ctrlBiped.vertical.controller  -----质心ctrl关键帧
			horzCtrl = ctrlBiped.horizontal.controller
			if (sysinfo.GetMaxLanguage())[3]=="CHS" then 
			(turnCtrl = ctrlBiped.flip.controller)
			else(turnCtrl = ctrlBiped.turning.controller)
			bipCtrlTemp = #(vertCtrl,horzCtrl,turnCtrl)
			for c in bipCtrlTemp do
			(
				biped.moveKeys c offsetFrame #selection  -----移动选定的质心帧
			)
			for nodeBiped in bipedAll where nodeBiped != undefined do  -----移动其他biped的选定帧
			(
				biped.moveKeys nodeBiped.controller offsetFrame #selection
			)
		)
	)	

	mapped fn fnMoveBipedScaleKeys tempObj offsetFrame =  -------移动biped的缩放帧
	(
		ctrlBiped = tempObj.controller
		if classof ctrlBiped == BipSlave_Control then  --------下面判定子动画是否为scaleXYZ
		(
			if ((ctrlBiped[1][1] != undefined) and ((getSubAnimName ctrlBiped[1][1] 1) == #ScaleXYZ)) then
			(
				movekeys ctrlBiped[1][1][1] offsetFrame #selection
			)
		)
	)

	fn fnAddTrajLayer =
	(
		if (LayerManager.getLayerFromName "Biped_Trajectories") != undefined then
		(
			layerTraj = LayerManager.getLayerFromName "Biped_Trajectories"
		)
		else layerTraj = LayerManager.newLayerFromName "Biped_Trajectories"
		layerTraj.lock = on
	)

	fn fnAddBipedTraj tempBiped =
	(
		pointTraj = point name:("Traj_" + tempBiped.name) \
				size:0 cross:true 
		appendIfUnique arrTraj pointTraj
		freeze pointTraj
		pointTraj.pos = tempBiped.center
		pointTraj.parent = tempBiped
		layerTraj.addNode pointTraj
		deleteKeys pointTraj #allKeys
		pointTraj.showTrajectory = true
		-- ResetXForm pointTraj
	)

	fn fnDeleteTraj tempBiped =
	(
		local deleteTraj
		local deleteTrajName = ("Traj_" + tempBiped.name)
		local deleteTraArrID = findItem arrTraj deleteTrajName
		if deleteTraArrID != 0 then
		(
			deleteTraj = arrTraj[deleteTraArrID]
			deleteItem arrTraj deleteTraArrID
		)
		if (getNodeByName deleteTrajName) != undefined then (delete (getNodeByName deleteTrajName))
	)

	on rolloutBulletKeyTools open do  ----打开脚本时操作
	(------刷新图标, 图标是max自带的,主要是懒得做
		btnSelBeforeKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,3,3,3,3,true,true) 
		btnSelAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,11,11,11,11,true,true) 
		btnSelAllKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,26,26,26,26,true,true)
		btnMoveKeys.images = #("ViewportNavigationControls_24i.bmp","ViewportNavigationControls_24i.bmp",46,39,39,39,39,true,true)
-- 		btnMoveAfterKeys.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,13,13,13,13,true,true)
		
		timeDIsTemp = timeDisplayMode  ----小数帧还是整数帧
		-- iniPos = (GetDialogPos rolloutBulletKeyTools) 
		fnSaveConfig ()  ---------------脚本位置赋值
		fnSetConfig ()  ----------------保存位置信息到ini文件
		registerTimeCallback fnChangetRangeTime  -------------帧范围改变添加回调
		rolloutBulletKeyTools.gbxMinTools.visible  = false
	)
	
	on rolloutBulletKeyTools close do -- 关闭记忆浮动窗口位置
	(
		iniPos = (GetDialogPos rolloutBulletKeyTools)
		fnSetConfig ()
	)
	
	on rolloutBulletKeyTools mbuttondown pos do 
	(
		try (destroydialog rolloutBulletKeyTools) catch ()
	)
	
	on rolloutBulletKeyTools lbuttondown posMou do
	(
		posMouMoved = posMou
		fnMouseState = on
	)
	
	on rolloutBulletKeyTools lbuttonup posMou do
	(
		fnMouseState = off
	)
	
	on rolloutBulletKeyTools mouseMove pos do
	(
		if fnMouseState == on then
		(
			SetDialogPos rolloutBulletKeyTools (mouse.screenpos - posMouMoved)			
		)
	)
	
	on btnSelBoneBiped pressed do ----选择bone或者biped
	(
		clearselection ()
		for o in objects where (o.ishidden == false) do 
		(
			if classof o == Biped_Object then selectmore o
		)
	)

	on btnSelBoneBiped rightclick do ----选择bone或者biped
	(
		clearselection ()
		for o in objects where (o.ishidden == false) do 
		(
			if classof o == BoneGeometry then selectmore o
		)
	)

	on spiStartTime changed valTime do  --------初始帧定位到输入的帧数
	(		
		local rangeStart = valTime as time
		if ((valTime != ".") and (valTime as time != undefined) and \
		(valTime != "") and (rangeStart < animationrange.end)) then
		(
			animationrange = (interval rangeStart animationrange.end)
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)

	on spiEndTime changed valTime do  --------初始帧定位到输入的帧数
	(		
		local rangEnd = valTime as time
		if ((valTime != ".") and (valTime as time != undefined) and \ 
		(valTime != "") and (rangEnd > animationrange.start)) then
		(
			animationrange = (interval animationrange.start rangEnd)
		)
		else messageBox "----------------------\r\n请输入正确帧数!"
	)
	
	on btnFnFrameTicks rightclick do  -------------切换整数帧小数帧,方便拖动滑条平滑预览
	(
		if timeDisplayMode != #frameTicks then 
		(
			timeDisplayMode = #frameTicks
			btnFnFrameTicks.text = " (=`▽`)"
		)
		else 
		(
			timeDisplayMode = #frames
			btnFnFrameTicks.text = "✧(≖ ◡ ≖"
		)
		slidertime -= 1
		slidertime += 1  ----------默认改了要划一下滑条才生效,脚本直接操作了~~没找到refresh的
	)
	
	on btnFnFrameTicks pressed do  -------------切换整数帧小数帧,方便拖动滑条平滑预览
	(
		if rolloutBulletKeyTools.gbxMinTools.visible  == true then
		(
			rolloutBulletKeyTools.width = 200
			rolloutBulletKeyTools.gbxMinTools.visible  = false
			btnFnFrameTicks.text = "✧(≖ ◡ ≖"
		)
		else
		(
			rolloutBulletKeyTools.width = 350
			rolloutBulletKeyTools.gbxMinTools.visible  = true
			btnFnFrameTicks.text = "(= `▽`)"
		)
	)

	on btnBoneTraj pressed do ------显示bone的轨迹
	(
		for i in (selection as array) where (classof i != Biped_Object) do
		(
			if i.showtrajectory == true then i.showtrajectory = false
			else i.showtrajectory = true
		)
	)

	on btnBoneTraj rightclick do   ----右键取消bone的轨迹显示
	(
		for i in (objects as array) where (classof i != Biped_Object) do
		(
			if i.showtrajectory == true then i.showtrajectory = false
		)
	)

	on btnBipedTraj pressed do 
	(
		fnAddTrajLayer () ----是否创建轨迹层
		if (selection.count > 1) then
		(
			for i in (selection as array) do
			(
				if classof i == Biped_Object then
				(
					if (getNodeByName ("Traj_" + i.name)) != undefined then 
					(
						fnDeleteTraj i
					)
				)
			)
		)
		else if selection.count == 1 then
		(
			if classof $ == Biped_Object then
				(
					if (getNodeByName ("Traj_" + $.name)) != undefined then 
					(
						fnDeleteTraj $
					)
					else fnAddBipedTraj $
				)
		)
	)

	on btnBipedTraj rightclick do
	(
		-- bipedRoot = #()   -------判断选择了几个biped骨架
		if (selection.count > 0) then
		(
			-- for i in (selection as array) where classof i == Biped_Object do  
			-- (
			-- 	appendIfUnique bipedRoot i.controller.rootNode  --添加到骨架数组
			-- )
			for i in (selection as array) do 
			(
				if (classof i == Biped_Object) then
				(
					nodeTemp = i.controller.rootNode
					trajDisFn = nodeTemp.controller.displayTrajectories
					if trajDisFn == true then nodeTemp.controller.displayTrajectories = false
					else nodeTemp.controller.displayTrajectories = true
					exit
				)
			)
		)
	)

	on edtMoveKey entered val do   -----移动帧数自定义,输入即可
	(
		if ((val != ".") and (val as time != undefined) and (val != "")) then
		(------"."他也认为是数字...
			keyMovedOffset = val as integer
			rolloutBulletKeyTools.edtMoveKey.text = keyMovedOffset as string + "f"
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
	on btnMoveKeys pressed do with undo on   ------移动选定帧
	(
		local rangEnd = animationrange.end
		local rangeStart = animationrange.start
		local n = 0  --n来判定是否有选中biped

		if keyMovedOffset != undefined then
		(
			if selection.count != 0 then
			(
				for i in selection where (i.ishidden == false) do
				(
					if classof i != Biped_Object then
					(
						fnMoveKeysAndLinkKeys i keyMovedOffset symbol
					)
					else 
					(
						fnMoveBipedScaleKeys i keyMovedOffset
						n += 1
					)
				)
				if n != 0 then  ----------分开解决biped多移动的问题,傻瓜式方法
				(
					fnMoveBipedKeys keyMovedOffset
				)
			)
			else  ---跟上面一样,只是对所有物体
			(
				for i in objects where (i.ishidden == false) do
				(
					if classof i != Biped_Object then
					(
						fnMoveKeysAndLinkKeys i keyMovedOffset symbol
					)
					else fnMoveBipedScaleKeys i keyMovedOffset
				)
				fnMoveBipedKeys keyMovedOffset
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
	on btnMoveKeys rightclick do with undo on
	(
		local n = 0
		if keyMovedOffset != undefined then  ---跟前面一样,只是不改变帧栏范围
		(
			if selection.count != 0 then
			(
				for i in selection where (i.ishidden == false) do
				(
					if classof i != Biped_Object then
					(
						fnMoveKeysAndLinkKeys i keyMovedOffset symbol
					)
					else 
					(
						fnMoveBipedScaleKeys i keyMovedOffset
						n += 1
					)
				)
				if n != 0 then
				(
					fnMoveBipedKeys keyMovedOffset
				)
			)
			else 
			(
				for i in objects where (i.ishidden == false) do
				(
					if classof i != Biped_Object then
					(
						fnMoveKeysAndLinkKeys i keyMovedOffset symbol
					)
					else fnMoveBipedScaleKeys i keyMovedOffset
				)
				fnMoveBipedKeys keyMovedOffset
			)
		)
	)
	on btnSelBeforeKeys pressed do  ------------选择滑条之前帧
	(
		symbol = 0
		fnCollectKeys ()
		if arrLinkKeys.count != 0 then
		(
			for i in arrLinkKeys do i.selected = false
		)
		if arrKeysTime.count != 0 then
		(
			if keyFirst <= sliderTime then 
			(
				fnSelKeys keyFirst sliderTime symbol
			)
			else 
			(
				fnSelKeys sliderTime sliderTime symbol
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				if arrLinkKeys[1].time <= sliderTime then 
				(
					fnSelLinkKeys arrLinkKeys[1].time sliderTime symbol
				)
				else 
				(
					fnSelLinkKeys sliderTime sliderTime symbol
				)
			)
		)
	)
	
	on btnSelAfterKeys pressed do  -------------选择滑条之后帧
	(
		symbol = 1
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
			if keyEnd >= sliderTime then 
			(
				fnSelKeys sliderTime keyEnd symbol
			)
			else 
			(
				fnSelKeys sliderTime sliderTime symbol
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				if arrLinkKeys[1].time >= sliderTime then 
				(
					fnSelLinkKeys sliderTime arrLinkKeys[1].time symbol
				)
				else 
				(
					fnSelLinkKeys sliderTime sliderTime symbol
				)
			)
		)
	)
	
	on btnSelAllKeys pressed do     ------------------选择所有帧
	(
		symbol = 2
		fnCollectKeys ()
		if arrKeysTime.count != 0 then
		(
			fnSelKeys keyFirst keyEnd symbol
		)
		else
		(
			if arrLinkKeys.count != 0 then
			(
				fnSelLinkKeys arrLinkKeys[1].time arrLinkKeys[arrLinkKeys.count].time symbol
			)
		)
	)

	on btnClearSelKeys pressed do  ---------------------清除帧选择
	(
		fnCollectKeys ()
		if arrKeysTime.count != 0 then  ----清除非link帧
		(
			for i in objects where (i.ishidden == false) do deselectKeys i
			if arrLinkKeys.count != 0 then
			(
				for i in arrLinkKeys do i.selected = false
			)
		)
		else
		(
			if arrLinkKeys.count != 0 then  ---清除link帧
			(
				for i in arrLinkKeys do i.selected = false
			)
		)
	)
	
	on btnJudgeLinkKey changed state do   --切换是否勾选link
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
				case of  ------万恶的link帧导致更多判定
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
	on btnDelOutKeys rightclick do with undo on-----------清理范围外帧(无限帧)
	(
		if (selection as array).count == 0 then 
		(
			for tempObject in (Objects as Array) do CleanOutRangeKeys tempObject
		)
		else
		(
			for tempObject in (selection as Array) do CleanOutRangeKeys tempObject
		)
	)

	on btnDelOutKeys pressed do with undo on-----------清理选择帧
	(
		for o in selection where ((classof o == Biped_Object) and (o.ishidden == false)) do 
		(
			if classof o.controller == Vertical_Horizontal_Turn then  --清理质心帧
			(
				biped.deleteKeys o.controller.vertical #selection
				biped.deleteKeys o.controller.horizontal #selection
				if (sysinfo.GetMaxLanguage())[3]=="CHS" then 
					(biped.deleteKeys o.controller.flip #selection)
					else(biped.deleteKeys o.controller.turning #selection)
			)
			else if classof o.controller == BipSlave_Control then  --清理biped正常帧
			(
				biped.deleteKeys o.controller #selection
				subanimBipedScale = GetSubAnim o.controller[1] 1
				if ((subanimBipedScale != undefined) and \
				(GetSubAnimName subanimBipedScale 1 == #ScaleXYZ)) then  --清理biped的所方针
				(
					deleteKeys subanimBipedScale.controller #selection
				)
			)
		)
		for o in selection where ((classof o != Biped_Object) and (o.ishidden == false)) do  ---清理非biped帧
		(
			deleteKeys o #selection
		)
	)

	on btnHideBones pressed do
	(
		if hideByCategory.bones == false then 
		(
			hideByCategory.bones = true
			btnHideBones.text = " ☼ 显骨"
		)
		else 
		(
			hideByCategory.bones = false
			btnHideBones.text = "☁ 藏骨"
		)
-- 		redrawviews()
		slidertime -= 1
		slidertime += 1
	)
)

Createdialog rolloutBulletKeyTools fgcolor:(color 255 20 100) pos:iniPos style:#()
clearListener()  ---------清除侦听器