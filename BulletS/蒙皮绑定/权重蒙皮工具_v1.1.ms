--创建UI

--global paints
rollout paints "笔刷 " 
(

			
		button 'paints' "开启笔刷"  width:100 height:35 across:2
		checkbutton 'blends' "过渡"  width:100 height:35 
			
		button 'a.005' "0.005"  width:43 height:28 across:5  offset:[0,10]
	 
		button 'a.01' "0.01"  width:43 height:28  offset:[0,10]
	 
		button 'a.02' "0.02"  width:43 height:28  offset:[0,10]
	 
		button 'a.05' "0.05"  width:43 height:28  offset:[0,10]
	 
		button 'a1.0' "1"  width:43 height:28  offset:[0,10]
			
		spinner 'q' "权重" width:80 height:16 range:[0,1,0] scale:0.001 across:2 align:#left offset:[20,20]
			
		slider 'q1' ""  width:180 height:25 range:[0,1,0] length:20 align:#left offset:[-30,10]
		
		spinner 'size' "尺寸" width:80 height:16 range:[0,1,0] scale:0.01 across:2 align:#left offset:[20,10]
			
		slider 'size1' ""  width:180 height:25 range:[0,1,0] length:20 align:#left offset:[-30,0]
		
		checkBox Mirror_cb "镜像" checked:false across:4
		
		dropdownlist Mirror_axle "" enabled:false items:#("X","Y","Z") width:50   offset:[-30,-2]
		
		spinner Offset_M "Offset:" range:[-1e+006,1e+006,0] scale:0.001 offset:[-40,0]
		
		spinner GizmoSize_M "Gizmo Size:" range:[0,1e+006,1] scale:0.001
	
	---------------------------------------------------------------------------------
	
	
	---------------------------------------------------------------------------------	
		
	on paints pressed do
	(
		try
			(
				max modify mode
				if subobjectLevel == 0 then
					(
						
						subobjectLevel = 1
						$.modifiers[#Skin].filter_vertices = on
						$.modifiers[#Skin].showNoEnvelopes = on
						skinOps.paintWeightsButton $.modifiers[#Skin]
						thePainterInterface.maxStr = q.value
						
						)
				else
						(
							subobjectLevel = 0
							)
				)
				catch()
		)
	on blends changed state  do
	(
		try
			(
				if Blends.state == true then
					(
						$.modifiers[#Skin].paintBlendMode = on
						
						)
				else
						(
							$.modifiers[#Skin].paintBlendMode = off
							
							)
				)
				catch
					(
						"?????????"
						)
		
		)
	on a.005 pressed do
	(
		try
		
			(
				$.modifiers[#Skin].paintBlendMode = off
				thePainterInterface.maxStr = 0.005
				Blends.state = false
				q.value = 0.005
				q1.value = 0.005
				) 
	
		catch()
		)
	on a.01 pressed do
	(
		try
			(
				$.modifiers[#Skin].paintBlendMode = off
				thePainterInterface.maxStr = 0.01
				 Blends.state = false
				q.value = 0.01
				q1.value = 0.01
				)
				catch()
		)
	on a.02 pressed do
	(
		try
			(
				$.modifiers[#Skin].paintBlendMode = off
				thePainterInterface.maxStr = 0.02
				 Blends.state = false
				q.value = 0.02
				q1.value = 0.02
				)
				catch()
		)
	on a.05 pressed do
	(
		try
			(
				$.modifiers[#Skin].paintBlendMode = off
				thePainterInterface.maxStr = 0.05
				 Blends.state = false
				q.value = 0.05
				q1.value = 0.05
				)
				catch()
		)
	on a1.0 pressed do
	(
		try
			(
				$.modifiers[#Skin].paintBlendMode = off
				thePainterInterface.maxStr = 1
				Blends.state = false
				q.value = 1
				q1.value = 1
				)
				catch()
		)
		
		
	on q changed val do
	(
	try
		(
			q1.value = val 
			thePainterInterface.maxStr = q1.value
			)
		catch()
	)
	on q1 changed val do
	(
		try
			(
				q.value = val 
				thePainterInterface.maxStr = q.value
				)
				catch()
		)
	on size changed val do
	(
	try
		(
			size1.value = val 
			thePainterInterface.maxSize  = size1.value
			)
		catch()
	)
	
	on size1 changed val do
	(
		try
			(
				size.value = val 
				thePainterInterface.maxSize  = size.value
				)
				catch()
		)	
		
		
	
	on Mirror_cb changed state do
	(
		if state then
		(
			thePainterInterface.mirrorEnable =true
			
			Mirror_axle.enabled = true
			
		)
		else
		(
			thePainterInterface.mirrorEnable =false
			
			Mirror_axle.enabled = false
		)
		
	)
	
	on Mirror_axle selected i do
	(

		thePainterInterface.mirrorAxis = i as integer
		
		 
	)
	
	on Offset_M changed val do 
	(
		thePainterInterface.mirrorOffset = val
		
	)

	on GizmoSize_M changed val do 
	(
		thePainterInterface.mirrorGizmoSize = val
		
	)

	
)
	
---------------------------------------------------------------------------------------------------------		
		
rollout Weight_Tool	"权重工具"
(

		button 'shrink' "shrink" width:53 height:23 across:4 
		button 'grow' "grow"  width:53 height:23 
		button 'Ring' "ring"  width:53 height:23 
		button 'loop' "loop"  width:53 height:23 
			
			
		button 'b.0' "0"  width:27 height:18 across:7 offset:[0,5]
		button 'b.1' "0.1"  width:27 height:18 offset:[0,5]
		button 'b.25' "0.25"  width:27 height:18 offset:[0,5]
		button 'b.5' "0.5"  width:27 height:18 offset:[0,5]
		button 'b.75' "0.75"  width:27 height:18 offset:[0,5]
		button 'b.9' "0.9"  width:27 height:18 offset:[0,5]
		button 'b1' "1"  width:27 height:18 offset:[0,5]
			
			
		button 'sets' "set weight "  width:72 height:32 across:4 
			
		spinner 'spn2' ""  width:56 height:16 range:[0,1,0] offset:[-10,5]
			
		button 'jia' "+"  width:49 height:26 
			
		button 'jian' "-"  width:49 height:26 
			
			
			
		button 'scales weight' "scale weight "  width:72 height:32 across:4 offset:[4,0]
			
		spinner 'spn3' ""  width:56 height:16 range:[0,1,0] offset:[-10,5]
			

		button 'jia1' "+"  width:49 height:26 

		button 'jian1' "-"  width:49 height:26 	
			
			
			
			
		button 'copy' "copy"  width:49 height:26 across:4 
			
		button 'paste' "paste"  width:49 height:26 
			
		button 'paste_pos' "paste_pos"  width:64 height:26 
			
		button 'Blendss' "blend"  width:49 height:26 


		
		
		
	on shrink pressed do
	(
		try
			(
				skinOps.shrinkSelection $.modifiers[#Skin]
				
				)
			catch()
		
		)
	on grow pressed do
	(
		try
			(
				skinOps.growSelection $.modifiers[#Skin]
				)
				catch()
		)
	on Ring pressed do
	(
		try
			(
				skinOps.ringSelection $.modifiers[#Skin]
				)
				catch()
		)
	on loop pressed do
	(
		try
			(
				skinOps.loopSelection $.modifiers[#Skin]
				)
				catch()
		)
	on b.0 pressed do
	(
		try
			(
				skinOps.setWeight $.modifiers[#Skin] 0
				)
				catch()
		)
	on b.1 pressed do
	(
		try
			(
				skinOps.setWeight $.modifiers[#Skin] 0.1
				)
				catch()
		)
	on b.25 pressed do
	(
		try
			(
				skinOps.setWeight $.modifiers[#Skin] 0.25
				)
				catch()
		)
	on b.5 pressed do
	(
		try
			(
				skinOps.setWeight $.modifiers[#Skin] 0.5
				)
				catch()
		)
	on b.75 pressed do
	(
		try
			(
				skinOps.setWeight $.modifiers[#Skin] 0.75
				)
				catch()
		)
	on b.9 pressed do
	(
		try
			(
				skinOps.setWeight $.modifiers[#Skin] 0.9
				)
				catch()
		)
	on b1 pressed do
	(
		try
			(
				skinOps.setWeight $.modifiers[#Skin] 1
				)
				catch()
		)
	on sets pressed do
	(
		try
			(
				skinOps.setWeight $.modifiers[#Skin] spn2.value
				)
				catch()
		
		)
	on spn2 changed val do
	(
		try
			(
				spn2.value =val
				
				$.modifiers[#Skin].weightTool_weight = val
				)
				catch()
		)
	on jia pressed do
	(
		try
			(
				skinOps.addWeight $.modifiers[#Skin] 0.05
				)
				catch()
		
		)
	on jian pressed do
	(
		try
			(
				skinOps.addWeight $.modifiers[#Skin] -0.05
				)
				catch()
		)
	on spn3 changed val do
	(
		try
			(
				spn3.value =val
				
				$.modifiers[#Skin].weightTool_weight = val
				)
				catch()
		)
	on jia1 pressed do
	(
		try
			(
				skinOps.addWeight $.modifiers[#Skin] 0.005
				)
				catch()
		
		)
	on jian1 pressed do
	(
		try
			(
				skinOps.addWeight $.modifiers[#Skin] -0.005
				)
				catch()
		)
	on copy pressed do
	(
		try
			(
				skinOps.copyWeights $.modifiers[#Skin]
				)
				catch()
		)
	on paste pressed do
	(
		try
			(
				skinOps.pasteWeights $.modifiers[#Skin]
				)
				catch()
		
		)
	on paste_pos pressed do
	(
		try
			(
				skinOps.pasteWeightsByPos $.modifiers[#Skin] 0.1
				)
				catch()
		)
	on Blendss pressed do
	(
		try
			(
				skinOps.blendSelected $.modifiers[#Skin]
				)
				catch()
		)
)

----------------------------------------------------------------------------------------------------------------------------

rollout Change_Weight "权重替换-封套复制" 
(
	
	groupBox 'grp1' "权重替换" pos:[4,7] width:154 height:99 align:#left

    --pickbutton 'source_bone' "from bone" pos:[35,26] width:93 height:21 toolTip:"选取需要被替换蒙皮的骨骼" align:#left
    button btn_cp "From Bone" pos:[37,26] width:93 height:21 toolTip:"复制选中骨骼权重" align:#left

	--pickbutton 'target_bone' "to bone" pos:[40,52] width:82 height:21 toolTip:"选取替换蒙皮的骨骼" align:#left
    button btn_ps "To Bone" pos:[37,52] width:93 height:21 toolTip:"权重剪贴到选中骨骼" align:#left

    checkbox ckb_sele_ver "" pos:[12,42] checked:false toolTip:"只作用于选中点模式"


    progressBar Bar "ProgressBar" pos:[13,80] width:136 height:16 color:red--进度条
    -------------------------------------------------------------------------------------------------------------------------
    groupBox group_env "封套" pos:[170,7] width:154 height:70

    button btn_env_cp "复制" pos:[180,26] width:64 height:21 toolTip:"复制当前选中封套"
    button btn_env_pa "粘贴" pos:[250,26] width:64 height:21 toolTip:"黏贴封套到选中骨骼"
    button Reset_Env "重置封套线" pos:[220,50] toolTip:"选取模型重置封套"
    -------------------------------------------------------------------------------------------------------------------------
    hyperlink lbl_help "帮助" address:"https://www.cgjoy.com/thread-210984-1-1.html" align:#center offset:[75,10]
    --button btn_cp "From"
    --button btn_ps "To"

	local aBones
	local BoneID
    global in_R
    global out_R
    global objSkin
    global id_a
    global id_b
    global skin_bone
    global objmesh


	-- FUNCTIONS -------------------------------------------------------------------
    fn get_skin_mod_ver obj_skin=  --收集蒙皮下选中的 点
    (
        selectedVerts =#()
        for i = 1 to (skinOps.GetNumberVertices obj_skin) do --vertnum is number of vertices in skin object
        (
            theVert = skinOps.IsVertexSelected obj_skin i
            if theVert == 1 do (append selectedVerts i )
        )
        return selectedVerts
    )
    --------------------------------------------------
	fn returnObjectBones obj =
	(
		a = skinOps.getNumberBones obj
		for i in 1 to a collect (skinops.getBoneName obj i 1)
	)--收集蒙皮骨骼 名字

    ---返回骨骼ID
    --------------------------------------------------
    fn repskin fron_bone_ID to_bone_ID =
    (
        --try
       -- (
            --max modify mode  --打开蒙皮编辑窗口
            --objSkin = obj_Skin--$.skin  --获取蒙皮文件
            --objSkin = $.modifiers[#Skin]
            --if objSkin != undefined do--then
            undo "skin" on --撤销无效
            (
                SkinBoneNum = returnObjectBones objSkin   --获取蒙皮骨骼
                target_bone_ID = to_bone_ID --returnBoneIndex SkinBoneNum target_bone.text --获取目标骨骼ID
                --target_bone_ID = findItem SkinBoneNum target_bone.text   --获取目标骨骼ID
                --source_bone_ID = findItem SkinBoneNum source_bone.text
                source_bone_ID = fron_bone_ID  --returnBoneIndex SkinBoneNum source_bone.text --获取源骨骼ID

                if ckb_sele_ver.state then
                (
                    skin_ver = get_skin_mod_ver objSkin
                    if skin_ver.count !=0 then
                    (
                        numSkinVerts = skin_ver
                    )
                    else
                    (
                        numSkinVerts = #{1..(skinOps.getNumberVertices objSkin)}
                    )
                )
                else (
                    numSkinVerts = #{1..(skinOps.getNumberVertices objSkin)}  --获取参与蒙皮的点
                )
                -- numSkinVerts =skinOps.getNumberVertices objSkin --获取参与蒙皮的点


                if target_bone_ID != 0 and source_bone_ID != 0 then
                (
                    -- Process Skin --------------------------------------------------------

                    --for n = 1 to numSkinVerts do
                    for n in numSkinVerts do
                    (
                        -- Find number of bones effecting curent vertex

                        numBoneWeights = skinOps.getVertexWeightCount objSkin n   --获取骨骼ID为n参与的蒙皮点 --每个点有几根骨骼影响

                        -- Find all bone weights

                        aBoneID         = #()  --创建骨骼ID集合
                        aVertWeights    = #()  --创建权重中集合
                         -- skinOps.GetSelectedBone  skin  --当前选择骨骼序号
                        for b = 1 to numBoneWeights do
                        (
                            vertexWeight = skinOps.getVertexWeight objSkin n b   --获取第n个点的参与的第b个骨骼权重值
                            boneID       = skinOps.getVertexWeightBoneID objSkin n b  --获取第n个点参与的第b个骨骼的ID

                            append aBoneID boneID    --收集这个点参与的所有骨骼ID
                            append aVertWeights vertexWeight  ---收集这个点参与的每根骨骼ID的权重值
                        )

                        foundsource_boneIndex = 0
                        for b = 1 to aBoneID.count do   -- 解析查找被替换骨骼的的骨骼序列号数
                        (
                            if aBoneID[b] == source_bone_ID do--then
                            (
                                foundsource_boneIndex = b
                            )
                        )

                        foundtarget_boneIndex = 0
                        for b = 1 to aBoneID.count do   -- 解析查找替换骨骼的的骨骼序列号数
                        (
                            if aBoneID[b] == target_bone_ID do --then
                            (
                                foundtarget_boneIndex = b
                            )
                        )
                        if foundsource_boneIndex > 0 do --then
                        (
                            sourceWeight = aVertWeights[foundsource_boneIndex]  -- 收集

                            if foundtarget_boneIndex > 0 then
                            (
                                aVertWeights[foundtarget_boneIndex] += aVertWeights[foundsource_boneIndex]
                            )
                            else
                            (
                                append aVertWeights sourceWeight
                                append aBoneID target_bone_ID
                            )

                            deleteItem aVertWeights foundsource_boneIndex
                            deleteItem aBoneID foundsource_boneIndex

                            skinOps.replaceVertexWeights objSkin n aBoneID aVertWeights

                                -- End of this vertex
                            update $
                        )
                        --Change_Weight.Bar.value = 100.*n/numSkinVerts
                        Change_Weight.Bar.value = 100.*n/(numSkinVerts.count)
                    )
                    Change_Weight.Bar.value = 0
                )
                else
                (
                    messageBox "ERROR: Source Bone not found in Skin!" title:"target2source"
                )
            )
            /*
            else
            (
                messageBox "模型没有蒙皮,是否选错了模型     "
            )
            */
       -- )catch (print "lllllllllllllllll")
    )

    --------------------------------------------------
	-- START OF SCRIPT -------------------------------------------------------------
    --skinOps.addbone <Skin> <Bone_node> <Update_integer>
    -----------------------------------------------------
    on btn_cp pressed do
    (
        objSkin = $.modifiers[#Skin]
        if objSkin != undefined do
        (
            id_a = skinOps.GetSelectedBone objSkin
			btn_cp.caption= skinOps.GetBoneName objSkin id_a 1
			
        )
		--source_bone.text = obj.name
		
    )
    on btn_ps pressed do
    (
        objSkin = $.modifiers[#Skin]
        if objSkin != undefined then
        (
            id_b = skinOps.GetSelectedBone objSkin
            if id_a != id_b do
            (
                repskin id_a id_b
			
            )
        )
        else(
            messageBox "模型没有蒙皮,是否选错了模型     "
        )
    )
    -----------------------------------------------------
	on btn_env_cp pressed do
	(

            objSkin =$.modifiers[#Skin]
            objmesh = $
            if objSkin != undefined do
            (
                skin_bone = returnObjectBones objSkin
                bone_id = skinOps.GetSelectedBone objSkin
                if bone_id != 0 then
                (
                    in_R =#() --内圈
                    out_R = #() -- 外圈
                    for i=1 to 2 do
                    (
                        in_R_a = skinOps.getInnerRadius objSkin bone_id i
                        in_R[i] = in_R_a

                        out_R_a = skinOps.getOuterRadius objSkin bone_id i
                        out_R[i] = out_R_a
                    )
                )
                else(
                    messageBox "选中骨骼错误  "
                )
            )
	)
    -----------------------------------------------------
    on btn_env_pa pressed do
    (
        if selection.count !=0 do
        (
            skinbones_name = for i in selection collect i.name
            select objmesh
            max modify mode
            --Change_Weight.Bar.color = blue
            for p= 1 to skinbones_name.count do
            (
                bone_id = findItem skin_bone skinbones_name[p]
                if bone_id != 0 do
                (

                    for o= 1 to 2 do
                    (
                        --try (
                            skinOps.setInnerRadius objSkin bone_id o in_R[o]   --内圈

                            skinOps.setOuterRadius objSkin bone_id o out_R[o]  --外圈
                        --)catch()
                    )
                    Change_Weight.Bar.value = 10.*p/(skinbones_name.count)
                )

            )
            Change_Weight.Bar.value = 0
        )
    )
    -----------------------------------------------------
    on Reset_Env pressed do
    (
        objSkin =$.modifiers[#Skin]
        --skin_BoneNum = returnObjectBones objSkin
        skin_BoneNum = skinOps.getNumberBones objSkin
        for i=1 to skin_BoneNum do
        (
            Bone_Name=skinOps.GetBoneName  objSkin i 1 ---获取ID骨骼名称
            --Bone_Name = ChangeName Bone_Name
            if Bone_Name != undefined do
            (
                try (
                    boneobj = execute ("$"+Bone_Name)
                    )
                catch
                (
                    boneobj = execute ("$"+"'"+Bone_Name+"'")
                )

            )
            case (classof boneobj ) of
            (
                BoneGeometry :
                (
                    --Bone_length=execute("$" + Bone_Name + ".length") ---获取骨骼长度
                    Bone_length=boneobj.length ---获取骨骼长度
                    --Bone_length * 0.2
                    --skinOps.setEndPoint objSkin i [0,0,0]
                    skinOps.setEndPoint objSkin i [0,0,0]   ---重置当前ID骨骼结束封套点
                    skinOps.setStartPoint objSkin i [Bone_length,0,0]  ---重置当前ID骨骼开始封套点
                )
                Biped_Object :
                (
                    /*
                    bound = nodeGetBoundingBox boneobj boneobj.transform
                    selSize = ( bound[2] - bound[1] )

                    --skinOps.setEndPoint objSkin i [0,0,0]
                    skinOps.setStartPoint objSkin i [(selSize.z*0.5),0,0]
                    */
                )
            )
            Change_Weight.Bar.value = (i / skin_BoneNum) * 100
        )
        Change_Weight.Bar.value = 0
    )
)


-----------------------------------------------------------------------------------------------------------------------------

rollout Weight_optimization "权重优化" 
(
	

	button 'Batch_Remove_0.001' "0.001位"  width:55 height:21 toolTip:"去除0.001位权重"  across:3 
	
	button 'Batch_Remove_0.01' "0.01位"  width:55 height:21 toolTip:"去除0.01位权重" offset:[-30,0]
	
	button 'Skin_bone' "统计蒙皮骨骼"   height:21 tooltip:"将蒙皮骨骼生成skin_bone集合" offset:[-30,0]
	
	edittext 'BoneNumber' "蒙皮骨骼数:" width:140 offset:[80,0]
 
	
	global Bone_Name =#() 				---权重骨骼名字
	global objSkin
	
	local val_num =100   ---默认0.001
	global skin_num = 0 ---蒙皮骨骼数
	
	progressBar 'QR_bar' ""  color:(color 0 0 255) align:#left--进度条
--进度条
--进度条

	
	HyperLink 'lbl_help' "帮助"  address:"https://www.cgjoy.com/thread-212021-1-1.html" align:#center
	
	fn rounding_off val  = --- 四舍五入
	(

			val = (val*val_num+0.5) as integer
			
			val = (val as float)/val_num
			

	)
	
	fn round_off val  = --- 取整
	(

			val = (val*val_num) as integer
			
			val = (val as float)/val_num
			

	)
			
	
	
	
	fn SkinBoneId obj_Skin =
	(
		
		--skin_index=#{1.. bone_count} --骨骼蒙皮ID列表
		
		numSkinVerts = #{1..(skinOps.getNumberVertices obj_Skin)} --获取参与蒙皮的点
		
		local tem_id = #()
		local tem_val = #()
		
		for n=1 to numSkinVerts.count do
		(
			numBoneWeights = skinOps.getVertexWeightCount obj_Skin n    --每个点有几根骨骼影响
			
            for b=1 to numBoneWeights do
			(
				vertexWeight = skinOps.getVertexWeight objSkin n b --获取第n个点参与的第b个骨骼的ID
				
				tem_id[b]  = skinOps.getVertexWeightBoneID objSkin n b
				
				tem_val[b] = rounding_off vertexWeight 

			)
			
			tem = 1.0
			for b=numBoneWeights to 2 by -1 do
			(
				tem_val[b]=round_off tem_val[b]
				skinOps.SetVertexWeights objSkin n tem_id[b] tem_val[b]
				
				tem = tem - tem_val[b]
			)
			
			skinOps.SetVertexWeights objSkin n tem_id[1] tem

			QR_bar.value = 100-100.*n/numSkinVerts.count
		)
			QR_bar.value = 0
	)
	
	
----------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------
	
	fn Get_NumberBones = ---检查
	(
		if selection.count == 1 then	
		(
			max modify mode
			global objSkin  = $.modifiers[#Skin]
			skinOps.RemoveZeroWeights objSkin
			skin_num = skinOps.GetNumberBones objSkin
			

		)
		else
		(
			messageBox "选择单个模型 "

		)
		--	BoneNumber.text= skin_num as string
		--	skin_num = 0
	
		
	)
	
----------------------------------------------------------------------------------------------------------------------------	

	on Batch_Remove_0.001 pressed do
	(
		val_num =100
		Get_NumberBones ()
		
		SkinBoneId objSkin 
		

	)
	on Batch_Remove_0.01 pressed do
	(
		val_num =10
		Get_NumberBones ()
		SkinBoneId objSkin 
		
	)
	
	on Skin_bone pressed do
	(
		if selection.count == 1 then	
		(
			Get_NumberBones ()
			local TemName =#() 
			local Tem_Name =#()
			for i =1 to skin_num  do    
			(
				TemName = skinOps.GetBoneName objSkin i 1
				--if TemName != undefined do
				try (
						Tem_Name = execute ("$"+TemName)
					)
				catch
					(
						Tem_Name = execute ("$"+"'"+TemName+"'")
					)
				
			
				append Bone_Name Tem_Name
			

			)

			selectionSets["skin_bone"] = Bone_Name
		)

		else
		(
			messageBox "选择单个模型 "
		
			Bone_Name =#()
			
		)

		
		BoneNumber.text= skin_num as string
		skin_num = 0
	
	
	)

	
)
---------------------------------------------------------------------------------------------------------------------------
rollout About_Sign "使用指南" width:162 
(
	label b "周文、海贼"
	label c "409856476@qq.com"
	label e "2018.11"
	hyperlink lb2_help "使用教程" width:60 address:"https://www.cgjoy.com/forum.php?mod=viewthread&tid=216060&page=1&extra=#pid10680456" align:#center offset:[5,0]
)

	
	
----------------------------------------------------------------------------------------------------------------------------	




	AllRollout = newRolloutFloater "权重工具" 350 390
	addRollout About_Sign AllRollout
	addRollout paints AllRollout
	addRollout Weight_optimization AllRollout
	addRollout Change_Weight AllRollout
	addRollout Weight_Tool AllRollout

	About_Sign.open = false
	paints .open = true
	Weight_optimization .open = true

	Change_Weight.open = false

	Weight_Tool.open = false


