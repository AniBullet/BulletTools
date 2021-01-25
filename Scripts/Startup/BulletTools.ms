/*
 * @Description: 版权归作者,请勿私自盗用甚至商用!!!
 * @Author: Bullet.S
 * @Date: 2019-08-03 17:36:21
 * @LastEditors: Bullet.S
 * @LastEditTime: 2021-01-25 12:18:35
 * @Email: animator.bullet@foxmail.com
 */

try (cui.unRegisterDialogBar rolBsTools) catch()
try (destroyDialog rolBsTools) catch()

Global ver = "0.8"

Global pathScripts = execute ("@\"" + (getDir #scripts) + "\\BulletS\"")
Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
-- Global pathLitScripts = execute ("@\"" + (getDir #scripts) + "\\BulletScripts\"")
Global arrClass = #()
Global nameArrClass = #()
Global arrScripts = #()
Global nameArrScripts = #()
Global arrTools = #()
Global nameArrTools = #()
Global iniBsToolsStyle --样式保存记录
Global iniBsToolsPos  --位置保存记录
Global iniBsToolsSize  --记录窗口大小
Global iniBsToolsClassIn  --记录按下的脚本类别
Global posBtn = [3,5]  --单个按钮位置,以此叠加
Global widthBtn = 55  --按钮长度
Global heightBtn = 20  --按钮高度
Global rolWidth = (widthBtn + 30)
Global rolHeight = 415
Global rolloutClasses
Global rolloutScripts
Global rolloutTools
Global rolloutLit
Global rolBsTools
Global fnResize
global myfgColor

------------------------方法引用-------------------------------
-- FileIn (pathLitScripts + "\\fnSetPlaybackSpeed.ms")
-- FileIn (pathLitScripts + "\\fnSetFps.ms")


---------------------------------------------------------------

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr)  --先提取文件中的记录
	if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
)

fn fnSaveConfig =  --引用上面方法提出需要的参数
(
	iniBsToolsPos = fnGetConfig iniBsToolsPos "GlobalSet" "Pos" (mouse.screenpos as string)
	iniBsToolsSize = fnGetConfig iniBsToolsSize "GlobalSet" "Size" ([rolWidth,950] as string)
	iniBsToolsStyle = fnGetConfig iniBsToolsStyle "GlobalSet" "Dock" "0"
	iniBsToolsClassIn = fnGetConfig iniBsToolsClassIn "GlobalSet" "ClassPressed" "1"
)
fnSaveConfig () --初始执行一遍
fn fnSetConfig =  --保存参数
(
	SetINISetting BulletConfig "GlobalSet"  "Pos" (iniBsToolsPos as string)
	SetINISetting BulletConfig "GlobalSet"  "Dock" (iniBsToolsStyle as string)
	SetINISetting BulletConfig "GlobalSet"  "Size" (iniBsToolsSize as string)
	SetINISetting BulletConfig "GlobalSet"  "ClassPressed" (iniBsToolsClassIn as string)
)
fn fnGetColorTheme =
(
	local curColorThemeFile = colorMan.getFileName()
	if (curColorThemeFile != undefined) then
	(
		if (matchpattern curColorThemeFile pattern:"*light*") then
		(
			myfgColor    = (color 65 105 225)
			myClickColor = (color 0 139 139)
		)
		else
		(
			myfgColor    = (color 219 209 72)
			myClickColor = (color 0 255 127)
		)
	)
	else
	(
		myfgColor    = (color 219 209 72)
		myClickColor = (color 0 255 127)
	)
)
fnGetColorTheme() ----获取当前主题是深色还是浅色,来更改文字颜色
------ ↓ 判断脚本文件夹是否为空
arrClass = GetDirectories (pathScripts + "/*");sort arrClass
arrTools = getFiles (pathScripts + "\\" + "*.m*"); sort arrTools
if arrClass[1] != undefined then
(
	for c in arrClass do  --获取文件夹名字,后面切换脚本类别和列表会用到
	(
		append nameArrClass (getFilenameFile (substring c 1 (c.count-1)))
	)
	arrScripts = getFiles (pathScripts + "\\" + nameArrClass[iniBsToolsClassIn] + ("\\" + "*.m*")); sort arrScripts
)
else
(
	if arrTools[1] == undefined then
	(
		makeDir ((getDir #scripts) + "\\BulletS")
		--设置dotNet窗口元素
		local mb = dotNetClass "System.Windows.Forms.MessageBox"
		local buttons = dotNetClass "System.Windows.Forms.MessageBoxButtons"
		local icons = dotNetClass "System.Windows.Forms.MessageBoxIcon"
		local defaultButton = dotNetClass "System.Windows.Forms.MessageBoxDefaultButton"
		local dialogResult = dotNetClass "System.Windows.Forms.DialogResult"

		local result = mb.show "没有找到脚本和分类,是否打开文件夹 ?" "复制脚本" buttons.YesNoCancel icons.Information defaultButton.Button3

		--选项按钮
		if ( result == dialogResult.Yes ) then
		(
			shellLaunch pathScripts ""
		)
		else if ( result == dialogResult.No ) then
		(
		format "NO\n"
		)
		else if ( result == dialogResult.Cancel ) then
		(
		format "CANCEL\n"
		)
	)
)

fn fnClose = --关闭工具
(
	try (cui.unRegisterDialogBar rolBsTools) catch()
	try (destroyDialog rolBsTools) catch()
)

fn fnAddButton nameBtn arrDir arrName tips = --根据文件夹和里面脚本添加按钮方法
(
	if (arrDir.count > 0) then
	(
		Local str = ""
		case of
		(
			(nameBtn == "btnClass"):
			(
				str = "rollout rolloutClasses \"类别\"(\r\n"
				for n = 1 to arrDir.count do 
				(				
					str += "button " + nameBtn + n as string + " \"" + arrName[n] + "\" pos:("+ posBtn as string + "+ [0," + ((n - 1) * heightBtn) as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[n] + tips + "\"" + "\r\n"
					str += "on btnClass" + (n as string) + " pressed do (\r\n iniBsToolsClassIn = " + (n as string) + "\r\n" + "SetINISetting BulletConfig \"GlobalSet\"  \"ClassPressed\" \"" + (n as string) + "\"\r\n fnRefreshScripts nameArrClass[iniBsToolsClassIn]\r\n)\r\n"
					str += "on btnClass" + (n as string) + " rightclick do (\r\n shellLaunch (@\"" + arrDir[n] + "\") \"\"\r\n)\r\n"
				)
				str += ")"
			)
			(nameBtn == "btnScripts"): 
			(
				str = "rollout rolloutScripts \"" + nameArrClass[iniBsToolsClassIn] + "\"(\r\n"
				
				for num = 1 to arrDir.count do
				(
					str += "button " + nameBtn + num as string + " \"" + arrName[num] + "\" pos:("+ posBtn as string + "+ [0," + ((num-1) * heightBtn)as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[num] + " (" + tips + ")\"" + "\r\n"
					str += "on btnScripts" + (num as string) + " pressed do (\r\n" + "try(FileIn (@\"" + arrDir[num] + "\"))catch(messagebox\"脚本疑丢失，请刷新脚本列表...        \")" + "\r\n)\r\n"
				)
				str += ")"
			)
			(nameBtn == "btnTools"): 
			(
				str = "rollout rolloutTools \"小工具\"(\r\n"
				
				for num = 1 to arrDir.count do
				(
					str += "button " + nameBtn + num as string + " \"" + arrName[num] + "\" pos:("+ posBtn as string + "+ [0," + ((num-1) * heightBtn)as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[num] + " (" + tips + ")\"" + "\r\n"
					str += "on btnTools" + (num as string) + " pressed do (\r\n" + "try(FileIn (@\"" + arrDir[num] + "\"))catch(messagebox\"脚本疑丢失，请刷新脚本列表...        \")" + "\r\n)\r\n"
				)
				str += ")"
			)
		)
	)
)

fn fnUninst = --卸载方法(待补充)
(
	--设置dotNet窗口元素
	local mb = dotNetClass "System.Windows.Forms.MessageBox"
	local buttons = dotNetClass "System.Windows.Forms.MessageBoxButtons"
	local icons = dotNetClass "System.Windows.Forms.MessageBoxIcon"
	local defaultButton = dotNetClass "System.Windows.Forms.MessageBoxDefaultButton"
	local dialogResult = dotNetClass "System.Windows.Forms.DialogResult"

	local result = mb.show "确定卸载此工具 ( BulletTools ) 吗 ?" "脚本卸载" buttons.YesNoCancel icons.Information defaultButton.Button3

	--选项按钮
	if ( result == dialogResult.Yes ) then
	(
		fnClose ()
		if (doesfileexist pathScripts == true) then
		(
			deleteFile pathScripts
		)
		if (doesfileexist BulletConfig == true) then
		(
			deleteFile BulletConfig
		)
		if (doesfileexist ((getDir #StartupScripts) + "\\BulletTools.ms") == true) then
		(
			setFileAttribute ((getDir #StartupScripts) + "\\BulletTools.ms") #readOnly false
			deleteFile ((getDir #StartupScripts) + "\\BulletTools.ms")
		)
		if (doesfileexist ((getDir #Scripts) + "\\BulletTools.ms") == true) then
		(
			deleteFile ((getDir #Scripts) + "\\BulletTools.ms")
		)
		if (doesfileexist ((getDir #userMacros)+"\\_[BulletTools]-BulletTools.mcr") == true) then
		(
			setFileAttribute ((getDir #userMacros)+"\\_[BulletTools]-BulletTools.mcr") #readOnly false
			deleteFile ((getDir #userMacros)+"\\_[BulletTools]-BulletTools.mcr")
		)
		
		if (shellLaunch (getDir #scripts) "") then
		(
			messagebox "BulletTools工具已删除卸载,\r\n\r\n也可能由于权限原因,\r\n\r\n需手动删除打开窗口下的\r\n\r\n\"BulletS\"文件夹~\r\n\r\n"
		)
	)
	else if ( result == dialogResult.No ) then
	(
	format "NO\n"
	)
	else if ( result == dialogResult.Cancel ) then
	(
	format "CANCEL\n"
	)
)

fn fnRefreshClass rolloutClasses =  --刷新脚本类别按钮
(	
	try (removeSubRollout rolBsTools.BsToolsMain rolloutClasses) catch()

	Local tips = " (右键打开文件夹)"
	Local str
	
	arrClass = GetDirectories (pathScripts + "/*");sort arrClass
	if arrClass[1] != undefined then 
	(
		nameArrClass = #()
		for c in arrClass do  --获取文件夹名字,后面切换脚本类别和列表会用到
		(
			append nameArrClass (getFilenameFile (substring c 1 (c.count-1)))
		)
		str = fnAddButton "btnClass" arrClass nameArrClass tips

		rolloutClasses = (execute str)
		AddSubRollout rolBsTools.BsToolsMain rolloutClasses
		case of
		(
			(arrClass.count <= 4):(rolBsTools.BsToolsMain.height = ((arrClass.count+1) * heightBtn + 10))
			(arrClass.count > 4):(rolBsTools.BsToolsMain.height = (5 * heightBtn + 10))
		)
		rolBsTools.BsToolsMain.width = 75
		rolBsTools.BsToolsMain.pos = [5,30]  --根据groSettings位置得出
		rolBsTools.BsToolsScripts.pos = rolBsTools.BsToolsMain.pos + [0,(rolBsTools.BsToolsMain.height + 5)]
		rolBsTools.BsToolsTool.pos = rolBsTools.BsToolsScripts.pos + [0,(rolBsTools.BsToolsScripts.height + 5)]
		if iniBsToolsStyle == 0 then rolBsTools.height = 45 + rolBsTools.BsToolsMain.height + rolBsTools.BsToolsScripts.height + rolBsTools.BsToolsTool.height
	)
)
fn fnRefreshScripts pressedClass =  --刷新脚本列表按钮
(
	try (removeSubRollout rolBsTools.BsToolsScripts rolloutScripts) catch()

	Local tips = "点击运行脚本"
	Local str
	
	if arrClass[1] != undefined then 
	(
		arrScripts = getFiles (pathScripts + "\\" + pressedClass + ("\\" + "*.m*")); sort arrScripts
			
		case of
		(
			(arrScripts[1] != undefined):
			(
				nameArrScripts = #()
				for s in arrScripts do  --获取脚本
				(
					append nameArrScripts (getFilenameFile (substring s 1 (s.count-1)))
				)
				
				str = fnAddButton "btnScripts" arrScripts nameArrScripts tips

				rolloutScripts = (execute str)
				AddSubRollout rolBsTools.BsToolsScripts rolloutScripts
				case of
				(
					(arrScripts.count <= 8):
					(
						rolBsTools.BsToolsScripts.height = ((arrScripts.count + 1) * heightBtn + 10)
					)
					(arrScripts.count > 8):
					(
						rolBsTools.BsToolsScripts.height = (9 * heightBtn + 10)
					)
				)
				rolBsTools.BsToolsScripts.width = 75
				rolBsTools.BsToolsScripts.pos = rolBsTools.BsToolsMain.pos + [0,(rolBsTools.BsToolsMain.height + 5)]
				rolBsTools.BsToolsTool.pos = rolBsTools.BsToolsScripts.pos + [0,(rolBsTools.BsToolsScripts.height + 5)]
				if iniBsToolsStyle == 0 then rolBsTools.height = 45 + rolBsTools.BsToolsMain.height + rolBsTools.BsToolsScripts.height + rolBsTools.BsToolsTool.height
			)
			(arrScripts[1] == undefined):
			(
				str = "rollout rolloutScripts \"脚本列表\" \r\n(\r\n	label labelTipsScripts \"   ( 空 )   \" align:#center \r\n\r\n)"
				
				rolloutScripts = (execute str)
				AddSubRollout rolBsTools.BsToolsScripts rolloutScripts
				rolBsTools.BsToolsScripts.width = 75
				rolBsTools.BsToolsScripts.height = (2 * heightBtn + 10)
				rolBsTools.BsToolsScripts.pos = rolBsTools.BsToolsMain.pos + [0,(rolBsTools.BsToolsMain.height + 5)]
				rolBsTools.BsToolsTool.pos = rolBsTools.BsToolsScripts.pos + [0,(rolBsTools.BsToolsScripts.height + 5)]
				if iniBsToolsStyle == 0 then rolBsTools.height = 45 + rolBsTools.BsToolsMain.height + rolBsTools.BsToolsScripts.height + rolBsTools.BsToolsTool.height
			)
		)
	)
)
fn fnRefreshTools =  --刷新小工具
(
	try (removeSubRollout rolBsTools.BsToolsTool rolloutTools) catch()
	
	Local tips = "点击运行脚本"
	Local str
	
	arrTools = getFiles (pathScripts + "\\" + "*.m*"); sort arrTools
	if arrTools[1] != undefined then
	(
		nameArrTools = #()
		for t in arrTools do  --获取脚本
		(
			append nameArrTools (getFilenameFile (substring t 1 (t.count-1)))
		)

		str = fnAddButton "btnTools" arrTools nameArrTools tips

		rolloutTools = (execute str)
		AddSubRollout rolBsTools.BsToolsTool rolloutTools
		case of
		(
			(arrTools.count <= 10):
			(
				rolBsTools.BsToolsTool.height = ((arrTools.count + 1) * heightBtn + 10)
			)
			(arrTools.count > 10):
			(
				rolBsTools.BsToolsTool.height = (11 * heightBtn + 10)
			)
		)
		rolBsTools.BsToolsTool.width = 75
		rolBsTools.BsToolsTool.pos = rolBsTools.BsToolsScripts.pos + [0,(rolBsTools.BsToolsScripts.height + 5)]
		if iniBsToolsStyle == 0 then rolBsTools.height = 45 + rolBsTools.BsToolsMain.height + rolBsTools.BsToolsScripts.height + rolBsTools.BsToolsTool.height
	)
)

fn fnRefreshList =  ------------更新脚本列表
(
	fnRefreshClass rolloutClasses
	fnRefreshScripts nameArrClass[iniBsToolsClassIn]
	fnRefreshTools ()
)

rcmenu menuBsToolsSetting --设置菜单
(	
	-- menuItem menufnResize "恢复默认高度"
	menuItem menuCustom "打开脚本文件夹"
	menuItem menuUpdate "更新脚本列表"
	subMenu "停靠方式"
	(
		menuItem mItemDockL "左"
		menuItem mItemDockR "右"
		menuItem mItemUnDock "浮动"
	)
	subMenu "自启设置"
	(
		menuItem menuNoAutorun "解除脚本自启"
		menuItem menuAutorun "打开脚本自启"
	)
	menuItem menuClose "关闭工具"
	separator menuSep01
	menuItem menuLink "更新地址"
	menuItem menuBlog "个人网站"
	separator menuSep02
	menuItem menuUninst "卸载"
	
	on menuClose picked do --关闭脚本
	(
		fnClose ()
	)
	on menuUninst picked do --卸载,带提示
	(
		fnUninst ()
	)
	on menuCustom picked do  --打开自定脚本目录
	(
		shellLaunch pathScripts ""
	)
	on menuNoAutorun picked do  --设置自启
	(
		if (doesfileexist ((getDir #StartupScripts) + "\\BulletTools.ms") == true) then
		(
			setFileAttribute ((getDir #StartupScripts) + "\\BulletTools.ms") #readOnly false
			deleteFile ((getDir #StartupScripts) + "\\BulletTools.ms")
			messagebox "------------------------------------------\r\n脚本自启已解除,\r\n但仍可点击工具栏按钮打开~        \r\n\r\n"
		)
		else messagebox "-----------------------------------------\r\n已是非自启状态,无需再次操作~\r\n可点击\"打开自启\"选项打开自启~        \r\n\r\n"
	)
	on menuAutorun picked do  --解除自启
	(
		if (doesfileexist ((getDir #StartupScripts) + "\\BulletTools.ms") == false) then
		(
			copyFile ((getDir #Scripts)+"\\BulletTools.ms") ((getDir #startupScripts)+"\\BulletTools.ms")
			messagebox "-----------------------------------------\r\n脚本自启已打开        ~\r\n\r\n"
		)
		else messagebox "-----------------------------------------\r\n已是自启状态,无需再次操作~\r\n可点击\"解除自启\"选项解除自启        \r\n\r\n"
	)
	on menuUpdate picked do  --更新脚本列表
	(
		fnRefreshList ()
	)
	-- on menufnResize picked do  --重置为初始宽高
	-- (
	-- 	fn fnResize =
	-- 	(
	-- 		iniBsToolsSize = [rolWidth,rolHeight]
	-- 		rolBsTools.width = rolWidth
	-- 		rolBsTools.height = rolHeight
	-- 	)
	-- 	Local styleTemp
	-- 	if (iniBsToolsStyle == 0) then
	-- 	(
	-- 		fnResize ()
	-- 	)
	-- 	else
	-- 	(
	-- 		styleTemp = cui.getDockState rolBsTools
	-- 		try (cui.unRegisterDialogBar rolBsTools) catch()
	-- 		fnResize ()
	-- 		cui.RegisterDialogBar rolBsTools maxSize:[rolWidth,rolHeight]
	-- 		cui.DockDialogBar rolBsTools styleTemp
	-- 	)
	-- 	SetINISetting BulletConfig "GlobalSet"  "Size" (iniBsToolsSize as string)
	-- )
	on menuLink picked do  --左键点击跳转链接
	(
		shellLaunch "https://github.com/AnimatorBullet/BulletTools" ""
	)
	on menuBlog picked do  --左键点击跳转链接
	(
		shellLaunch "https://www.anibullet.com/" ""
	)

	on mItemDockL picked do 
	(
		iniBsToolsPos = (GetDialogPos rolBsTools)
		try (cui.unRegisterDialogBar rolBsTools) catch()
		rolBsTools.height = rolHeight
		rolBsTools.width = rolWidth
		rolBsTools.fnUiStyle 1;iniBsToolsStyle = 1
		fnRefreshList ()
	)  --停靠左边

	on mItemDockR picked do 
	(
		iniBsToolsPos = (GetDialogPos rolBsTools)
		try (cui.unRegisterDialogBar rolBsTools) catch()
		rolBsTools.height = rolHeight
		rolBsTools.width = rolWidth
		rolBsTools.fnUiStyle 2;iniBsToolsStyle = 2
		fnRefreshList ()
	)  --停靠右边

	on mItemUnDock picked do 
	(
		rolBsTools.fnUiStyle 0;iniBsToolsStyle = 0
		rolBsTools.width = rolWidth
		rolBsTools.height = 55 + rolBsTools.BsToolsMain.height + rolBsTools.BsToolsScripts.height + rolBsTools.BsToolsTool.height
		fnRefreshList ()
	)  --浮动
)

rollout rolBsTools "" width:rolWidth height:iniBsToolsSize[2]
(
	local strTop = ("BsTools_v" + ver)
	label lblTop strTop pos:[5,0] width:(rolBsTools.width - 10)
	label lblSetting "[右击设置]" pos:[15,15] width:(rolBsTools.width - 10)

	subrollout BsToolsMain ""
	subrollout BsToolsScripts ""
	subrollout BsToolsTool ""
	
	
	local posMouMoved = [0,0]
	local switchMouseState = off
	local uiClientOffsets = undefined
	
	fn fnUiStyle iniBsToolsStyle = --判断停靠位置方法
	(
		iniBsToolsSize = (GetDialogSize rolBsTools)
		SetINISetting BulletConfig "GlobalSet"  "Size" (iniBsToolsSize as string)
		case of 
		(
			(iniBsToolsStyle == 1):
			(
				cui.RegisterDialogBar rolBsTools  maxSize:[rolWidth,rolHeight]
				cui.DockDialogBar rolBsTools #cui_dock_left  --切换工具嵌入浮动位置和大小等
			)
			(iniBsToolsStyle == 2):
			(
				cui.RegisterDialogBar rolBsTools  maxSize:[rolWidth,rolHeight]
				cui.DockDialogBar rolBsTools #cui_dock_right  --切换工具嵌入浮动位置和大小等
			)
			(iniBsToolsStyle == 0):
			(	
				try (cui.unRegisterDialogBar rolBsTools) catch()
				rolBsTools.width = rolWidth;rolBsTools.height = iniBsToolsSize[2]  --切换工具嵌入浮动位置和大小等
			)
		)
		fnSetConfig ()
	)

	on rolBsTools open do -- 打开加载停靠位置,0=浮动,1=左,2=右
	(
		fnRefreshList ()
		fnSaveConfig ()
		cui.RegisterDialogBar rolBsTools  maxSize:[rolWidth,rolHeight]
		fnUiStyle iniBsToolsStyle
	)
	on rolBsTools close do -- 关闭记忆浮动窗口位置
	(
		if iniBsToolsStyle == 0 then iniBsToolsPos = (GetDialogPos rolBsTools)
		iniBsToolsSize = (GetDialogSize rolBsTools)
		fnSetConfig ()
	)

	on rolBsTools rbuttondown pos do 
	(
		popupMenu menuBsToolsSetting pos:[mouse.screenpos.x + 20,mouse.screenpos.y]
	)
	
	on rolBsTools lbuttondown posMou do
	(
		if(iniBsToolsStyle == 0) then
		(
			posMouMoved = posMou
			switchMouseState = on
		)
	)
	
	on rolBsTools lbuttonup posMou do
	(
		if(iniBsToolsStyle == 0) then
		(
			switchMouseState = off
		)
	)
	
	on rolBsTools mouseMove pos do
	(
		if(iniBsToolsStyle == 0) then
		(
			if switchMouseState == on then
			(
				SetDialogPos rolBsTools (mouse.screenpos - posMouMoved)			
			)
			if (uiClientOffsets == undefined) then 
			(
				uiClientOffsets = pos - (mouse.screenPos - (getDialogPos rolBsTools)) 
			)
		)
	)
)

rollout rolloutClasses ""
(	
	on rolloutClasses open do 
	(
		fnRefreshClass rolloutClasses
	)
)
rollout rolloutScripts "脚本列表"
(	
	on rolloutScripts open do 
	(
		if nameArrClass[1] != undefined then
		(
			fnRefreshScripts nameArrClass[iniBsToolsClassIn]
		)
	)
)
rollout rolloutTools "小工具"
(
	on rolloutScripts open do 
	(
		if nameArrTools[1] != undefined then
		(
			fnRefreshTools ()
		)
	)
)
CreateDialog rolBsTools pos:iniBsToolsPos fgcolor:myfgColor style:#()
------------------- 创建子卷轴栏和按钮等等UI -------------------------------------------
fnRefreshClass rolloutClasses
fnRefreshScripts nameArrClass[iniBsToolsClassIn]
fnRefreshTools ()
clearListener()  --清空监听器

macroScript BulletTools
category:"_[BulletTools]"
buttonText:"_BulletTools_Start"
toolTip:"_BulletTools_Start"
Icon:#("Systems",2)
(
	on execute do
	(
		try(fileIn ((getDir #Scripts)+"\\"+"BulletTools.ms"))catch(messagebox"打开失败，请尝试重新安装BsTools...        ")
	)
)