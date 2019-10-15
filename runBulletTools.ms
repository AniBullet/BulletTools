/*
 * @Description: 安装窗口修改自网上分享的 Rush hour Package.mzp, 安装窗版权归原作者
 * @Author: Bullet.S
 * @Date: 2019-08-18 22:17:43
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-10-14 11:59:18
 * @Email: animator.bullet@foxmail.com
 */

try(destroyDialog mzpDialog)catch()

Global arrLog = #()
Global rolUpdateLog
Global mzpDialog
Global numVer = 6
Global createRolUpdate

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

fn createRolUpdate arrLog =
(
	local posMzpDialog = GetDialogPos mzpDialog

	if rolUpdateLog != undefined then closeRolloutFloater rolUpdateLog
	rolUpdateLog = newRolloutFloater "更新记录" 300 285
	rolUpdateLog.pos = (posMzpDialog + [218,0])
-------------------------------------------------------↓ 添加更新记录描述 -----------------------------------------------------------------
	for i = numVer to 1 by -1 do
	(
		local str = "rollout rolLogV" + i as string + " \" v" + (i/10) as string + "." + ((mod i 10)as integer) as string + " \"\r\n(\r\n	label labelV" + i as string + " \"\" pos:[10,10] width:270 height:222 style_sunkenedge:true \r\n)"
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
	addRollout arrLog[1] rolUpdateLog  rolledUp:false
	for i = 2 to arrLog.count do
	(
		addRollout arrLog[i] rolUpdateLog  rolledUp:true
	)
	fnAddLogCap 6 "2019.10.04  v0.6\r\n\r\n1. 修复浮动窗位置保存有误的bug\r\n\r\n2. 添加改变帧率和播放速度的快捷按钮\r\n\r\n"
	fnAddLogCap 5 "2019.10.03  v0.5\r\n\r\n1. 优化工具宽度(强迫症),按钮位置极致对称(开玩笑的\r\n\r\n2. 修改快捷操作中文字颜色,使其在深色主题中也能看清\r\n\r\n3. 修复只有一个脚本类别文件夹时高度显示(脚本类别被遮住)问题~\r\n\r\n推荐更新!"
	fnAddLogCap 4 "2019.10.01  v0.4\r\n\r\n1. 优化很多插件体验比如根据脚本数量调整UI高度\r\n\r\n2. 预备新增快捷操作按钮和实用功能,只显示图标,右键功能提示\r\n\r\n3. 修复很多报错bug,具体哪些我也忘了...推荐更新!\r\n\r\n4. 有其他建议可以私我~ 欢迎交流讨论"
	fnAddLogCap 3 "2019.08.19  v0.3\r\n\r\n1. 修复新暴力粘贴插件打不开的问题,\r\n\r\n2. 添加更新帖的链接,右键设置里面~"
	fnAddLogCap 2 "2019.08.xx  v0.2\r\n\r\n太远古忘记更新啥了..."
	fnAddLogCap 1 "2019.08.xx  v0.1\r\n\r\n太远古忘记更新啥了..."
----------------------------------------------------------------------------------------------------------------------------------------
)

rollout mzpDialog " BulletTools 安装工具 "
(
	local textUpdateLink = (" 说明 ------ [ 当前版本 v"+ (numVer/10) as string + "." + ((mod numVer 10)as integer) as string + " ]")

	dotNetControl tbxResult "textBox" readonly:true Multiline:true height:100 width:195 pos:[10,25]

	button btnRemove "解除该脚本自启" pos:[22,160] width:170 enabled:false tooltip:"解除工具随MAX启动,设置里也有"
	button btnInstall "安装更新并自启该脚本" pos:[22,185] width:170 enabled:true tooltip:"安装工具并随MAX启动"
	button btnOpenFolder "打开自定脚本目录" pos:[22,210] width:170 enabled:true tooltip:"打开自定义脚本目录自定工具按钮"
	button btnUpdateLog "版本更新记录" pos:[22,235] width:170 enabled:true tooltip:"版本更新记录清单"
	button btnUpdateLink "查看更新和下载" pos:[22,260] width:170 enabled:true tooltip:"查看更新下载"
	
	GroupBox grbTips "" pos:[5,5] width:205 height:130
	GroupBox grbInstall " 安装 " pos:[5,140] width:205 height:150
	
	-----------------------------------------------------------------------------------------------------------------INSTALL FILES
		--these are the locations the mzp package extracted the files to
		local file1 = "BulletTools.mse"
		local theMacroFile = "BulletTools.mcr"
		
		--the array of files which have to be moved, deleted or installed
		local myScriptFileArray = #(file1) --the scriptfiles which have to be copied
		local myTotalFileArray = #(file1,theMacroFile) --the scriptfiles including the macroscript
	-----------------------------------------------------------------------------------------------------------------INSTALL FILES
	
	
	--check if there are scriptfiles present in the userscripts-folder with the same names as the files we want to install
	fn fn_checkScriptFilePresence =
	(
		local dotNetStringArray = #()
		--test if the files are already present
		for fileString in myScriptFileArray do
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
		if rolUpdateLog != undefined then closeRolloutFloater rolUpdateLog
		createRolUpdate arrLog
	)
	
	on mzpDialog close do
	(
		--delete the files from a temp location, clean up
		for fileString in myScriptFileArray do
		(
			deleteFile ((getDir #temp)+"\\"+fileString) --delete any file with the same name on this location
		)
		deleteFile ((getDir #temp)+"\\"+theMacroFile) --delete the macro
		if rolUpdateLog != undefined then closeRolloutFloater rolUpdateLog ----更新记录跟随关闭
	)
	
	on btnInstall pressed do
	(
		--process the scriptfiles
		for fileString in myScriptFileArray do
		(
			deleteFile ((getDir #startupScripts)+"\\"+fileString) --delete any file with the same name on this location
			copyFile ((getDir #temp)+"\\"+fileString) ((getDir #startupScripts)+"\\"+fileString) --move the file to the userscripts
			deleteFile ((getDir #Scripts)+"\\"+fileString) --delete any file with the same name on this location
			copyFile ((getDir #temp)+"\\"+fileString) ((getDir #Scripts)+"\\"+fileString) --move the file to the userscripts
			copyFile ((getDir #temp)+"\\_Blzt.dll") ("c:\\Blzt")
		)
		--process the macro
		deleteFile ((getDir #userMacros)+"\\"+theMacroFile) --delete the macro
		copyFile ((getDir #temp)+"\\"+theMacroFile) ((getDir #userMacros)+"\\"+theMacroFile) --move the macro to the usermacros
		--execute the macro. this puts the script in a button
		fileIn ((getDir #userMacros)+"\\"+theMacroFile)
		--update the interface
		local theArray = fn_checkScriptFilePresence()
		local myMessage = "工具安装成功. 你可以在\r\n \"Customize\" -- \"Customize user interface...\" -- \"Toolbars\" -- \"_[BulletTools]\" Category (最上) \r\n中找到,并拖到工具栏~"
		fn_updateInterface tbxResult myMessage theArray btnRemove
		FileIn ((getDir #startupScripts) + "\\" + "BulletTools.mse")
	)

	on btnRemove pressed do
	(
		for fileString in myScriptFileArray do
		(
			deleteFile ((getDir #startupScripts)+"\\"+fileString) --delete any file with the same name on this location
		)

		local theArray = fn_checkScriptFilePresence()
		local myMessage = "已解除该脚本自启\r\n( 并不是卸载~ )\r\n( 设置中可开启自启 )"
		fn_updateInterface tbxResult myMessage theArray btnRemove
		btnRemove.enabled = false
	)
	
	on btnOpenFolder pressed do
	(
		makeDir ((getDir #scripts)+"\\BulletS")
		ShellLaunch "explorer" ((getDir #scripts)+"\\BulletS")
	)
	
	on btnUpdateLog pressed do  ----更新记录打开
	(
		arrLog = #()
		if rolUpdateLog != undefined then closeRolloutFloater rolUpdateLog
		createRolUpdate arrLog
	)
	
	on mzpDialog moved pos do  ----更新记录跟随移动
	(
		if rolUpdateLog != undefined then rolUpdateLog.pos = ((GetDialogPos mzpDialog) + [218,0])
	)

	on btnUpdateLink pressed do  --左键点击跳转链接
	(
		shellLaunch "https://www.cgjoy.com/forum.php?mod=viewthread&tid=224775" ""
	)
)
-- try(destroyDialog mzpInstall)catch()
createDialog mzpDialog 220 295