
try (	cui.unRegisterDialogBar cstoolroll1)catch()
try (	destroydialog cstoolroll1)catch()
rollout mergebip "MIX工具" width:294 height:157
(
	button btn14 "..." pos:[12,34] width:27 height:25
	button btn15 "按文件名顺序进行MIX合并" pos:[12,67] width:270 height:46 enabled:true toolTip:""
	editText edt2 "" pos:[41,36] width:237 height:23
	groupBox grp1 "MIX文件夹下所有的文件" pos:[6,9] width:284 height:121


on mergebip open do
(
)

on btn14 pressed do
(
  loadfilepath = getSavePath caption:"选择读取文件路径:"  initialDir:""
if loadfilepath!=undefined then edt2.text=loadfilepath 
)

on btn15 pressed do
(

loadfilepath=edt2.text
-- bip = biped.createNew 100 -90 [0,0,0] arms:true neckLinks:2 spineLinks:4 legLinks:4 \
-- tailLinks:1 ponyTail1Links:1 ponyTail2Links:1 fingers:5 fingerLinks:2 toes:4 toeLinks:2 ankleAttach:0.3 trianglePelvis:True  
 

if $sangum070816_Bip01==undefind then
      mergeMAXFile "$UI_ln\\ICONS\\cstoolIcons\\newbip.max"  #select

bip=$sangum070816_Bip01.controller

themixer.addMixerToDisplay $sangum070816_Bip01.transform.controller

mymixer = $sangum070816_Bip01.transform.controller.mixer

if mymixer.numTrackgroups<1 then appendTrackgroup  mymixer

mx1=getTrackgroup mymixer 1
 
mx2=getTrack mx1 1

theFiles = getFiles (loadfilepath+"\\*.bip") 

--对文件名进行排序--------------------------------------------
		for  i=1 to theFiles.count  do
		     for j=1 to theFiles.count do
			 (
			   if theFiles[i]< theFiles[j] then ( temp= theFiles[i]; theFiles[i]=theFiles[j];theFiles[j]=temp;)
			 ) 
---------------------------------------------------------------

bip.figureMode= false
        bip.mixerMode=true
		for f in theFiles do
			if f.count>18 then
			(
			  bipname=substring f (f.count-17) 18
			   if bipname!="cstools_mixall.bip" then  mx3=appendClip mx2 f  false 1f 
			   )
			   else
			   mx3=appendClip mx2 f  false 1f 

	   mixdown mymixer false true 0 true 0.0
	   copyMixdownToBiped  mymixer
	   bip.mixerMode=false
	   bipfile=loadfilepath+"\\"+"cstools_mixall.bip"
	   biped.saveBipfile bip bipfile
	   select  $sangum070816*
        actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
   )
)
rollout cstoolroll1 "CS工具" width:136 height:174
(
	local	Thepos1=[0,0]
	local mousedd1=false
	local zxshuzhi=0
	local image_leftFootA = openbitmap 	"$scripts\DTools\ui\\cstools\\leftfootA.bmp"
	local image_leftFootB = openbitmap "$scripts\DTools\ui\\cstools\\leftfootB.bmp"
	local image_leftFootC = openbitmap "$scripts\DTools\ui\\cstools\\leftfootC.bmp"
	local image_leftFootD = openbitmap "$scripts\DTools\ui\\cstools\\leftfootD.bmp"
	local image_leftFootA2 = openbitmap"$scripts\DTools\ui\\cstools\\leftfootA2.bmp"
	local image_leftFootB2 = openbitmap "$scripts\DTools\ui\\cstools\\leftfootB2.bmp"
	local image_leftFootC2 = openbitmap "$scripts\DTools\ui\\cstools\\leftfootC2.bmp"
	local image_leftFootD2 = openbitmap "$scripts\DTools\ui\\cstools\\leftfootD2.bmp"
	ImgTag leftfootA_btn "leftfoota" pos:[63,129] width:22 height:18 transparent:(color 0 255 0) bitmap:image_leftfootA
	ImgTag leftfootB_btn "leftfootb" pos:[63,147] width:22 height:15 transparent:(color 0 255 0) bitmap:image_leftfootB
	ImgTag leftfootC_btn "leftfootc" pos:[85,129] width:21 height:33 transparent:(color 0 255 0) bitmap:image_leftfootC
	ImgTag leftfootD_btn "leftfootd" pos:[106,129] width:15 height:33 transparent:(color 0 255 0) bitmap:image_leftfootD
	button savefile_btn "save" pos:[38,129] width:24 height:34 images:#("$scripts\DTools\ui\\cstools\\bip2_i.bmp", "$scripts\DTools\ui\\cstools\\bip2_a.bmp", 10, 3, 3, 4, 4) 
	button openfile_btn "open" pos:[13,129] width:24 height:34 images:#("$scripts\DTools\ui\\cstools\\bip2_i.bmp", "$scripts\DTools\ui\\cstools\\bip2_a.bmp", 10, 1, 1, 2, 2) 
	button key_btn "key" pos:[13,23] width:25 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_i.bmp", "$scripts\DTools\ui\\cstools\\bip_a.bmp", 8, 1, 1, 2, 2)toolTip:"设置关键帧"
	button plantedkey_btn "planted key" pos:[41,23] width:25 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_i.bmp", "$scripts\DTools\ui\\cstools\\bip_a.bmp", 8, 3, 3, 4, 4)toolTip:"设置踩踏关键帧"
	button sliderkey_btn "slider key" pos:[69,23] width:25 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_i.bmp", "$scripts\DTools\ui\\cstools\\bip_a.bmp", 8, 5, 5, 6, 6)toolTip:"设置滑动关键帧"
	button freekey_btn "free  key" pos:[97,23] width:25 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_i.bmp", "$scripts\DTools\ui\\cstools\\bip_a.bmp", 8, 7, 7, 8, 8)toolTip:"设置自由关键帧"
	checkbutton hori_btn "hoir" pos:[13,107] width:35 height:20 images:#("$scripts\DTools\ui\\cstools\\bip2_i.bmp", "$scripts\DTools\ui\\cstools\\bip2_a.bmp", 10, 5, 5, 6, 6)
	checkbutton vert_btn "vert" pos:[50,107] width:35 height:20 images:#("$scripts\DTools\ui\\cstools\\bip2_i.bmp", "$scripts\DTools\ui\\cstools\\bip2_a.bmp", 10, 7, 7, 8, 8)
	checkbutton rotate_btn "rotate" pos:[87,107] width:35 height:20 images:#("$scripts\DTools\ui\\cstools\\bip2_i.bmp", "$scripts\DTools\ui\\cstools\\bip2_a.bmp", 10, 9, 9, 10, 10)
	button newlayer_btn "newlayer" pos:[13,65] width:25 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_layer_i.bmp","$scripts\DTools\ui\\cstools\\bip_layer_a.bmp", 24, 5, 5, 6, 6)toolTip:"创建层"
	button deletelayer_btn "deletelayer" pos:[41,65] width:25 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_layer_i.bmp", "$scripts\DTools\ui\\cstools\\bip_layer_a.bmp", 24, 7, 7, 8, 8)toolTip:"删除层"
	button collapselayer_btn "collapselayer" pos:[69,65] width:25 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_layer_i.bmp", "$scripts\DTools\ui\\cstools\\bip_layer_a.bmp", 24, 13, 13, 14, 14)toolTip:"塌陷"
	button layerkey_btn "layerkey" pos:[97,65] width:25 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_layer_i.bmp", "$scripts\DTools\ui\\cstools\\bip_layer_a.bmp", 24, 15, 15, 16, 16)toolTip:"捕捉和设置关键点"
	button Copy_btn "copy" pos:[13,44] width:35 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_copypaste_i.bmp", "$scripts\DTools\ui\\cstools\\bip_copypaste_a.bmp", 22, 3, 3, 4, 4) 
	button Paste_btn "paste" pos:[50,44] width:35 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_copypaste_i.bmp", "$scripts\DTools\ui\\cstools\\bip_copypaste_a.bmp", 22, 7, 7, 8, 8)
	button mirrorpaste_btn "MirrorPaste" pos:[87,44] width:35 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_copypaste_i.bmp", "$scripts\DTools\ui\\cstools\\bip_copypaste_a.bmp", 22, 9, 9, 10, 10)
	button MIX_btn "MIX" pos:[13,86] width:40 height:20	toolTip:"混合器" 
	checkbutton mixdoor_btn "mixmode" pos:[55,86] width:22 height:20 images:#("$scripts\DTools\ui\\cstools\\bip_modes_i.bmp", "$scripts\DTools\ui\\cstools\\bip_modes_a.bmp", 8, 7, 7, 8, 8) toolTip:"混合器模式"
	button MtoB_btn "M>B" pos:[79,86] width:33 height:20 
	button MixFolder_btn "+" pos:[114,86] width:8 height:20
	groupBox grp13 "CS_骨骼工具" pos:[6,6] width:124 height:161
	Timer    tmr1   "Timer" pos:[-11,261] width:24 height:24 interval:100
	on tmr1 tick do
(
		if  classof selection[1]==Biped_Object do
	(
		mingzhi=selection[1].controller.rootNode
		shuzi= mingzhi.controller.trackSelection
(bip=selection[1].controller.rootNode; if  bip.controller.mixerMode==false  do  
	(mixdoor_btn.checked=false 
	leftfootA_btn.enabled=true 
	leftfootB_btn.enabled=true
	leftfootC_btn.enabled=true
	leftfootD_btn.enabled=true
	savefile_btn.enabled=true
	openfile_btn.enabled=true
	key_btn.enabled=true
	plantedkey_btn.enabled=true
	sliderkey_btn.enabled=true
	freekey_btn.enabled=true
	hori_btn.enabled=true
	vert_btn.enabled=true
	rotate_btn.enabled=true
	newlayer_btn.enabled=true
	deletelayer_btn.enabled=true
	collapselayer_btn.enabled=true
	layerkey_btn.enabled=true
	Copy_btn.enabled=true
	Paste_btn.enabled=true
	mirrorpaste_btn.enabled=true
		)
if  bip.controller.mixerMode==true  do (	
	mixdoor_btn.checked=true
	leftfootA_btn.enabled=false 
	leftfootB_btn.enabled=false
	leftfootC_btn.enabled=false
	leftfootD_btn.enabled=false
	savefile_btn.enabled=false
	openfile_btn.enabled=false
	key_btn.enabled=false
	plantedkey_btn.enabled=false
	sliderkey_btn.enabled=false
	freekey_btn.enabled=false
	hori_btn.enabled=false
	vert_btn.enabled=false
	rotate_btn.enabled=false
	newlayer_btn.enabled=false
	deletelayer_btn.enabled=false
	collapselayer_btn.enabled=false
	layerkey_btn.enabled=false
	Copy_btn.enabled=false
	Paste_btn.enabled=false
	mirrorpaste_btn.enabled=false
	)
	)
	
		if shuzi==1 do
		(
			hori_btn.checked = true  
			vert_btn.checked = false 
			rotate_btn.checked = false
		)
		if shuzi==2 do 
		(	hori_btn.checked = false  
			vert_btn.checked = true 
			rotate_btn.checked = false
			)
		if shuzi==3 do 
		(	hori_btn.checked = false  
			vert_btn.checked = false 
			rotate_btn.checked = true 
		)
		if shuzi==4 do 
		(	hori_btn.checked = true   
			vert_btn.checked = true 
			rotate_btn.checked =false 
		)
			if shuzi==5 do 
		(	hori_btn.checked = true   
			vert_btn.checked = false 
			rotate_btn.checked =true 
		)
			if shuzi==6 do 
		(	hori_btn.checked = false  
			vert_btn.checked = true
			rotate_btn.checked =true 
		)
			if shuzi==7 do 
		(	hori_btn.checked = true  
			vert_btn.checked = true
			rotate_btn.checked =true 
		)
	)
	zxshuzhi=shuzi
-- 		shezi=false 
-- 	   	  for n in 1 to selection.count do
-- 		(	
-- 			if classof selection[n]==Biped_Object do
-- 			( 
-- 				if  shezi!=true do(
-- 				bip=selection[n].controller	
-- 				if bip.mixerMode==true then  mixdoor_btn.checked=true;
-- 				else  mixdoor_btn.checked=false;
-- 				shezi=true
-- 				)
-- 			)
-- 		)
	  )
	  
	 fn BipedPivot PivotNumber =
  (
    if havebip==1 then
	(
    foot=$ ;clearselection();
	max motion mode;select foot;TheKeyIndex = getKeyIndex ($.controller) currentTime;max create mode;
	if TheKeyIndex != 0 then
	(
		TheKey = biped.getKey foot.controller TheKeyIndex;
		TheKey.ikPivotIndex = PivotNumber
		)
		)
	
)
	on LeftFootA_btn mouseover do (LeftFootA_btn.bitmap = image_LeftFootA2)
	on LeftFootA_btn mouseout  do (LeftFootA_btn.bitmap = image_LeftFootA)

	
	on LeftFootB_btn mouseover do (LeftFootB_btn.bitmap = image_LeftFootB2)
	on LeftFootB_btn mouseout  do (LeftFootB_btn.bitmap = image_LeftFootB)
	
	on LeftFootC_btn mouseover do (LeftFootC_btn.bitmap = image_LeftFootC2)
	on LeftFootC_btn mouseout  do (LeftFootC_btn.bitmap = image_LeftFootC)

	
	on LeftFootD_btn mouseover do (LeftFootD_btn.bitmap = image_LeftFootD2)
	on LeftFootD_btn mouseout  do (LeftFootD_btn.bitmap = image_LeftFootD)
	

	on LeftFootA_btn  click do 
	(
		
		if  selection.count==1 do
		(if classof $==Biped_Object do 
			(
				biped.setSelectedKey  $.controller
				BipedPivot 1
			)
		) 
	
	)
	on LeftFootB_btn  click do 
	(
		if  selection.count==1 do
		(if classof $==Biped_Object do 
			(
				biped.setSelectedKey  $.controller
				BipedPivot 3
			)
		) 
	
	)
    on LeftFootC_btn  click do 
	(
		if  selection.count==1 do
		(if classof $==Biped_Object do 
			(
				biped.setSelectedKey  $.controller
				BipedPivot 6
			)
		) 
	
	)
    on LeftFootD_btn  click do	
		(
		if  selection.count==1 do
		(if classof $==Biped_Object do 
			(
				BipedPivot 8
			)
		) 
	
	)
	
	on savefile_btn pressed do
	(
		if  classof selection[1]==Biped_Object then
					
	 (
		 bip=selection[1].controller.rootNode.controller
		 if bip.figureMode== true then
			 (
       		if querybox "BIP处于编辑状态，要切换成运动模式并保存BIP文件么？" title:"提示" beep:false then
			try(
				selection[1].controller.rootNode.controller.figureMode=false 
				local bipfile
				makeDir ("D:\Program Files\Autodesk\CannedFish\bip")
		    bipfile = getsavefileName caption:"保存BIP文件" filename:"D:\Program Files\Autodesk\CannedFish\bip\bip动画"  types:"Bip file(*.Bip)|*.bip|All files(*.*)|*.*"
		   if bipfile!=undefined then 
		   (
			
		      bip=selection[1].controller
			  biped.saveBipfile bip bipfile
			  biped_ctrl =selection[1].controller
		      activeTimeString = filterString (animationRange as string) " "
		      startFrame = (replace activeTimeString[2] activeTimeString[2].count 1 "") as integer
		      endFrame = (replace activeTimeString[3] (activeTimeString[3].count-1) 2 "") as integer
		      biped.saveBipFileSegment biped_ctrl bipfile startFrame endFrame
		   )
			)catch()
			)
			 
			 else 
		  (	
			local bipfile
			makeDir ("D:\Program Files\Autodesk\CannedFish\bip")
		    bipfile = getsavefileName caption:"保存BIP文件" filename:"D:\Program Files\Autodesk\CannedFish\bip\bip动画"  types:"Bip file(*.Bip)|*.bip|All files(*.*)|*.*"
		   if bipfile!=undefined then 
		   (
		      bip=selection[1].controller
			  biped.saveBipfile bip bipfile
			  biped_ctrl =selection[1].controller
		      activeTimeString = filterString (animationRange as string) " "
		      startFrame = (replace activeTimeString[2] activeTimeString[2].count 1 "") as integer
		      endFrame = (replace activeTimeString[3] (activeTimeString[3].count-1) 2 "") as integer
		      biped.saveBipFileSegment biped_ctrl bipfile startFrame endFrame
		   )
          
		  )
   )
   )
   	on openfile_btn pressed do
	(
		if  classof selection[1]==Biped_Object then 
		(	
		 local bipfile
	   makeDir ("D:\Program Files\Autodesk\CannedFish\bip")
	    bipfile = getOpenFileName caption:"打开BIP文件" filename:"D:\Program Files\Autodesk\CannedFish\bip\bip动画" types:"Bip file(*.BIP)|*.bip|Bip file(*.BVH)|*.bvh|All files(*.*)|*.*"
			 if bipfile!=undefined then
	( 
			biped_ctrl =selection[1].controller
			 biped_time_ctrl = selection[1].controller
			 biped.loadbipfile biped_ctrl bipfile #noRedraw #noRedraw #noRedraw #noRedraw
			 num_keys = numkeys biped_time_ctrl
		     startTime = getkeytime biped_time_ctrl 1
			 endTime = startTime
		     for i = 1 to num_keys do (
		     key_time = getkeytime biped_time_ctrl i
		     if key_time > endTime then (
				endTime = key_time
				)
				)
		tempArr= filterstring (endTime as string) "f"
		
		endTime_int= tempArr[1] as integer
		format "endTime = %\n" (endTime_int) 

		if endTime_int > 0 then (
		animationRange = interval 0 endTime_int
		)
		else (
		animationRange = interval 0 1
		                            ) 
	)
	)
	)
	on hori_btn changed state do
	(
		if zxshuzhi==0 do (selection[1].controller.rootNode.controller.trackSelection=1)
		if zxshuzhi==1 do (selection[1].controller.rootNode.controller.trackSelection=0)
		if zxshuzhi==2 do (selection[1].controller.rootNode.controller.trackSelection=4)
		if zxshuzhi==3 do (selection[1].controller.rootNode.controller.trackSelection=5)
		if zxshuzhi==4 do (selection[1].controller.rootNode.controller.trackSelection=2)
		if zxshuzhi==5 do (selection[1].controller.rootNode.controller.trackSelection=3)
		if zxshuzhi==6 do (selection[1].controller.rootNode.controller.trackSelection=7)
		if zxshuzhi==7 do (selection[1].controller.rootNode.controller.trackSelection=6)
			)
	on vert_btn changed state do
	(
		if zxshuzhi==0 do (selection[1].controller.rootNode.controller.trackSelection=2)
		if zxshuzhi==1 do (selection[1].controller.rootNode.controller.trackSelection=4)
		if zxshuzhi==2 do (selection[1].controller.rootNode.controller.trackSelection=0)
		if zxshuzhi==3 do (selection[1].controller.rootNode.controller.trackSelection=6)
		if zxshuzhi==4 do (selection[1].controller.rootNode.controller.trackSelection=1)
		if zxshuzhi==5 do (selection[1].controller.rootNode.controller.trackSelection=7)
		if zxshuzhi==6 do (selection[1].controller.rootNode.controller.trackSelection=3)
		if zxshuzhi==7 do (selection[1].controller.rootNode.controller.trackSelection=5)
			)
	on rotate_btn changed state do
	(
		if zxshuzhi==0 do (selection[1].controller.rootNode.controller.trackSelection=3)
		if zxshuzhi==1 do (selection[1].controller.rootNode.controller.trackSelection=5)
		if zxshuzhi==2 do (selection[1].controller.rootNode.controller.trackSelection=6)
		if zxshuzhi==3 do (selection[1].controller.rootNode.controller.trackSelection=0)
		if zxshuzhi==4 do (selection[1].controller.rootNode.controller.trackSelection=7)
		if zxshuzhi==5 do (selection[1].controller.rootNode.controller.trackSelection=1)
		if zxshuzhi==6 do (selection[1].controller.rootNode.controller.trackSelection=2)
		if zxshuzhi==7 do (selection[1].controller.rootNode.controller.trackSelection=4)
		)
	on key_btn pressed do
	(
		for n in 1 to selection.count do
			(if classof selection[n]==Biped_Object do (
			biped.setSelectedKey  selection[n].controller)
			)
	)
	on plantedkey_btn pressed do
	(
		for n in 1 to selection.count do
			(if classof selection[n]==Biped_Object do (
			biped.setPlantedKey  selection[n])
			)
	)					
	on sliderkey_btn pressed do					
	(
		for n in 1 to selection.count do
			(if classof selection[n]==Biped_Object do (
			biped.setSlidingKey  selection[n])
			)
	)
	on freekey_btn pressed do
	(
		for n in 1 to selection.count do
			(if classof selection[n]==Biped_Object do (
			biped.setfreekey  selection[n])
			)
	)
	on copy_btn pressed  do
	(
		     for n in 1 to selection.count do
			(
			if classof selection[n]==Biped_Object do
			(
			bip=selection[n].controller	
			biped.deleteAllCopies  bip  #pose
			biped.deleteAllCopies bip #posture
			cos=biped.numCopyCollections bip
			if cos==0 then  biped.createcopyCollection bip "zsj"
			biped.copyPosture bip #posture on on on
			biped.setCopyName bip #posture 1 "posture_good"
			posturenum=biped.numCopies bip #posture 
			posenum=biped.numCopies bip #pose 
			   
				if posturenum==0 then 
				(biped.deleteAllCopies  bip  #pose
				biped.deleteAllCopies bip #posture
				biped.copyPosture  bip #pose on on on 
				biped.setCopyName bip #pose 1 "pose_good"		
				posturenum=biped.numCopies bip #posture 
				posenum=biped.numCopies bip #pose
			   )
			)
		)
			
	)
	on paste_btn pressed do
	undo on 
	(
		  for n in 1 to selection.count do
		(
			if classof selection[n]==Biped_Object do
			(
			bip=selection[n].controller	
			posturenum=biped.numCopies bip #posture 
			if posturenum==1  then 
			biped.pastePosture  bip #posture false "posture_good"
			else
			biped.pastePosture  bip #pose false "pose_good"	
			)
		)
	)
	on mirrorpaste_btn pressed do
		undo on 
	(
			  for n in 1 to selection.count do
		(
			if classof selection[n]==Biped_Object do
			(
			bip=selection[n].controller	
			posturenum=biped.numCopies bip #posture 
			if posturenum==1  then 
		   biped.pastePosture  bip #posture true "posture_good"
			else
		   biped.pastePosture  bip #pose true "pose_good"
			)
		)			
	)
		on newlayer_btn pressed do
	(	shezi=false 
	   	  for n in 1 to selection.count do
		(	
			if classof selection[n]==Biped_Object do
			( 
				if  shezi!=true do(
				bip=selection[n].controller
				if biped.numLayers bip >= 1 then
				messagebox("当前已存在层,无法再增加了")
				else
				undo on( biped.createLayer bip 1 "Layer 2" )
				slidertime=currenttime
				shezi=true
				)
			)
		)
				
	)
	on deletelayer_btn pressed do
		undo on(
			for n in 1 to selection.count do
			(
				if classof selection[1]==Biped_Object do
				(
				bip=selection[n].controller
				if biped.numLayers bip >= 1 then   biped.deleteLayer bip  1 )
			)
		)
	on collapselayer_btn pressed do
	undo on(	  
		for n in 1 to selection.count do
		(
			if classof selection[n]==Biped_Object do
			(
			bip=selection[n].controller
			if biped.numLayers bip >= 1 then   biped.collapseAtLayer bip  0 )
		)
	)
	on layerkey_btn pressed do
	undo on(
		for n in 1 to selection.count do
		(
			if classof selection[n]==Biped_Object do
			(
			bip=selection[n]
				biped.setSnapKey bip
			)
		)
	)
on MIX_btn pressed do
( themixer.hideMixer();	themixer.showMixer();   )
		
	on mixdoor_btn changed state do
	(if classof selection[1]==Biped_Object do
(bip=selection[1].controller.rootNode; if mixdoor_btn.checked==true then  bip.controller.mixerMode=true else bip.controller.mixerMode = false; )
	)
	on MtoB_btn pressed do
	undo on (
	if classof selection[1]==Biped_Object do
	(
	 if  mixdoor_btn.checked==true then 
	  (
		bip=selection[1].controller.rootNode;
	   mymixer = bip.transform.controller.mixer
	   mixdown mymixer false false 0 false 0.0
	   copyMixdownToBiped  mymixer
	   bip.controller.mixerMode=false
	   mixdoor_btn.checked=false
	  )
	)
	)
	
	on  MixFolder_btn pressed do
	(
      if mergebip.open==false then createdialog mergebip 294 157
         else DestroyDialog mergebip  
	)


	
		on cstoolroll1 lbuttondblclk g11 do
		(		DestroyDialog cstoolroll1
		)
		on cstoolroll1 lbuttonup pos1 do
	(	
		cstoolroll1_weizhi=(mouse.screenpos-Thepos1)
		makeDir  ((GetDir #scripts)+"\\DTools\\")
		setINISetting "$scripts\\DTools\jiaoben_weizhi.ini" "cstoolroll1" "cstoolroll1_weizhi" (cstoolroll1_weizhi as string )
		mousedd1=false
	)
		on cstoolroll1 lbuttondown pos1 do
	(
		mousedd1=true
		Thepos1=pos1
	)
		on cstoolroll1 mouseMove pos1 do
	(	if mousedd1==true Then 
		(SetDialogPos cstoolroll1 (mouse.screenpos-Thepos1))

		)
)
cstoolroll1_weizhi=[0,0]
makeDir  ((GetDir #scripts)+"\\DTools\\")
ss=(getINISetting "$scripts\\DTools\jiaoben_weizhi.ini" "cstoolroll1" "cstoolroll1_weizhi") 
if ss !="" then( cstoolroll1_weizhi=execute ss
createDialog cstoolroll1 pos:cstoolroll1_weizhi  fgcolor:(color 50 255 255) style:#(#style_maximizebox)
	)
	else
	(createDialog cstoolroll1   fgcolor:(color 50 255 255) style:#(#style_maximizebox))
	