/*
 * @Description: 版权归作者,请勿私自盗用甚至商用!!!
 * @Author: Bullet.S
 * @Date: 2019-08-03 17:36:21
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-11-03 01:48:48
 * @Email: animator.bullet@foxmail.com
 */

try (cui.unRegisterDialogBar BStools) catch()
try (destroyDialog BStools) catch()

Global mouPosX = mouse.screenpos.x  
Global mouPosY = mouse.screenpos.y  --获取鼠标位置

Global ver = " v0.6 -- Bullet.S"

Global pathScripts = ((getDir #scripts) + "\\BulletS")
Global BulletConfig = ((getDir #scripts) + "\\BulletConfig.ini")  --配置文件路径
Global pathLitScripts = ((getDir #scripts) + "\\BulletScripts")
Global arrClass = #()
Global nameArrClass = #()
Global arrScripts = #()
Global nameArrScripts = #()
Global arrTools = #()
Global nameArrTools = #()
Global iniStyle --样式保存记录
Global iniPos  --位置保存记录
Global iniSize  --记录窗口大小
Global iniClassIn  --记录按下的脚本类别
Global posBtn = [3,5]  --单个按钮位置,以此叠加
Global widthBtn = 55  --按钮长度
Global heightBtn = 25  --按钮高度
Global rolWidth = (widthBtn * 2 + 40)
Global rolHeight = 994
Global rolloutClasses
Global rolloutScripts
Global rolloutTools
Global rolloutLit
Global BsTools
Global fnResize

------------------------方法引用-------------------------------
FileIn (pathLitScripts + "\\fnSetPlaybackSpeed.ms")
FileIn (pathLitScripts + "\\fnSetFps.ms")


---------------------------------------------------------------

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr)  --先提取文件中的记录
	if attr == "" then attr = (execute valueAttr) else (attr = execute attr)  --判断记录为空与否得到需要的记录参数
)

fn fnSaveConfig =  --引用上面方法提出需要的参数
(
	iniPos = fnGetConfig iniPos "GlobalSet" "Pos" ([mouPosX,mouPosY] as string)
	iniSize = fnGetConfig iniSize "GlobalSet" "Size" ([rolWidth,950] as string)
	iniStyle = fnGetConfig iniStyle "GlobalSet" "Dock" "0"
	iniClassIn = fnGetConfig iniClassIn "GlobalSet" "ClassPressed" "1"
)
fnSaveConfig () --初始执行一遍
fn fnSetConfig =  --保存参数
(
	SetINISetting BulletConfig "GlobalSet"  "Pos" (iniPos as string)
	SetINISetting BulletConfig "GlobalSet"  "Dock" (iniStyle as string)
	SetINISetting BulletConfig "GlobalSet"  "Size" (iniSize as string)
	SetINISetting BulletConfig "GlobalSet"  "ClassPressed" (iniClassIn as string)
)

------ ↓ 判断脚本文件夹是否为空
arrClass = GetDirectories (pathScripts + "/*");sort arrClass
arrTools = getFiles (pathScripts + "\\" + "*.m*"); sort arrTools
if arrClass[1] != undefined then
(
	for c in arrClass do  --获取文件夹名字,后面切换脚本类别和列表会用到
	(
		append nameArrClass (getFilenameFile (substring c 1 (c.count-1)))
	)
	arrScripts = getFiles (pathScripts + "\\" + nameArrClass[iniClassIn] + ("\\" + "*.m*")); sort arrScripts
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
			shellLaunch "explorer.exe" pathScripts
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
	if iniStyle == 0 then destroyDialog BStools 
	else (cui.unRegisterDialogBar BStools;destroyDialog BStools)
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
				str = "rollout rolloutClasses \"脚本类别\"(\r\n"
				case of
				(
					(mod arrDir.count 2 == 0):
					(
						for num = 1 to arrDir.count/2 do 
						(				
							local n = (2 * num) - 1
							str += "button " + nameBtn + n as string + " \"" + arrName[n] + "\" pos:("+ posBtn as string + "+ [0," + ((((n + 1)/2) - 1) * heightBtn) as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[n] + tips + "\"" + "\r\n"
							str += "button " + nameBtn + (n + 1) as string + " \"" + arrName[(n + 1)] + "\" pos:(" + posBtn as string + "+ [" + widthBtn as string + "," + ((((n + 1)/2) - 1) * heightBtn) as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[(n + 1)] + tips + "\"" + "\r\n"
						)
						for num = 1 to arrDir.count do
						(
							str += "on btnClass" + (num as string) + " pressed do (\r\n iniClassIn = " + (num as string) + "\r\n" + "SetINISetting BulletConfig \"GlobalSet\"  \"ClassPressed\" \"" + (num as string) + "\"\r\n fnRefreshScripts nameArrClass[iniClassIn]\r\n)\r\n"
							str += "on btnClass" + (num as string) + " rightclick do (\r\n shellLaunch \"explorer.exe\" (@\"" + arrDir[num] + "\")\r\n)\r\n"
						)
						str += ")"
					)
					(mod arrDir.count 2 == 1):
					(
						for num = 1 to arrDir.count/2 do 
						(				
							local n = (2 * num) - 1
							str += "button " + nameBtn + n as string + " \"" + arrName[n] + "\" pos:("+ posBtn as string + "+ [0," + ((((n + 1)/2) - 1) * heightBtn) as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[n] + tips + "\"" + "\r\n"
							str += "button " + nameBtn + (n + 1) as string + " \"" + arrName[(n + 1)] + "\" pos:(" + posBtn as string + "+ [" + widthBtn as string + "," + ((((n + 1)/2) - 1) * heightBtn) as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[(n + 1)] + tips + "\"" + "\r\n"
						)
						str += "button " + nameBtn + arrDir.count as string + " \"" + arrName[arrDir.count] + "\" pos:("+ posBtn as string + "+ [0," + (arrDir.count/2 * heightBtn) as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[arrDir.count] + tips + "\"" + "\r\n"
						str += "button " + nameBtn + (arrDir.count + 1) as string + " \"( 空 )\" pos:("+ posBtn as string + "+ [" + widthBtn as string + "," + (arrDir.count/2 * heightBtn) as string + "]) width: " + widthBtn as string + " height: " + (heightBtn as string) + " border:true toolTip: " + "\"( 空 )\"" + "\r\n"
						for num = 1 to arrDir.count do
						(
							str += "on btnClass" + (num as string) + " pressed do (\r\n iniClassIn = " + (num as string) + "\r\n" + "SetINISetting BulletConfig \"GlobalSet\"  \"ClassPressed\" \"" + (num as string) + "\"\r\n fnRefreshScripts nameArrClass[iniClassIn]\r\n)\r\n"
							str += "on btnClass" + (num as string) + " rightclick do (\r\n shellLaunch \"explorer.exe\" (@\"" + arrDir[num] + "\")\r\n)\r\n"
						)
						str += ")"
					)
				)
			)
			(nameBtn == "btnScripts"): 
			(
				str = "rollout rolloutScripts \"" + nameArrClass[iniClassIn] + "\"(\r\n"
				
				for num = 1 to arrDir.count do
				(
					str += "button " + nameBtn + num as string + " \"" + arrName[num] + "\" pos:("+ posBtn as string + "+ [0," + ((num-1) * heightBtn)as string + "]) width: " + (widthBtn * 2) as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[num] + " (" + tips + ")\"" + "\r\n"
					str += "on btnScripts" + (num as string) + " pressed do (\r\n" + "FileIn (@\"" + arrDir[num] + "\")" + "\r\n)\r\n"
-- 					str += "on btnScripts" + (num as string) + " rightclick do (\r\n)\r\n"
				)
				str += ")"
			)
			(nameBtn == "btnTools"): 
			(
				str = "rollout rolloutTools \"小工具\"(\r\n"
				
				for num = 1 to arrDir.count do
				(
					str += "button " + nameBtn + num as string + " \"" + arrName[num] + "\" pos:("+ posBtn as string + "+ [0," + ((num-1) * heightBtn)as string + "]) width: " + (widthBtn * 2) as string + " height: " + (heightBtn as string) + " border:true toolTip: \"" + arrName[num] + " (" + tips + ")\"" + "\r\n"
					str += "on btnTools" + (num as string) + " pressed do (\r\n" + "FileIn (@\"" + arrDir[num] + "\")" + "\r\n)\r\n"
-- 					str += "on btnScripts" + (num as string) + " rightclick do (\r\n)\r\n"
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
		if (doesfileexist pathLitScripts == true) then
		(
			deleteFile pathLitScripts
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
		
		if (shellLaunch "explorer.exe" (getDir #scripts)) then
		(
			messagebox "BulletTools工具已删除卸载,\r\n\r\n重新安装需要原mzp拖入...\r\n\r\n也可能由于权限原因,\r\n\r\n需手动删除打开窗口下的\r\n\r\n\"BulletS\"和\"BulletScripts\"文件夹~\r\n\r\n"
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
	try (removeSubRollout BStools.BStoolsMain rolloutClasses) catch()

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
		AddSubRollout BStools.BStoolsMain rolloutClasses
		case of
		(
			(arrClass.count <= 2):(BStools.BStoolsMain.height = (2 * heightBtn + 10))
			default:
			(
				case of
				(	
					(((arrClass.count/2) <= 5) and (mod (arrClass.count/2) 2) == 0):
					(
						BStools.BStoolsMain.height = ((arrClass.count/2 + 1) * heightBtn + 10)
					)
					(((arrClass.count/2) <= 5) and (mod (arrClass.count/2) 2) == 1):
					(
						BStools.BStoolsMain.height = ((arrClass.count/2 + 2) * heightBtn + 10)
					)
					((arrClass.count/2) > 5):
					(
						BStools.BStoolsMain.height = (6 * heightBtn + 10)
					)
				)
			)
		)
		BStools.BStoolsMain.width = 129
		BStools.BStoolsMain.pos = [12,95]  --根据groSettings位置得出
		BStools.BStoolsScripts.pos = BStools.BStoolsMain.pos + [0,(BStools.BStoolsMain.height + 10)]
		BStools.BStoolsTool.pos = BStools.BStoolsScripts.pos + [0,(BStools.BStoolsScripts.height +10)]
		BStools.BStoolsLit.pos = BStools.BStoolsTool.pos + [0,(BStools.BStoolsTool.height + 10)]
		if iniStyle == 0 then BStools.height = 134 + BStools.BStoolsMain.height + BStools.BStoolsScripts.height + BStools.BStoolsTool.height + BStools.BStoolsLit.height
	)
)
fn fnRefreshScripts pressedClass =  --刷新脚本列表按钮
(
	try (removeSubRollout BStools.BStoolsScripts rolloutScripts) catch()

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
				AddSubRollout BStools.BStoolsScripts rolloutScripts
				case of
				(
					(arrScripts.count <= 8):
					(
						BStools.BStoolsScripts.height = ((arrScripts.count + 1) * heightBtn + 10)
					)
					(arrScripts.count > 8):
					(
						BStools.BStoolsScripts.height = (9 * heightBtn + 10)
					)
				)
				BStools.BStoolsScripts.width = 129
				BStools.BStoolsScripts.pos = BStools.BStoolsMain.pos + [0,(BStools.BStoolsMain.height + 10)]
				BStools.BStoolsTool.pos = BStools.BStoolsScripts.pos + [0,(BStools.BStoolsScripts.height +10)]
				BStools.BStoolsLit.pos = BStools.BStoolsTool.pos + [0,(BStools.BStoolsTool.height + 10)]
				if iniStyle == 0 then BStools.height = 134 + BStools.BStoolsMain.height + BStools.BStoolsScripts.height + BStools.BStoolsTool.height + BStools.BStoolsLit.height
			)
			(arrScripts[1] == undefined):
			(
				str = "rollout rolloutScripts \"脚本列表\" \r\n(\r\n	label labelTipsScripts \"   ( 空 )   \" align:#center \r\n\r\n)"
				
				rolloutScripts = (execute str)
				AddSubRollout BStools.BStoolsScripts rolloutScripts
				BStools.BStoolsScripts.width = 129
				BStools.BStoolsScripts.height = (2 * heightBtn + 10)
				BStools.BStoolsScripts.pos = BStools.BStoolsMain.pos + [0,(BStools.BStoolsMain.height + 10)]
				BStools.BStoolsTool.pos = BStools.BStoolsScripts.pos + [0,(BStools.BStoolsScripts.height +10)]
				BStools.BStoolsLit.pos = BStools.BStoolsTool.pos + [0,(BStools.BStoolsTool.height + 10)]
				if iniStyle == 0 then BStools.height = 134 + BStools.BStoolsMain.height + BStools.BStoolsScripts.height + BStools.BStoolsTool.height + BStools.BStoolsLit.height
			)
		)
	)
)
fn fnRefreshTools =  --刷新小工具
(
	try (removeSubRollout BStools.BStoolsTool rolloutTools) catch()
	
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
		AddSubRollout BStools.BStoolsTool rolloutTools
		case of
		(
			(arrTools.count <= 10):
			(
				BStools.BStoolsTool.height = ((arrTools.count + 1) * heightBtn + 10)
			)
			(arrTools.count > 10):
			(
				BStools.BStoolsTool.height = (11 * heightBtn + 10)
			)
		)
		BStools.BStoolsTool.width = 129
		BStools.BStoolsTool.pos = BStools.BStoolsScripts.pos + [0,(BStools.BStoolsScripts.height +10)]
		BStools.BStoolsLit.pos = BStools.BStoolsTool.pos + [0,(BStools.BStoolsTool.height + 10)]
		if iniStyle == 0 then BStools.height = 134 + BStools.BStoolsMain.height + BStools.BStoolsScripts.height + BStools.BStoolsTool.height + BStools.BStoolsLit.height
	)
)

fn fnRefreshRolLit =
(
	if BStools.BStoolsLit.rollouts.count != 0 then
	(
		removeSubRollout BStools.BStoolsLit rolloutLit
	)
	addSubRollout BStools.BStoolsLit rolloutLit 
	BStools.BStoolsLit.width = 129
	BStools.BStoolsLit.height = 155
	BStools.BStoolsLit.pos = BStools.BStoolsTool.pos + [0,(BStools.BStoolsTool.height + 10)]
	if iniStyle == 0 then BStools.height = 134 + BStools.BStoolsMain.height + BStools.BStoolsScripts.height + BStools.BStoolsTool.height + BStools.BStoolsLit.height
)

fn fnRefreshList =  ------------更新脚本列表
(
	fnRefreshClass rolloutClasses
	fnRefreshScripts nameArrClass[iniClassIn]
	fnRefreshTools ()
	fnRefreshRolLit ()
)

rcmenu menuBStoolsSetting --设置菜单
(	
	menuItem menufnResize "恢复默认高度"
	menuItem menuCustom "自定脚本文件夹"
	menuItem menuUpdate "更新脚本列表"
	menuItem menuNoAutorun "解除脚本自启"
	menuItem menuAutorun "打开脚本自启"
	menuItem menuClose "关闭工具"
	separator menuSep01
	menuItem menuLink "更新地址"
	menuItem menuBlog "个人网站"
	separator menuSep02
	menuItem menuUninst "卸载 [ 请慎重 ! ]"
	
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
		shellLaunch "explorer.exe" pathScripts
	)
	on menuNoAutorun picked do  --打开自定脚本目录
	(
		if (doesfileexist ((getDir #StartupScripts) + "\\BulletTools.ms") == true) then
		(
			setFileAttribute ((getDir #StartupScripts) + "\\BulletTools.ms") #readOnly false
			deleteFile ((getDir #StartupScripts) + "\\BulletTools.ms")
			messagebox "------------------------------------------\r\n脚本自启已解除,\r\n但仍可点击工具栏按钮打开~\r\n\r\n"
		)
		else messagebox "-----------------------------------------\r\n已是非自启状态,无需再次操作~\r\n可点击\"打开自启\"选项打开自启~\r\n\r\n"
	)
	on menuAutorun picked do  --打开自定脚本目录
	(
		if (doesfileexist ((getDir #StartupScripts) + "\\BulletTools.ms") == false) then
		(
			copyFile ((getDir #Scripts)+"\\BulletTools.ms") ((getDir #startupScripts)+"\\BulletTools.ms")
			messagebox "-----------------------------------------\r\n脚本自启已打开,请安心享用~\r\n\r\n"
		)
		else messagebox "-----------------------------------------\r\n已是自启状态,无需再次操作~\r\n可点击\"解除自启\"选项解除自启\r\n\r\n"
	)
	on menuUpdate picked do  --更新脚本列表
	(
		fnRefreshList ()
	)
	on menufnResize picked do  --重置为初始宽高
	(
		fn fnResize =
		(
			iniSize = [rolWidth,rolHeight]
			BStools.width = rolWidth
			BStools.height = rolHeight
		)
		Local styleTemp
		if (iniStyle == 0) then
		(
			fnResize ()
		)
		else
		(
			styleTemp = cui.getDockState BStools
			cui.unRegisterDialogBar BStools
			fnResize ()
			cui.RegisterDialogBar BStools maxSize:[rolWidth,rolHeight]
			cui.DockDialogBar BStools styleTemp
		)
		SetINISetting BulletConfig "GlobalSet"  "Size" (iniSize as string)
	)
	on menuLink picked do  --左键点击跳转链接
	(
		shellLaunch "https://www.cgjoy.com/forum.php?mod=viewthread&tid=224775" ""
	)
	on menuBlog picked do  --左键点击跳转链接
	(
		shellLaunch "https://acebullet.tk" ""
	)
)

rollout BStools ("BsTools" + ver) width:rolWidth height:iniSize[2]
(		
	groupBox groSettings "" pos:[11,5] width:(BStools.width - 20) height:82
	button btnUnDock "UnDock" pos:[groSettings.width/2 - 3,20] width:30 height:25 border:false toolTip:"窗口浮动"
	button btnDockL "DockL" pos:[btnUnDock.pos[1] - 40,20] width:30 height:25 border:false toolTip:"左嵌入" 
	button btnDockR "DockR" pos:[btnUnDock.pos[1] + 40,20] width:30 height:25 border:false toolTip:"右嵌入"
	HyperLink lnkBlog "[Author:Bullet.S]" pos:[btnUnDock.pos[1] - 25,48] width:BStools.width color:(color 46 139 87) hovercolor:(color 255 0 255) visitedcolor:(color 46 139 87) address:"https://acebullet.tk/"
	HyperLink lnkSetting "[右键此处设置]" pos:[btnUnDock.pos[1] - 25,65] width:BStools.width color:(color 46 139 87) hovercolor:(color 255 0 255) visitedcolor:(color 46 139 87) address:"https://space.bilibili.com/2031113"

	subrollout BStoolsMain ""
	subrollout BStoolsScripts ""
	subrollout BStoolsTool ""
	subrollout BStoolsLit ""
	
	fn fnRefreshIcons = --更新按钮图标,调用系统ui位图...
	(
		Local theBmp
		
		theBmp = "bip_mfltrans_i.bmp" 
		btnDockL.images = #(theBmp,theBmp,26,11,11,12,12,false,true)
		btnDockR.images = #(theBmp,theBmp,26,13,13,14,14,false,true)
		theBmp = "bip_ikkey_i.bmp"
		btnUnDock.images = #(theBmp,theBmp,8,1,1,2,2,false,true)
	)
	
	fn fnUiStyle iniStyle = --判断停靠位置方法
	(
		iniSize = (GetDialogSize BStools)
		SetINISetting BulletConfig "GlobalSet"  "Size" (iniSize as string)
		case of 
		(
			(iniStyle == 1):(
								cui.RegisterDialogBar BStools  maxSize:[rolWidth,rolHeight]
								groSettings.caption = ("BsTools" + ver) --修改Group的显示名称
								cui.DockDialogBar BStools #cui_dock_left  --切换工具嵌入浮动位置和大小等
								btnDockL.enabled = false;btnUnDock.enabled = true;btnDockR.enabled = true)  --修改按钮禁用启用
			(iniStyle == 2):(
								cui.RegisterDialogBar BStools  maxSize:[rolWidth,rolHeight]
								groSettings.caption = ("BsTools" + ver)  --修改Group的显示名称
								cui.DockDialogBar BStools #cui_dock_right  --切换工具嵌入浮动位置和大小等
								btnDockL.enabled = true;btnUnDock.enabled = true;btnDockR.enabled = false)  --修改按钮禁用启用
			(iniStyle == 0):(	
								cui.unRegisterDialogBar BStools
								groSettings.caption = "<-... ..- .-.. .-.. . - ...>"  --修改Group的显示名称
								BStools.width = rolWidth;BStools.height = iniSize[2]  --切换工具嵌入浮动位置和大小等
								btnDockL.enabled = true;btnUnDock.enabled = false;btnDockR.enabled = true)  --修改按钮禁用启用
		)
		fnSetConfig ()
	)

	on BStools open do -- 打开加载停靠位置,0=浮动,1=左,2=右
	(
-- 		posBtn = [3,5]
		fnRefreshIcons ()
		fnRefreshList ()
		fnSaveConfig ()
		cui.RegisterDialogBar BStools  maxSize:[rolWidth,rolHeight]
		fnUiStyle iniStyle
	)
	on BStools close do -- 关闭记忆浮动窗口位置
	(
		if iniStyle == 0 then iniPos = (GetDialogPos BStools)
		iniSize = (GetDialogSize BStools)
		fnSetConfig ()
	)

	on btnDockL pressed do 
	(
		iniPos = (GetDialogPos BStools)
-- 		posBtn = [3,5]
		if btnDockR.enabled == false then cui.unRegisterDialogBar BStools
		BStools.height = rolHeight
		BStools.width = rolWidth
		fnUiStyle 1;iniStyle = 1
		fnRefreshList ()
	)  --停靠左边

	on btnDockR pressed do 
	(
		iniPos = (GetDialogPos BStools)
-- 		posBtn = [3,5]
		if btnDockL.enabled == false then cui.unRegisterDialogBar BStools
		BStools.height = rolHeight
		BStools.width = rolWidth
		fnUiStyle 2;iniStyle = 2
		fnRefreshList ()
	)  --停靠右边

	on btnUnDock pressed do 
	(
-- 		posBtn = [3,5]
		fnUiStyle 0;iniStyle = 0
		BStools.width = rolWidth
		BStools.height = 134 + BStools.BStoolsMain.height + BStools.BStoolsScripts.height + BStools.BStoolsTool.height + BStools.BStoolsLit.height
		fnRefreshList ()
	)  --浮动

	on lnkSetting rightClick do popupMenu menuBStoolsSetting  --弹出设置菜单
	on lnkBlog rightClick do popupMenu menuBStoolsSetting  --弹出设置菜单
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
			fnRefreshScripts nameArrClass[iniClassIn]
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

rcmenu menuSetSpeed
(
	menuItem menuCurrentSpeed "" enabled:false
	menuItem menuSet14Speed "-- 1/4x --"
	menuItem menuSet12Speed "-- 1/2x --"
	separator menuSepSpeedLow
	menuItem menuSet1Speed "--  1x  --"
	separator menuSepSpeedHigh
	menuItem menuSet2Speed "--  2x  --"
	menuItem menuSet4Speed "--  4x  --"

	on menuSetSpeed open do 
	(
		judgePlaySpeedValue ()
		menuSetSpeed.menuCurrentSpeed.text = "当前: " + valuePlaySpeed
	)

	on menuSet14Speed picked do 
	(
		fnSetSpeed 1
	)
	on menuSet12Speed picked do
	(
		fnSetSpeed 2
	)
	on menuSet1Speed picked do 
	(
		fnSetSpeed 3
	)
	on menuSet2Speed picked do 
	(
		fnSetSpeed 4
	)
	on menuSet4Speed picked do 
	(
		fnSetSpeed 5
	)
)

rcmenu menuSetFps
(
	menuItem menuCurrentFps "" enabled:false
	menuItem menuSet60Fps "-- 60 Fps --"
	menuItem menuSet30Fps "-- 30 Fps --"
	menuItem menuSet24Fps "-- 24 Fps --"
	separator menuSepCustom
	menuItem menuCustomFps "自定义帧率"

	on menuSetFps open do 
	(
		menuSetFps.menuCurrentFps.text = "当前帧率: " + framerate as string + " FPS"
	)

	on menuSet60Fps picked do 
	(
		fnSetFps 60
	)
	on menuSet30Fps picked do
	(
		fnSetFps 30
	)
	on menuSet24Fps picked do 
	(
		fnSetFps 24
	)

	on menuCustomFps picked do
	(
		try (destroyDialog rolCustomFps) catch()
		createdialog rolCustomFps 120 55 fgcolor:(color 255 20 147)
	)
)

rollout rolloutLit "快捷操作"
(
	local btnTipsSize = 26
	local btnPos
	local strCurrentFps = "当前帧率: " + framerate as string + " FPS"

	fn fnRolLitBtnPos numL numB =
	(
		btnPos = [(6 + (26 * (numL - 1))),(20 + (26 * (numB - 1)))]
	)

	HyperLink lnkTips "( 右键图标功能提示 )" pos:[3,3] width:BStools.width color:(color 255 20 147) hovercolor:(color 255 0 255) visitedcolor:(color 255 20 147) address:"https://space.bilibili.com/2031113"
	
	button btnReset " " pos:(fnRolLitBtnPos 1 1) width:btnTipsSize height:btnTipsSize \
	toolTip:"静默重置场景"
	button btnTipsIsolate "" pos:(fnRolLitBtnPos 2 1)  width:btnTipsSize height:btnTipsSize \
	toolTip:"蒙皮时左键编辑模型,\r\n右键隐藏选择面,\r\n已隐藏则显示全部元素"
	button btnSetFps " " pos:(fnRolLitBtnPos 3 1) width:btnTipsSize height:btnTipsSize \
	toolTip:"设置帧率"
	button btnSetPlaySpeed " " pos:(fnRolLitBtnPos 4 1) width:btnTipsSize height:btnTipsSize \
	toolTip:"设置播放速度"
	button btnTips4 " " pos:(fnRolLitBtnPos 1 2) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips5 " " pos:(fnRolLitBtnPos 2 2) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips6 " " pos:(fnRolLitBtnPos 3 2) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips7 " " pos:(fnRolLitBtnPos 4 2) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips8 " " pos:(fnRolLitBtnPos 1 3) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips9 " " pos:(fnRolLitBtnPos 2 3) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips10 " " pos:(fnRolLitBtnPos 3 3) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips11 " " pos:(fnRolLitBtnPos 4 3) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips12 " " pos:(fnRolLitBtnPos 1 4) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips13 " " pos:(fnRolLitBtnPos 2 4) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips14 " " pos:(fnRolLitBtnPos 3 4) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips15 " " pos:(fnRolLitBtnPos 4 4) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips16 " " pos:(fnRolLitBtnPos 1 5) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips17 " " pos:(fnRolLitBtnPos 2 5) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips18 " " pos:(fnRolLitBtnPos 3 5) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips19 " " pos:(fnRolLitBtnPos 4 5) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips20 " " pos:(fnRolLitBtnPos 1 6) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips21 " " pos:(fnRolLitBtnPos 2 6) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips22 " " pos:(fnRolLitBtnPos 3 6) width:btnTipsSize height:btnTipsSize toolTip:" "
	button btnTips23 " " pos:(fnRolLitBtnPos 4 6) width:btnTipsSize height:btnTipsSize toolTip:" "
	
	on rolloutLit open do ----------------给按钮附加图片
	(
		btnReset.images = #("UVWUnwrapModes_24i.bmp","UVWUnwrapModes_24i.bmp",28,3,3,3,3,true,false)
		btnTipsIsolate.images = #("UVWUnwrapView_24i.bmp","UVWUnwrapView_24i.bmp",27,15,15,15,15,true,false) 
		btnSetFps.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,19,19,19,19,true,true) 
		btnSetPlaySpeed.images = #("VCRControls_24i.bmp","VCRControls_24i.bmp",28,11,11,11,11,true,true) 
	)

	on lnkTips rightClick do popupMenu menuBStoolsSetting  --弹出设置菜单
	
	on btnReset pressed do (resetMaxFile #noPrompt;max tool maximize)  --静默重置场景

	on btnReset rightClick do (messagebox "---------------------------------------\r\n静默重置场景并最大化view, \r\n方便快速打开其他文件, \r\n不带之前材质球等多余配置, \r\n且没有重置提示~强烈推荐!")

	on btnTipsIsolate pressed do 
	(
		local objSelTemp
		if (selection.count == 1) and (classof $ != undefined) then
		(
			objSelTemp = $
			if (classof objSelTemp == Editable_Poly) then
			(
				modPanel.setCurrentObject objSelTemp
				subobjectLevel = 5
			)
			else
			(
				messagebox "------------------------------------\r\n仅支持 Editable_Poly 模型~"
			)
		)
	)
	on btnTipsIsolate rightclick do 
	(
		local objSelTemp
		if (selection.count == 1) and (classof $ != undefined) then
		(
			objSelTemp = $
			if (classof objSelTemp == Editable_Poly) then
			(
				if ((polyop.getHiddenFaces $) as array).count == 0 then
				(
					subobjectLevel = 0
				)
				else
				(
					modPanel.setCurrentObject objSelTemp
					subobjectLevel = 5
					objSelTemp.unhideAll #Face
					subobjectLevel = 0
				)
			)
			else
			(
				messagebox "------------------------------------\r\n仅支持 Editable_Poly 模型~"
			)
		)
	)

	on btnSetFps pressed do 
	(
		popupMenu menuSetFps
	)

	on btnSetPlaySpeed pressed do 
	(
		popupMenu menuSetSpeed
	)
)
CreateDialog BStools pos:iniPos style:#(#style_titlebar)
------------------- 创建子卷轴栏和按钮等等UI -------------------------------------------
fnRefreshClass rolloutClasses
fnRefreshScripts nameArrClass[iniClassIn]
fnRefreshTools ()
fnRefreshRolLit ()
clearListener()  --清空监听器