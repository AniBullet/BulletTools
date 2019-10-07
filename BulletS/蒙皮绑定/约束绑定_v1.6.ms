-------------------------------------------------------
-------------------约束绑定-----------------------
------------------Time:2018-09-12----------------------
-------------------Author:乔磊-------------------------
------------------QQ:409856476-------------------------
-------------------------------------------------------



rollout PosLookAt_Constraint "位置注视约束" width:162 height:126
(
	spinner 'Con_size' "控制器尺寸:" pos:[13,7]  range:[0.01,100,1] scale:0.1  align:#left
 
	colorPicker 'Con_Color' "控制器颜色:" pos:[13,28]  color:[0,255,0] modal:false toolTip:"预设控制器颜色" align:#left  
  

	edittext 'name_tex' "控制器命名" pos:[13,53] width:136 height:17 align:#left 
 

	button 'PosLookat_Con' "位置注视约束"  width:82 height:21 toolTip:"依次选取物体"  
 

	
	local tem_color=[0,255,0]
	local tem_size=1
	local tem_name=""

	
	on Con_size changed val do  
	(
		--selection.size = val
		tem_size=val as float
	)
	
	
	on Con_Color changed new_col do
	(
		--selection.wirecolor = new_col
		tem_color=new_col
	)
	
	on name_tex entered txt do
	(
		tem_name = txt
	)
	on PosLookat_Con pressed do
	(
		pts=#()
		for x in selection do
		(	
			layer = layermanager.newLayerFromName "Con_Point"
			layer = LayerManager.getLayerFromName  "Con_Point"
			pt=point size:PosLookAt_Constraint.Con_size.value centermarker:false axistripod:false cross:false box:true wirecolor:PosLookAt_Constraint.Con_Color.color
			if tem_name != "" then
			(
				pt.name = uniquename tem_name
			)
			pt.transform=x.transform
			append pts pt
			layer.addNode pt -----添加集合
		) 
		for i=1 to selection.count do
		(
			a=selection[i]
			PosCon=position_constraint()  ---创建位置约束
			a.pos.controller=PosCon
			PosCon.appendTarget pts[i] 100 		
			if i<selection.count then
			(
				lookAtCon=LookAt_constraint()  ---创建注视约束
				a.rotation.controller=lookAtCon
				lookAtCon.appendTarget pts[i+1] 100
				lookAtCon.lookat_vector_length=0  
				lookAtCon.upnode_world=false
				lookAtCon.pickupNode=pts[i]
				
			)
			
		)
		
	)
)

--------------------------------------------------------------------------------------------------------------------------------

rollout Pos_Constraint "位置约束"
(
	button Pos_Con "位置约束"  toolTip:"依次选取三个物体" 
	
	on Pos_Con pressed do
	(
		if selection.count ==3 then
		(
			for i=2 to selection.count-1 do
			(
				a=selection[i]
				a.pos.controller=position_list ()	
				PosCon=position_constraint()  ---创建位置约束
				a.pos.controller.Available.controller=PosCon			
				PosCon.appendTarget selection[i-1] 50	
				PosCon.appendTarget selection[i+1] 50	
				PosCon.relative = on
				a.pos.controller.Available.controller= Position_XYZ ()
				lst = a.pos.controller
				lst.SetActive 3
			)
		)
		else
		(
			messagebox "请依次选择三个物体" beep:false
		)
	)
		
)

--------------------------------------------------------------------------------------------------------------------------------

rollout Rot_Constraint "方向约束"
(
	button Rot_Con "方向约束"  toolTip:"依次选取三个物体" 
	
	on Rot_Con pressed do
	(
		if selection.count ==3 then
		(
			for i=2 to selection.count-1 do
			(
				a=selection[i]
				a.rotation.controller=rotation_list ()	
				RotCon=Orientation_Constraint()  ---创建方向约束
				a.rotation.controller.Available.controller=RotCon			
				RotCon.appendTarget selection[i-1] 50	
				RotCon.appendTarget selection[i+1] 50	
				RotCon.relative = on
				a.rotation.controller.Available.controller= Euler_XYZ ()
				lst = a.rotation.controller
				lst.SetActive 3
			)
		)
		else
		(
			messagebox "请依次选择三个物体" beep:false
		)	
	)
)



