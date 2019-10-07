struct mseEncrypter
(
	fn encryptScripts msFile: vers:1 =
	(
		local myFile 
		if msFile!=unsupplied do
		(
			local myFile = (getFilenamePath msFile)+"\\"+(getFilenameFile msFile)+".mse"
			if not (doesFileExist myFile) do
			(
				encryptscript msFile version:vers
			)
		)
		myFile
	),

	fn encryptThisScript msArray:#() useDestFolder:false version:1 =
	(
		fn checkFolder file: =
		(
			local myFolder = getFilenamePath file 
			local newFolder = myFolder + "\\Encrypted"
			
			if not (doesFileExist newFolder) do (makeDir newFolder)
			newFolder
		)
		
		case of 
		(
			(version >=1 and classOf version==integer) : (version=1)
			(version <=0 and classOf version==integer) : (version=0)
		)

		if msArray.count!=0 do
		(	
			clearlistener()
			for i in msArray do
			(
				case useDestFolder of
				(
					true : ( 
								local myNewFolder = checkFolder file:i 
								local myEncScript = this.encryptScripts msFile:i vers:version --filename 
								local mynewScr= filenameFromPath myEncScript
								local newFile= (myNewFolder+"\\"+mynewScr) 
								copyFile myEncScript newFile
								deleteFile myEncScript
								format "New encrypted file : %\n" newFile
							)
					
					false : (
								local myEncScript = this.encryptScripts msFile:i vers:version
								format "New encrypted file : %\n" myEncScript
							 )
				)
			)
			
		)
		
	),

	fn getOpenFileNames InitialDirectory:undefined multiselect:true titles:"Select" =
	(
	theFolder= getFilenamePath  ((dotNetClass "System.Environment").GetEnvironmentVariable "ProgramFiles")
	if InitialDirectory==undefined or InitialDirectory==unsupplied do InitialDirectory=theFolder
	imageFilter= "Script file (*.ms)|*.ms"	
	theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
	theDialog.title = titles --set the title
	theDialog.Multiselect=multiselect
		
	theDialog.Filter = imageFilter 
	theDialog.FilterIndex = 1
	result = theDialog.showDialog()

	result.ToString() 
	result.Equals result.OK
	result.Equals result.Cancel
	if theDialog.fileNames.count !=0 then theFilenames = theDialog.fileNames else return undefined
	),
	
	fn joinArrayFiles ctrls: sArray:#() dArr:#() freeit:false =
	(
		if ctrls!=unsupplied do
		(
			if sArray.count!=0 do
			(
				if freeit == true do (free dArr)
				join dArr sArray
				local bb= for i in dArr collect (filenameFromPath i)
					
				if bb.count!=0 do
				(
					if bb.count==1 then
						(
							ctrls.text=bb[1] as string	
						)
					else
						(
							ctrls.text= (trimright (trimLeft (bb as string) "#(" ) ")")	
						)
				)
			)
		)
	)
)


try (destroydialog scriptEnc) catch()
global scEn=mseEncrypter()

rollout scriptEnc "MSE Maker" width:227 height:63
(
	local ver=1
	local allFiles=#()
	
	edittext edt_file "" pos:[-2,8] width:203 height:17 readOnly:true
	button btn_selFile "..." pos:[203,7] width:20 height:20 toolTip:"Click: Select *.ms file\n+Right Click: Append another files"
	radiobuttons rdo_Ver "" pos:[4,41] width:86 height:16 labels:#("1", "0") default:1 columns:2
	button btn_Enc "Encrypt" pos:[134,33] width:90 height:26  toolTip:"Start encrypting the file" enabled:false
	groupBox grp1 "Version" pos:[1,27] width:105 height:32
	checkButton ckb_newFolder "NF" pos:[107,33] width:26 height:26 enabled:false checked:true toolTip:"Move encrypted to new folder or not !" 
		
	on btn_selFile pressed do
	(
		arrFile = scEn.getOpenFileNames InitialDirectory:undefined multiselect:true titles:"Select maxscript files"
		if arrFile!=undefined do 
			(
				btn_Enc.enabled=ckb_newFolder.enabled=true
				scEn.joinArrayFiles ctrls:edt_file sArray:arrFile dArr:allFiles freeit:true
			)
	)
	
	on btn_selFile rightclick  do
	(
		if (edt_file.text!="" ) do
		(
		local myNewArr = scEn.getOpenFileNames InitialDirectory:undefined multiselect:true titles:"Add another maxscript files"
		if myNewArr!=undefined do (scEn.joinArrayFiles ctrls:edt_file sArray:myNewArr dArr:allFiles freeit:false)
		)
	)
	
	on rdo_Ver changed state do
	(
		case state of 
		(
			1: (ver=1)
			2: (ver=0)
			default : (ver=1)
		)
	)
	
	on btn_Enc pressed do
	(
		if allFiles.count!=0 then
		(
			scEn.encryptThisScript msArray:allFiles useDestFolder:ckb_newFolder.state version:ver
		)
		else
		(
			messageBox "Nothing to encrypt !!" title:"3dsMax"
		)
	)
)
createDialog scriptEnc style:#(#style_toolwindow,#style_sysmenu)
