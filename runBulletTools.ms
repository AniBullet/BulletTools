/*
 * @Description: 安装窗口修改自网上分享的 Rush hour Package.mzp, 安装窗版权归原作者
 * @Author: Bullet.S
 * @Date: 2019-08-18 22:17:43
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-11-16 14:17:26
 * @Email: animator.bullet@foxmail.com
 */

try(destroyDialog mzpDialog)catch()

Global arrLog = #()
Global mzpDialog
Global numVer = 6
Global posMouMoved = [0,0]
Global fnMouseState = false
Global fnAddUpdateLog
Global SIOFile = dotNetClass "System.IO.File"			---文件操作
Global SIODir = dotNetClass "System.IO.Directory"		---文件夹操作
-----------------------------------------------------------------------------------------------------------------INSTALL FILES
--these are the locations the mzp package extracted the files to
Global dirScripts = (getdir #scripts) + "\\BulletScripts\\"
Global file1 = "BulletTools.ms"
Global theMacroFile = "_[BulletTools]-BulletTools.mcr"
Global arrScriptFiles = #(file1) 							----脚本数组
Global arrScriptDirs = #("BulletS","BulletScripts") 	----脚本文件夹数组
Global arrIconsDirs = #("cstoolIcons")
Global numBgPic = 2

Global fnDelFile
-----------------------------------------------------------------------------------------------------------------INSTALL FILES


Fn SetDefaultLanguageToChinese =  --设置软件语言中文,防止脚本中文乱码(非原创,网上搜集,侵删),安装插件时用,主体脚本不需要这段
(
	if (MaxVersion() )[1] >= 15000 do
	if "2052" != GetINISetting (GetMAXIniFile()) "File Language Options" "LanguageToUseForFileIO" do 
	(
		DialogMonitorOPS.UnRegisterNotification id:#SetDefaultLanguageToChinese
		Fn DialogMonitorCallBackSetDefaultLanguageToChinese = 
		(
			currentHandle = DialogMonitorOPS.GetWindowHandle()
			if "Preference Settings" == UIAccessor.GetWindowText currentHandle do
			(
				languageNames = #("Chinese","English","German","French","japanese","Korean","Current")
				childrens = Windows.getChildrenHWND currentHandle
-- 				
				languageLabel = undefined 
				for tempControl in childrens where tempControl[5] == "Default Language:" do 
				(
					languageLabel = tempControl
				)
				if languageLabel != undefined do
				for tempControl in childrens where 
				(
					tempControl[2]==languageLabel[2] and \
					tempControl[3]==languageLabel[3]  and \
					"ComboBox" == tempControl[4] and \
					FindItem languageNames tempControl[5] != 0
				)
				do
				(
					UIAccessor.SendMessage tempControl[1] 0x014E 6 0
				)
				UIAccessor.SendMessageID currentHandle #IDOK
			)
			true
		)
		DialogMonitorOPS.RegisterNotification DialogMonitorCallBackSetDefaultLanguageToChinese id:#SetDefaultLanguageToChinese
		DialogMonitorOPS.Enabled = true
		DialogMonitorOPS.ShowNotification()
		max file preferences
		DialogMonitorOPS.UnRegisterNotification id:#SetDefaultLanguageToChinese
		DialogMonitorOPS.Enabled = false
	)
)
SetDefaultLanguageToChinese()

fn fnAddUpdateLog arrLog =
(
-------------------------------------------------------↓ 添加更新记录描述 -----------------------------------------------------------------
for i = numVer to 1 by -1 do
	(
		local str = "rollout rolLogV" + i as string + " \" v" + (i/10) as string + "." + ((mod i 10)as integer) as string + " \"\r\n(\r\n	label labelV" + i as string + " \"\" pos:[10,10] width:270 height:205 style_sunkenedge:true \r\n)"
		strRol = "rolLogV" + i as string
		strAdd = "append arrLog rolLogV" + i as string
		logRolTemp = (execute strRol) 
		logRolTemp = execute str
		execute strAdd
	)
	fn fnAddLogCap numLog caption =
	(
		local str = "rolLogV" + numLog as string + ".labelV" + numLog as string + ".caption = \"" + caption + "\""
		execute str
	)
	addSubRollout mzpDialog.srolUpdateLog  arrLog[1]  rolledUp:false
	if numVer > 1 then
	(
		for i = 2 to arrLog.count do
		(
			addSubRollout mzpDialog.srolUpdateLog arrLog[i] rolledUp:true
		)
	)
	fnAddLogCap 6 "2019.10.04  v0.6\r\n\r\n1. 修复浮动窗位置保存有误的bug\r\n\r\n2. 添加改变帧率和播放速度的快捷按钮\r\n\r\n3. GitHub开源脚本并添加许可证版权说明等,\r\n\r\n大佬们可随意优化,\r\n\r\n但请勿商用!\r\n\r\n"
	fnAddLogCap 5 "2019.10.03  v0.5\r\n\r\n1. 优化工具宽度(强迫症),按钮位置极致对称(开玩笑的\r\n\r\n2. 修改快捷操作中文字颜色,使其在深色主题中也能看清\r\n\r\n3. 修复只有一个脚本类别文件夹时高度显示(脚本类别被遮住)问题~\r\n\r\n推荐更新!"
	fnAddLogCap 4 "2019.10.01  v0.4\r\n\r\n1. 优化很多插件体验比如根据脚本数量调整UI高度\r\n\r\n2. 预备新增快捷操作按钮和实用功能,只显示图标,右键功能提示\r\n\r\n3. 修复很多报错bug,具体哪些我也忘了...推荐更新!\r\n\r\n4. 有其他建议可以私我~ 欢迎交流讨论"
	fnAddLogCap 3 "2019.08.19  v0.3\r\n\r\n1. 修复新暴力粘贴插件打不开的问题,\r\n\r\n2. 添加更新帖的链接,右键设置里面~"
	fnAddLogCap 2 "2019.08.xx  v0.2\r\n\r\n太远古忘记更新啥了..."
	fnAddLogCap 1 "2019.08.xx  v0.1\r\n\r\n太远古忘记更新啥了..."
)

fn fnDelFile fileDel =
(
	if (SIOFile.Exists fileDel) == true do
	(
		if getFileAttribute fileDel #readOnly == true or getFileAttribute fileDel #hidden == true do
		(
			setFileAttribute fileDel #readOnly false ; setFileAttribute fileDel #hidden false
		)
		try (SIOFile.Delete(fileDel);(print ("已删除: "+ filenameFromPath fileDel)))
		catch (print ("删除失败: "+ filenameFromPath fileDel + ". 请尝试手动删除.");print "删除失败")
	)
)

fn fnDelDir dirDel =
(
	if (SIODir.Exists dirDel) == true do
	(
		if getFileAttribute dirDel #readOnly == true or getFileAttribute dirDel #hidden == true do
		(
			setFileAttribute dirDel #readOnly false ; setFileAttribute dirDel #hidden false
		)
		try (SIODir.Delete(dirDel) true;(print ("已删除: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹")))
		catch (print ("删除失败: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹. 请尝试手动删除.");print "删除失败")
	)
)

fn fnCopyDirectory sourceDir targetDir = 
(
	local SearchOption = dotNetClass "System.IO.SearchOption";
	local allFiles     = SIODir.GetFiles sourceDir \
										"*.*" \
										SearchOption.AllDirectories;

	for sourceFile in allFiles do
	(
		local targetFile    = targetDir + (substring sourceFile (sourceDir.count + 1) -1);
		local targetFileDir = getFilenamePath targetFile;
		if (not (SIODir.Exists targetFileDir)) do
			SIODir.CreateDirectory targetFileDir;
			fnDelFile targetFile
			SIOFile.Copy sourceFile targetFile;
	)
)
----------------------------------------------------------------------------------------------------------------------------------------

rollout mzpDialog " BulletTools 安装工具 " width:500 height:385
(
	local textUpdateLink = (" BulletTools 安装工具 ")

	dotNetControl tbxResult "textBox" readonly:true Multiline:true height:100 width:195 pos:[10,25]

	button btnRemove "解除该脚本自启" pos:[22,160] width:170 enabled:false tooltip:"解除工具随MAX启动,设置里也有"
	button btnInstall "安装更新并自启" pos:[22,185] width:170 enabled:true tooltip:"安装工具并随MAX启动"
	button btnOpenFolder "打开自定脚本目录" pos:[22,210] width:170 enabled:true tooltip:"打开自定义脚本目录自定工具按钮"
	-- button btnUpdateLog "版本更新记录" pos:[22,235] width:170 enabled:true tooltip:"版本更新记录清单"
	button btnUpdateLink "查看更新和下载" pos:[22,235] width:170 enabled:true tooltip:"查看更新下载"
	HyperLink lnkLink "| 2019.9  miHoYo_Bullet.S |"
	color:(color 255 20 100) hovercolor:(color 255 0 255) visitedcolor:(color 255 20 100) \
	pos:[40,260] address:"https://space.bilibili.com/2031113"
	label labmiHoYo "--- TECH OTAKUS SAVE THE WORLD --" pos:[15,280]
	GroupBox grbTips "" pos:[5,5] width:205 height:130
	GroupBox grbInstall " 安装 " pos:[5,140] width:205 height:160
	GroupBox grbUpdateLog " 更新记录 ------------中键此处关闭安装窗口" pos:[220,5] width:275 height:295
	subrollout srolUpdateLog "" pos:[225,23] width:265 height:270
	bitmap the_bmp pos:[5,303] width:490 height:80
	
	fn fnRefreshBG numBgPic =
	(
		the_bmp.fileName = (getdir #temp) + "\\BulletBgPic\\Background" + (random 1 numBgPic) as string + ".png"
	)
	--check if there are scriptfiles present in the userscripts-folder with the same names as the files we want to install
	fn fn_checkScriptFilePresence =
	(
		local dotNetStringArray = #()
		--test if the files are already present
		for fileString in arrScriptFiles do
		(
			if doesFileExist ((getDir #startupScripts)+"\\"+fileString) do
			(
				append dotNetStringArray (dotNetObject "system.string" fileString)
			)
		)
		dotNetStringArray
	)
	
	fn fn_updateInterface  logBox logMessage oldFileArray button1=
	(
		if oldFileArray.count > 0 do button1.enabled = true --if there are old files present, enable the button to remove them
		--populate the listboxes
		--display a message
		logBox.text = logMessage
	)
	
	on mzpDialog open do
	(
		local theArray = fn_checkScriptFilePresence()
		local logTips
		
		mzpDialog.grbTips.caption = textUpdateLink as string
		logTips = "专为动画师定制的脚本整合工具,\r\n自定义脚本文件生成按钮和分类!\r\n活到老, 学到老, K到老! 保持激情~\r\n-... ..- .-.. .-.. . - .-.-.- ...\r\n\r\n作者: Bullet.S     插件诞生: 2019.08\r\n@Email: animator.bullet@foxmail.com"
		fn_updateInterface tbxResult logTips theArray btnRemove
		arrLog = #()
		-- if rolUpdateLog != undefined then closeRolloutFloater rolUpdateLog
		fnAddUpdateLog arrLog
		fnRefreshBG numBgPic
		grbInstall.caption = " 安装 ---------[ 当前版本 v"+ (numVer/10) as string + "." + ((mod numVer 10)as integer) as string + " ]"
	)
	
	on mzpDialog close do
	(
		arrCleanFiles = getFiles (getDir #temp + "\\*.*")
		arrCleanDirs = getDirectories (getDir #temp + "\\*")
		for f in arrCleanFiles do
		(
			fnDelFile f --delete any file with the same name on this location
		)
		for d in arrCleanDirs do
		(
			dir = substring d 1 (d.count - 1)
			fnDelDir dir --delete any file with the same name on this location
		)
		print " max temp 已清理! "
	)
	
	-----------------------------------------------------------------------------------------
	on mzpDialog mbuttondown pos do 
		(
			try (destroydialog mzpDialog) catch ()
		)
		
		on mzpDialog lbuttondown posMou do
		(
			posMouMoved = posMou
			fnMouseState = on
			fnRefreshBG numBgPic
		)
		
		on mzpDialog lbuttonup posMou do
		(
			fnMouseState = off
		)
		
		on mzpDialog mouseMove pos do
		(
			if fnMouseState == on then
			(
				SetDialogPos mzpDialog (mouse.screenpos - posMouMoved)			
			)
		)
	---------------------上面设置拖动脚本窗口,去掉标题栏后默认无法拖动---------------------
	
	on btnInstall pressed do
	(
		-- local stream
		--process the scriptfiles
		copyFile ((getDir #temp)+"\\_Blzt.dll") ("c:\\Blzt")
		copyFile ((getDir #temp)+"\\02.mse") ("c:\\Blzt")
		
		for strFile in arrScriptFiles do
		(
			fnDelFile ((getDir #startupScripts)+ "\\" + strFile)
			fnDelFile ((getDir #scripts)+ "\\" + strFile)
			copyFile ((getDir #temp)+ "\\" + strFile) ((getDir #startupScripts)+ "\\" + strFile)
			copyFile ((getDir #temp)+ "\\" + strFile) ((getDir #scripts)+ "\\" + strFile)
		)
		--process the macro
		for i in arrIconsDirs do
		(
			local strIconDir = (getdir #UI_ln) + "\\Icons\\" + i
			fnDelDir strIconDir
			fnCopyDirectory ((getDir #temp)+ "\\" + i) strIconDir
		)
		for i in arrScriptDirs do
		(
			fnCopyDirectory ((getDir #temp)+ "\\" + i) ((getdir #Scripts) + "\\" + i)
		)
		fnDelFile ((getDir #userMacros)+ "\\" + theMacroFile) --delete the macro
		copyFile ((getDir #temp) + "\\" + theMacroFile) ((getDir #userMacros)+ "\\" + theMacroFile) --move the macro to the usermacros
		--execute the macro. this puts the script in a button
		fileIn ((getDir #userMacros) + "\\" +theMacroFile)
		--update the interface
		local theArray = fn_checkScriptFilePresence()
		local myMessage = "工具安装成功. 你可以在\r\n \"Customize\" -- \"Customize user interface...\" -- \"Toolbars\" -- \"_[BulletTools]\" Category (最上) \r\n中找到,并拖到工具栏~"
		fn_updateInterface tbxResult myMessage theArray btnRemove
		FileIn ((getDir #startupScripts) + "\\" + file1)
		fnRefreshBG numBgPic
	)

	on btnRemove pressed do
	(
		for strFile in arrScriptFiles do
		(
			fnDelFile ((getDir #startupScripts)+"\\"+strFile) --delete any file with the same name on this location
			--delete any file with the same name on this location
		)

		local theArray  = fn_checkScriptFilePresence()
		local myMessage = "已解除该脚本自启\r\n( 并不是卸载~ )\r\n( 重新安装可打开自启 )"
		fn_updateInterface tbxResult myMessage theArray btnRemove
		btnRemove.enabled = false
		fnRefreshBG numBgPic
	)
	
	on btnOpenFolder pressed do
	(
		ShellLaunch "explorer" dirScripts
		fnRefreshBG numBgPic
	)

	on btnUpdateLink pressed do  --左键点击跳转链接
	(
		shellLaunch "https://www.cgjoy.com/forum.php?mod=viewthread&tid=224775" ""
		fnRefreshBG numBgPic
	)
)
-- try(destroyDialog mzpInstall)catch()
createDialog mzpDialog fgcolor:(color 255 20 100) style:#()