--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
------------------------------链子锤工具----------------------------------------------------------------------------------------

if wando_chains !=undefined then destroydialog wando_chains

rollout wando_chains "链子骨骼架设" 
(
	Global EC_OBJ, EC_TargetOBJ = "None" 
	local constraintor = #()
	local distance_all = #(0)
	local spline_bones = #()
	local spline_bones_pos = #()
	
	
	fn constraintor_percent dis_all  num =  ----计算百分比函数
	(
		dd = 0
		for i in 1 to num do
		(
			dd = dd + dis_all[i]
		)
		spline_length = 0
		for i in dis_all do 
		(
			spline_length = spline_length + i
		)
		return ( dd / spline_length * 100 )
	)
	
	fn drawLine ptArray =    ----画线函数
	(
		LyLine = SplineShape pos:ptArray[1]
		addNewSpline LyLine
		for i in 1 to ptArray.count do 
		( 
			addKnot LyLine 1 #smooth #curve ptArray[i] 
		)
		updateShape LyLine
		return  LyLine
	)
	fn SelChildren sel SelChilds =   --把子物体加进选择集函数
	(
		for i = 1 to sel.children.count do
		( 
			tempsel = sel.children[i]
			append SelChilds tempsel 
			if tempsel != undefined do SelChildren tempsel SelChilds
		)
		return  SelChilds
	)
	checkbox chk_hammer "链锤，保持锤子不变形"  toolTip:"既然是链锤，所以就需要锤子不变形"
	button btn_chains "架设骨骼" 
	hyperlink lbl_help "帮助" address: "http://www.cgjoy.com/thread-1634-1-1.html" align:#center offset:[0,10]
	--activeXControl ax1 "http://www.cgjoy.com/mini.php" height:685 width:230 align:#center 

	
		
	on btn_chains pressed do
	(
		constraintor = #()
		distance_all = #(0)
		spline_bones = #()
		spline_bones_pos = #()
		undo on
		(
			if selection.count == 1 then 
			(
				tempsel = #()
				append tempsel $ 
				SelChildren $ tempsel
				print (tempsel.count as string + "----------------------------------")
				select tempsel
			)
			if selection.count >= 3 then 
			(
				if chk_hammer.checked == true then
				(
					if selection.count >=4 then
					(
						for i in 1 to (selection.count-1) do append spline_bones selection[i]
					)
				)
				else
				(
					if selection.count >=3 then
					(
						for i in selection do append spline_bones i
					)
				)
			
				if spline_bones.count >= 3 then
				(
					for i in 2 to spline_bones.count do append  spline_bones_pos  spline_bones[i].pos
				)
				
				for i in 1 to (spline_bones_pos.count-1) do append distance_all (distance spline_bones[i] spline_bones[i+1])
	
				for i in 2 to spline_bones.count do 
				(
					constraintor_point = (Point transform:spline_bones[i].transform size:(spline_bones[i].width*3) name:("constraintor_" + spline_bones[i].name))
					append constraintor constraintor_point
					select spline_bones[i]
				
				--=========================以下部分是位置约束===========================================
							-------------------------------------------------------------------------------------------
							-- Switch to Motion Panel
							-------------------------------------------------------------------------------------------
						
							IF getCommandPanelTaskMode() != #motion then SetCommandPanelTaskMode Mode:#Motion
							
							-------------------------------------------------------------------------------------------
							-- Check for Groups and act accordingly
							-------------------------------------------------------------------------------------------
							
							EC_OBJ = selection[1]
							if selection.count > 1 do 
							(
								local h = EC_OBJ.parent 
								if (h != undefined and h.isSelected and isGroupHead h) do EC_OBJ = h
							)
							
							-------------------------------------------------------------------------------------------
							-- Define Filter Function for PickObject Selection
							-------------------------------------------------------------------------------------------
							
							fn SameFilt o = (refs.DependencyLoopTest o EC_OBJ.controller) == false
							
							-------------------------------------------------------------------------------------------
							
							--Format "%\n" ("Pick Object to Constrain " + EC_OBJ.name + " to:") to:Listener
							
							-------------------------------------------------------------------------------------------
							-- Pick Target Object
							-------------------------------------------------------------------------------------------
						
							--EC_TargetOBJ = PickObject count:1 select:true Filter:SameFilt message:"Pick Object to Constraint to..." Rubberband:EC_OBJ.transform.pos ForceListenerFocus:False
							EC_TargetOBJ = getNodeByName ("constraintor_" + spline_bones[i].name)
							If EC_TargetOBJ != undefined and EC_TargetOBJ != "None" then
							(
								-------------------------------------------------------------------------------------------
								-- Add List Controller
								-------------------------------------------------------------------------------------------
								
								local cont = AddListController EC_OBJ "Pos" Position_List
								-- print cont
				
								-------------------------------------------------------------------------------------------
								-- Add Constraint
								---------------------------------------------------------------------------------------
								If classof cont[listCtrl.GetActive cont].object != Position_Constraint then constraint = AddConstraint EC_OBJ "Pos" Position_Constraint true
								else constraint = cont[listCtrl.GetActive cont].object
								-------------------------------------------------------------------------------------------
								-- Add Position Constraint Objects
								-------------------------------------------------------------------------------------------
								If ((constraint.AppendTarget EC_TargetOBJ 50) == true) then
								(
								-------------------------------------------------------------------------------------------
								-- Set Active Controller
								-------------------------------------------------------------------------------------------
										
								SetActiveController cont constraint
											
								--Format "%\n"  (EC_OBJ.name + " is Constrained to " + EC_TargetOBJ.name) to:Listener
							
								-------------------------------------------------------------------------------------------
								Select EC_OBJ		
							)	
								else throw 0
							)	
				--=========================以上部分把位置约束搞定了。===========================================
				
				)
				for i in 1 to (spline_bones.count-1) do
				(
						select spline_bones[i]
						-------------------------------------------------------------------------------------------
						-- Switch to Motion Panel
						-------------------------------------------------------------------------------------------
					
						IF getCommandPanelTaskMode() != #motion then SetCommandPanelTaskMode Mode:#Motion
						
						-------------------------------------------------------------------------------------------
						-- Check for Groups and act accordingly
						-------------------------------------------------------------------------------------------
						
						EC_OBJ = selection[1]
						if selection.count > 1 do 
						(
							local h = EC_OBJ.parent 
							if (h != undefined and h.isSelected and isGroupHead h) do EC_OBJ = h
						)
						
						-------------------------------------------------------------------------------------------
						-- Define Filter Function for PickObject Selection
						-------------------------------------------------------------------------------------------
						
						fn SameFilt o = (refs.DependencyLoopTest o EC_OBJ.controller) == false
						
						-------------------------------------------------------------------------------------------
						
						-- Format "%\n" ("Pick Object to Constrain " + EC_OBJ.name + " to:") to:Listener
				
						-------------------------------------------------------------------------------------------
						-- Pick Target Object
						-------------------------------------------------------------------------------------------
						
						--EC_TargetOBJ = PickObject count:1 select:true filter:SameFilt Message:"Pick Object to Look At.." Rubberband:EC_OBJ.transform.pos ForceListenerFocus:False
						EC_TargetOBJ = getNodeByName ("constraintor_" + spline_bones[(i+1)].name)
						If EC_TargetOBJ != undefined and EC_TargetOBJ != "None" then
						(
							-------------------------------------------------------------------------------------------
							-- Add List Controller
							-------------------------------------------------------------------------------------------
							
							local cont = AddListController EC_OBJ "Rotation" Rotation_List
							
							-------------------------------------------------------------------------------------------
							-- Add Constraint
							---------------------------------------------------------------------------------------
							
							If classof cont[listCtrl.GetActive cont].object != LookAt_Constraint then constraint = AddConstraint EC_OBJ "Rotation" LookAt_Constraint true
								else constraint = cont[listCtrl.GetActive cont].object
							-------------------------------------------------------------------------------------------
							-- Add Look At Constraint Objects
							-------------------------------------------------------------------------------------------
									
							If ((constraint.AppendTarget EC_TargetOBJ 50) == true) then
							(
							-------------------------------------------------------------------------------------------
							-- Set Active Controller
							-------------------------------------------------------------------------------------------
									
							SetActiveController cont constraint
					
							-- Format "%\n"  (EC_OBJ.name + " is Constrained to " + EC_TargetOBJ.name) to:Listener
							
							-------------------------------------------------------------------------------------------
							Select EC_OBJ
						)
							else throw 0
						)
				)
				myline = drawLine spline_bones_pos ----画线
				print (myline.name + "-------------------------------------------------------")
				for i in 1 to constraintor.count do  -- 路径动画
				(
						select constraintor[i]
						-------------------------------------------------------------------------------------------
						-- Switch to Motion Panel
						-------------------------------------------------------------------------------------------
					
						IF getCommandPanelTaskMode() != #motion then SetCommandPanelTaskMode Mode:#Motion
						
						-------------------------------------------------------------------------------------------
						-- Check for Groups and act accordingly
						-------------------------------------------------------------------------------------------
						
						EC_OBJ = selection[1]
						if selection.count > 1 do 
						(
							local h = EC_OBJ.parent 
							if (h != undefined and h.isSelected and isGroupHead h) do EC_OBJ = h
						)
						
						-------------------------------------------------------------------------------------------
						-- Define Filter Function for PickObject Selection
						-------------------------------------------------------------------------------------------
						
						fn ShapeFilt o = superClassOf o == Shape and (refs.DependencyLoopTest o EC_OBJ.controller) == false
						
						-------------------------------------------------------------------------------------------
								
						--Format "%\n" ("Pick Shape to Constrain " + EC_OBJ.name + " to:") to:Listener
						
						--EC_TargetOBJ = PickObject count:1 select:true filter:ShapeFilt message:"Pick Shape to Constrain to.." Rubberband:EC_OBJ.transform.pos ForceListenerFocus:False
						EC_TargetOBJ = myline
						If EC_TargetOBJ != undefined and EC_TargetOBJ != "None" then
						(
							-------------------------------------------------------------------------------------------
							-- Add List Controller
							-------------------------------------------------------------------------------------------
							
							local cont = AddListController EC_OBJ "Pos" Position_List
							
							-------------------------------------------------------------------------------------------
							-- Add Constraint
							-------------------------------------------------------------------------------------------
							If classof cont[listCtrl.GetActive cont].object != Path then constraint = AddConstraint EC_OBJ "Pos" Path true
							else constraint = cont[listCtrl.GetActive cont].object
					
							-------------------------------------------------------------------------------------------
							-- Add Position Constraint Objects
							-------------------------------------------------------------------------------------------
									
							If ((constraint.AppendTarget EC_TargetOBJ 50) == true) then
							(
							-------------------------------------------------------------------------------------------
							-- Set Active Controller
							-------------------------------------------------------------------------------------------
									
							SetActiveController cont constraint
										
							--Format "%\n"  (EC_OBJ.name + " is Path Constrained to " + EC_TargetOBJ.name) to:Listener
							
							-------------------------------------------------------------------------------------------			
							Select EC_OBJ
						)	
							else throw 0
						)	
					-----------------------------------------------------
						myper = constraintor_percent distance_all i
						$.pos.controller.Path_Constraint.controller.percent = myper
						maxOps.deleteSelectedAnimation()
				)
				addModifier myline (Spline_IK_Control ())
				myline.Modifiers[#Spline_IK_Control].createHelper  spline_bones_pos.count
				myline.Modifiers[#Spline_IK_Control].helper_size = (spline_bones[1].width*6)
				myline.Modifiers[#Spline_IK_Control].noLinking()
				if chk_hammer.checked == true then
				(
					-------------------------------固定末端骨骼的旋转，就是不让锤子动。------------------------
					Moduan_IK_helper = myline.Modifiers[#Spline_IK_Control].helper_list[myline.Modifiers[#Spline_IK_Control].helper_list.count]
					Moduan_spline_bone = spline_bones[spline_bones.count]
					Moduan_IK_helper.transform = Moduan_spline_bone.transform
					select Moduan_spline_bone
					-------------------------------往下要给末端的骨骼加一个旋转约束----------------------------
					-- Switch to Motion Panel
					-------------------------------------------------------------------------------------------
				
					IF getCommandPanelTaskMode() != #motion then SetCommandPanelTaskMode Mode:#Motion
					
					-------------------------------------------------------------------------------------------
					-- Check for Groups and act accordingly
					-------------------------------------------------------------------------------------------
					
					EC_OBJ = selection[1]
					if selection.count > 1 do 
					(
						local h = EC_OBJ.parent 
						if (h != undefined and h.isSelected and isGroupHead h) do EC_OBJ = h
					)
					
					-------------------------------------------------------------------------------------------
					-- Define Filter Function for PickObject Selection
					-------------------------------------------------------------------------------------------
					
					fn SameFilt o = (refs.DependencyLoopTest o EC_OBJ.controller) == false
					
					-------------------------------------------------------------------------------------------
					
					--Format "%\n" ("Pick Object to Constrain " + EC_OBJ.name + " to:") to:Listener
					
					--EC_TargetOBJ = PickObject count:1 select:true filter:SameFilt message:"Pick Object to Constrain to..." Rubberband:EC_OBJ.transform.pos ForceListenerFocus:False
					EC_TargetOBJ = Moduan_IK_helper
					If EC_TargetOBJ != undefined and EC_TargetOBJ != "None" then
					(
						-------------------------------------------------------------------------------------------
						-- Add List Controller
						-------------------------------------------------------------------------------------------
						
						local cont = AddListController EC_OBJ "Rotation" Rotation_List
						
						-------------------------------------------------------------------------------------------
						-- Add Constraint
						---------------------------------------------------------------------------------------
						If classof cont[listCtrl.GetActive cont].object != Orientation_Constraint then constraint = AddConstraint EC_OBJ "Rotation" Orientation_Constraint true
							else constraint = cont[listCtrl.GetActive cont].object
		
						-------------------------------------------------------------------------------------------
						-- Add Position Constraint Objects
						-------------------------------------------------------------------------------------------
								
						If ((constraint.AppendTarget EC_TargetOBJ 50) == true) then
						(
						-------------------------------------------------------------------------------------------
						-- Set Active Controller
						-------------------------------------------------------------------------------------------
								
						SetActiveController cont constraint
				
						--Format "%\n"  (EC_OBJ.name + " is Constrained to " + EC_TargetOBJ.name) to:Listener
						
						-------------------------------------------------------------------------------------------
						Select EC_OBJ
					)	
						else throw 0
					)	
				)
			)
			else 
			(
				Messagebox "骨骼数太少，无法使用用!"
			)
		)
	)
	
)

--------------------------------------------------------------------------------------------------------------------------------

rollout Mirror_Control "镜像控制"
(
	checkbox 'pos_s' "Pos" pos:[13,7] checked:true 
 
	checkbox 'Rot_s' "Rot" pos:[56,7] checked:true 
 
	checkbox 'scale_s' "Scale" pos:[101,7]  checked:true 
 
	radiobuttons 'radioAxis' "父物体镜像轴："  labels:#("X", "Y", "Z") columns:3  --labels:#("X", "Y", "Z") columns:3
 --labels:#("X", "Y", "Z") columns:3
--labels:#("X", "Y", "Z") columns:3
--labels:#("X", "Y", "Z") columns:3

	button 'start' "镜像"  toolTip:"依次选取控制物体和被控制物体"
 

	local mirrorTm=1	
		

	on radioAxis changed var do --设置镜像轴
	(
	    case of(
	        (var == 1 ): mirrorTm=1
	        (var == 2 ): mirrorTm=2
	        (var == 3 ): mirrorTm=3
	    )
	)
	on start pressed do
	(
		for i=1 to selection.count do
		(
			paramWire.disconnect selection[i].controller

			
			selection[i].position.controller=Position_XYZ()
	
			selection[i].rotation.controller=Euler_XYZ()
			
			selection[i].scale.controller = ScaleXYZ ()
	
		)
		
		if (mod selection.count 2 == 0) then
		(
			case of
			(
				( mirrorTm == 1 ):
					for i=1 to selection.count by 2 do
					(
						if pos_s.checked then
						(
							paramWire.connect selection[i].pos.controller[#X_Position] selection[i+1].pos.controller[#X_Position] "-X_Position"
							paramWire.connect selection[i].pos.controller[#Y_Position] selection[i+1].pos.controller[#Y_Position] "Y_Position"
							paramWire.connect selection[i].pos.controller[#Z_Position] selection[i+1].pos.controller[#Z_Position] "Z_Position"
						)	
						if Rot_s.checked then	
						(							
							paramWire.connect selection[i].rotation.controller[#X_Rotation] selection[i+1].rotation.controller[#X_Rotation] "X_Rotation"
							paramWire.connect selection[i].rotation.controller[#Y_Rotation] selection[i+1].rotation.controller[#Y_Rotation] "-Y_Rotation" 
							paramWire.connect selection[i].rotation.controller[#Z_Rotation] selection[i+1].rotation.controller[#Z_Rotation] "-Z_Rotation"
						)
						if scale_s.checked then	
						(
							paramWire.connect selection[i].transform.controller[#Scale] selection[i+1].transform.controller[#Scale] "Scale"
						)
						
					)
				( mirrorTm == 2 ):
					for i=1 to selection.count by 2 do
					(
						if pos_s.checked then
						(				
							paramWire.connect selection[i].pos.controller[#X_Position] selection[i+1].pos.controller[#X_Position] "X_Position"
							paramWire.connect selection[i].pos.controller[#Y_Position] selection[i+1].pos.controller[#Y_Position] "-Y_Position"
							paramWire.connect selection[i].pos.controller[#Z_Position] selection[i+1].pos.controller[#Z_Position] "Z_Position"
						)
						if Rot_s.checked then	
						(
							paramWire.connect selection[i].rotation.controller[#X_Rotation] selection[i+1].rotation.controller[#X_Rotation] "-X_Rotation"
							paramWire.connect selection[i].rotation.controller[#Y_Rotation] selection[i+1].rotation.controller[#Y_Rotation] "Y_Rotation" 
							paramWire.connect selection[i].rotation.controller[#Z_Rotation] selection[i+1].rotation.controller[#Z_Rotation] "-Z_Rotation"
						)
						if scale_s.checked then	
						(
							paramWire.connect selection[i].transform.controller[#Scale] selection[i+1].transform.controller[#Scale] "Scale"
						)
					)
				( mirrorTm == 3 ):
					for i=1 to selection.count by 2 do
					(
						if pos_s.checked then
						(
							paramWire.connect selection[i].pos.controller[#X_Position] selection[i+1].pos.controller[#X_Position] "X_Position"
							paramWire.connect selection[i].pos.controller[#Y_Position] selection[i+1].pos.controller[#Y_Position] "Y_Position"
							paramWire.connect selection[i].pos.controller[#Z_Position] selection[i+1].pos.controller[#Z_Position] "-Z_Position"
						)
						if Rot_s.checked then	
						(
							paramWire.connect selection[i].rotation.controller[#X_Rotation] selection[i+1].rotation.controller[#X_Rotation] "-X_Rotation"
							paramWire.connect selection[i].rotation.controller[#Y_Rotation] selection[i+1].rotation.controller[#Y_Rotation] "-Y_Rotation" 
							paramWire.connect selection[i].rotation.controller[#Z_Rotation] selection[i+1].rotation.controller[#Z_Rotation] "Z_Rotation"
						)
						if scale_s.checked then	
						(
							paramWire.connect selection[i].transform.controller[#Scale] selection[i+1].transform.controller[#Scale] "Scale"
						)
					)
			)
		)
		else
		(
			messagebox "选择个数非偶数" 
		)
	)

)


--------------------------------------------------------------------------------------------------------------------------
------------------------------链接----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
rollout CRE_link "链接" width:162 height:49
(
	
	checkbox 'In_Ex' "对齐" pos:[21,7] width:46 height:15 checked:false toolTip:"勾选后链接对齐" align:#left 	
 	
 	
 	
	button 'C_link' "快捷链接" pos:[68,5] width:60 height:21 toolTip:"选择的物体链接给最后一个物体" align:#left 
 
 



	on C_link pressed do
	(
		if (selection.count !=1 and selection.count !=0 )then
		(			
			if In_Ex.checked then
			(
				for i=1 to selection.count-1 do
				(
					$selection[i].parent = $selection[selection.count]
					selection[i].transform=selection[selection.count].transform
				)		
			)
			else
			(
				for i=1 to selection.count-1 do
				(
					$selection[i].parent = $selection[selection.count]		
				)	
			)
		)
		else
		(
			messagebox "请依次选择链接物体" beep:false
		)
		
	)
)


------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------

rollout Mirror_Con "镜像对齐" 
(
	button M_Con "镜像对齐"  width:97 height:20 toolTip:"依次选取镜像物体与原物体"
	
	
	fn MirrorCon=
	(
		
		for i=1 to (selection.count-1) do
		(
			setobj=selection[i]
			getobj=selection[selection.count]
			pos=getobj.pos
			rot=getobj.rotation
			setobj.rotation=(quat rot.x (rot.y*-1) (rot.z*-1) rot.w) 
			setobj.pos=pos*[-1,1,1]
			)
	)

	on M_Con pressed do
	(
		if selection.count !=0  then
		(
			MirrorCon ()
		)
		else
		(
			messagebox "请依次选取镜像物体与原物体" beep:false
		)

	)

)


------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------




rollout About_Sign "使用说明" width:162
(
	hyperlink lbl_help "帮助" address:"https://www.cgjoy.com/thread-211244-1-1.html" align:#center offset:[0,10]
)




--------------------------------------------------------------------------------------------------------------------------------


	AllRollout = newRolloutFloater "约束" 170 420
	addRollout PosLookAt_Constraint AllRollout
	addRollout Pos_Constraint AllRollout
	addRollout Rot_Constraint AllRollout
	addRollout Mirror_Con AllRollout
	addRollout CRE_Link AllRollout
	addRollout wando_chains AllRollout
	addRollout Mirror_Control AllRollout
	addRollout About_Sign AllRollout

 
	PosLookAt_Constraint.open = true
	Pos_Constraint.open = true
	Rot_Constraint.open = true
	Mirror_Con.open = true
	CRE_link.open = true
	wando_chains.open = false
	Mirror_Control.open = false
	About_Sign.open = false
