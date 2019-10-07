try (destroyDialog BoneMirrorTabs)
	catch()	


-- 20170222 判断最大关键帧范围函数
fn fn_AllKeyRange ObjArray = 
(
	AllKeyRange = #(0f,0f)
	for o in ObjArray do
	(
		try	TempRange1 = #(o.position.controller.keys[1].time,o.position.controller.keys[o.position.controller.keys.count].time)
			catch TempRange1 =#()
		try	TempRange2 = #(o.rotation.controller.keys[1].time,o.rotation.controller.keys[o.rotation.controller.keys.count].time)
			catch TempRange2 =#()
		try	TempRange3 = #(o.scale.controller.keys[1].time,o.scale.controller.keys[o.scale.controller.keys.count].time)
			catch TempRange3 =#()
				
		AllKeyRange = #(amin (AllKeyRange + TempRange1 + TempRange2 + TempRange3),amax (AllKeyRange + TempRange1 + TempRange2 + TempRange3))
	
	
	)
	return AllKeyRange
)

--20140609检测父物体是否有缩放 并返回缩放关键帧的各种参数
fn fnParentScale fnBoneBasic = 
	(
	local fnBoneFirstNode = #() --定义数组变量 所有镜像物体第一节骨骼的集合
	local fnIsScaleNode = #()	--定义数组变量 所有有带缩放的父物体的集合
	--检索镜像骨骼的所有第一节骨骼
	for i = 1 to fnBoneBasic.count do
		(
		try
			(	
			if findItem fnBoneFirstNode (getNodeByName (filterstring (getappdata fnBoneBasic[i] 100) "|")[2]).parent == 0 do
				append fnBoneFirstNode (getNodeByName (filterstring (getappdata fnBoneBasic[i] 100) "|")[2]).parent
			)
			catch()
		)
	for i= 1 to fnBoneFirstNode.count do
		(
		--新建一个变量 可以在不改变 fnBoneFirstNode 内容的情况下 循环拾取父物体	
		local fnScanNodeScale = fnBoneFirstNode[i]
		while true do
			(
			if fnScanNodeScale != undefined and classof FnScanNodeScale != Biped_Object then
				(
				try
					(
					--判断 当前是否有缩放值 or 是否存在缩放的关键帧  是则添加进选中集合
					if fnScanNodeScale.controller.scale != [1,1,1] or fnScanNodeScale.controller.scale.keys.count > 1 do
						if (findItem fnIsScaleNode fnScanNodeScale) == 0 do --检测物体是否已经被选中
							(
							local fnKeyInf = #() --临时变量 用于转接关键帧信息以及缩放信息
							--按照指定格式存入数组 #(物体名字,#(关键帧1,缩放值1,贝塞尔手柄信息)......)
							fnKeyInf[1]= fnScanNodeScale
							if fnScanNodeScale.controller.scale.keys.count > 0 then
								for x = 1 to fnScanNodeScale.controller.scale.keys.count do
									(
									fnKeyInf[x+1] = #(fnScanNodeScale.controller.scale.keys[x].time,fnScanNodeScale.controller.scale.keys[x].value)
									--判断曲线是否为贝塞尔类型 是则将手柄信息存入第三个数据位: #(.inTangentType,.inTangent,.inTangentLength,.outTangentType,.outTangent,.outTangentLength)
									if (classof fnScanNodeScale.scale.controller) == bezier_scale do 
										fnKeyInf[x+1][3] = #(fnScanNodeScale.scale.controller.keys[x].inTangentType,fnScanNodeScale.scale.controller.keys[x].inTangent,fnScanNodeScale.scale.controller.keys[x].inTangentLength,fnScanNodeScale.scale.controller.keys[x].outTangentType,fnScanNodeScale.scale.controller.keys[x].outTangent,fnScanNodeScale.scale.controller.keys[x].outTangentLength)
									)
								else fnKeyInf[2] = #(0f,fnScanNodeScale.controller.scale)--Scale Key为0 但是又有缩放的 做此特殊处理
							--将按规定格式处理好的数据 放入所有带缩放的父物体集合中
							append fnIsScaleNode fnKeyInf
							)
					fnScanNodeScale = fnScanNodeScale.parent
					)
					catch exit
				)
				else exit
			)
		)
	return fnIsScaleNode
	)--检测父物体是否有缩放函数结束

--20140609清除缩放值函数	
fn fnParentScaleClear fnIsScaleNode = 
	(
	--处理指定格式输入的数组 #(物体名字,#(关键帧1,缩放值1,帧状态信息)......)
	--缩放及关键帧值清零
	for i = 1 to fnIsScaleNode.count do
		(
		for x = 2 to fnIsScaleNode[i].count do 
			(
			try
				(
				--print ("i= "+i as string+" x="+ x as string)
				--判断缩放关键帧是否有关键帧 无则在0帧插入一个关键帧
				if fnIsScaleNode[i][1].controller.scale.keys.count == 0 do
					addNewKey fnIsScaleNode[i][1].controller.scale.keys 0f
				--将所有缩放关键帧的值 重置为1
				fnIsScaleNode[i][1].controller.scale.keys[x-1].value = [1,1,1]
				--判断曲线类型是否为贝塞尔类型 是则把手柄清零
				--if fnScanNodeScale.controller.scale.keys.count > 0 do
				--	(
					if (classof fnIsScaleNode[i][1].scale.controller) == bezier_scale do 
						(
						fnIsScaleNode[i][1].scale.controller.keys[x-1].inTangent = [0,0,0]
						fnIsScaleNode[i][1].scale.controller.keys[x-1].inTangentLength = [0,0,0]
						fnIsScaleNode[i][1].scale.controller.keys[x-1].outTangent = [0,0,0]
						fnIsScaleNode[i][1].scale.controller.keys[x-1].outTangentLength = [0,0,0]
						)
				--	)
				)
				catch()
			)
		)	
	)--清除缩放值函数结束
	
--20140609根据参数恢复缩放及关键帧信息函数
fn fnParentScaleRecover fnIsScaleNode =
	(
	--try
--	(

-- 出错！！！！！！ 当物体没有缩放关键帧的时候 没有输入关键帧的曲线信息 导致重新赋予曲线信息出错
	for i = 1 to fnIsScaleNode.count do
		(
		for x = 2 to fnIsScaleNode[i].count do 
			(
			try 
			fnIsScaleNode[i][1].controller.scale.keys[x-1].value = fnIsScaleNode[i][x][2]
			catch()
			--判断曲线类型是否为贝塞尔类型 是则重新写入手柄信息
			if (classof fnIsScaleNode[i][1].scale.controller) == bezier_scale and fnIsScaleNode[i][1].controller.scale.keys.count > 0 do 
				(
				try
				(
				fnIsScaleNode[i][1].scale.controller.keys[x-1].inTangent = fnIsScaleNode[i][x][3][2]
				fnIsScaleNode[i][1].scale.controller.keys[x-1].inTangentLength = fnIsScaleNode[i][x][3][3]
				fnIsScaleNode[i][1].scale.controller.keys[x-1].inTangentType = fnIsScaleNode[i][x][3][1]
				fnIsScaleNode[i][1].scale.controller.keys[x-1].outTangent = fnIsScaleNode[i][x][3][5]
				fnIsScaleNode[i][1].scale.controller.keys[x-1].outTangentLength = fnIsScaleNode[i][x][3][6]
				fnIsScaleNode[i][1].scale.controller.keys[x-1].outTangentType = fnIsScaleNode[i][x][3][4]
				)
				catch()
				)
			)
		)
	--)
	--catch()
	)--恢复缩放函数结束

-- 寻找镜像根节点函数
fn BoneMirror_FindRoot BoneMirror_Before BoneMirror_After = 
	(
	if BoneMirror_Before.parent != undefined do
		(
		--判断根节点的父物体是否为bip的半侧 如是 则将BoneMirror_After的父物体改为另外一侧
		NodeRoot = (filterstring BoneMirror_Before.parent.name " ")
		if NodeRoot[2] == "R" then	BoneMirror_After.parent = getnodebyname (NodeRoot[1]+" L "+NodeRoot[3])
			else if NodeRoot[2] == "L" do BoneMirror_After.parent = getnodebyname (NodeRoot[1]+" R "+NodeRoot[3])
		if BoneMirror_Before.parent == BoneMirror_After.parent or NodeRoot[2] == "R" or NodeRoot[2] == "L" then 
			(
			return #(BoneMirror_Before,BoneMirror_After)
			)
		else BoneMirror_FindRoot BoneMirror_Before.parent BoneMirror_After.parent
		)
	)
		
--通过第一节骨骼 按顺序拾取子节点函数
fn addChildren AllObj_New_AC theRoot AllObj_AC = 
	(
	if theRoot != undefined do 
		(		
		for c in theRoot.children do
			(
			if ( findItem AllObj_AC c ) != 0 do 
				(
				append AllObj_New_AC c
				)
			addChildren AllObj_New_AC c AllObj_AC
			)
		)
	)
	
--骨骼选择集 重新整理排序函数
--(有bug 都是从一根骨骼系的根节点开始寻找 返回整条骨骼链 而不是选中的物体 需要修改) 20111010已解决
fn BoneMirror_SortObj AllObj = 
	(
	AllObj_Root = #()
	for c in AllObj do
		(
		try
			(
			Temp_Obj = (getnodebyname (filterstring (getappdata c 100) "|")[2])
			if ( findItem AllObj_Root Temp_Obj ) == 0 do append AllObj_Root Temp_Obj
			)
		catch ()
		)
	AllObj_New = #()
	
	for i = 1 to AllObj_Root.count do 
		(			
		if ( findItem AllObj AllObj_Root[i] ) != 0 do append AllObj_New AllObj_Root[i]
	 	AddChildren AllObj_New AllObj_Root[i] AllObj
		)
	return AllObj_New
	)
	
--位置镜像函数
--20150807 添加范围判断参数
--fn BoneMirror_BeginMirror BoneMirror_fnBasic MirrorRange =
fn BoneMirror_BeginMirror BoneMirror_fnBasic  =
	(	
	--开始镜像计算
	for i = 1 to BoneMirror_fnBasic.count do
		(
	--	try
			(				
			--取得写在物体 ID:100 中的 物体名、镜像物体名、以及各自的镜像父物体、父物体坐标和世界坐标的偏移四元数、和镜像物体的旋转、位移差值
			BoneMirror_Obj_array = (filterstring (getappdata BoneMirror_fnBasic[i] 100) "|")
			--BoneMirror_Obj_Mirror = getnodebyname ( filterstring (getappdata (getnodebyname BoneMirror_Obj_Array[2]) 100) "|")[1]
			BoneMirror_Obj_Mirror = getnodebyname BoneMirror_Obj_array[1]
			
			--BoneMirror_Obj_Mirror = getnodebyname (filterstring (getappdata BoneMirror_fnBasic[i] 100) "|")[1]
			ObjDifferent = execute (filterstring(getappdata BoneMirror_Obj_Mirror 100) "|")[4]
			BoneMirror_Obj = #(BoneMirror_fnBasic[i] , getnodebyname BoneMirror_Obj_array[1] , getnodebyname BoneMirror_Obj_array[2] , execute BoneMirror_Obj_array[3], getnodebyname ( filterstring (getappdata BoneMirror_Obj_Mirror 100) "|")[2] ,execute ( filterstring (getappdata BoneMirror_Obj_Mirror 100) "|")[3])
			--镜像动画语句
			if BoneMirror_Obj[3].parent != undefined then 
				(
				--BoneMirror_Obj[2].transform = prerotatez (orthogonalize (BoneMirror_Obj[1].transform * inverse (PreRotate BoneMirror_Obj[3].parent.transform BoneMirror_Obj[4]) * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0]) * (PreRotate BoneMirror_Obj[5].parent.transform BoneMirror_Obj[6]))) 180
				MirrorTransform = prerotatez (orthogonalize (BoneMirror_Obj[1].transform * inverse (PreRotate BoneMirror_Obj[3].parent.transform BoneMirror_Obj[4]) * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0]) * (PreRotate BoneMirror_Obj[5].parent.transform BoneMirror_Obj[6]))) 180				
				BoneMirror_Obj[2].transform = preRotateX MirrorTransform ObjDifferent[1]
				BoneMirror_Obj[2].transform =  preRotatey MirrorTransform ObjDifferent[2]
				BoneMirror_Obj[2].transform =  preRotatez MirrorTransform ObjDifferent[3]
				BoneMirror_Obj[2].transform = translate MirrorTransform ObjDifferent[4]
				)
				else 
				(
				--BoneMirror_Obj[2].transform = prerotatez (orthogonalize (BoneMirror_Obj[1].transform  * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])  )) 180		
				MirrorTransform = prerotatez (orthogonalize (BoneMirror_Obj[1].transform  * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])  )) 180	
				BoneMirror_Obj[2].transform = preRotateX MirrorTransform ObjDifferent[1]
				BoneMirror_Obj[2].transform =  preRotatey MirrorTransform ObjDifferent[2]
				BoneMirror_Obj[2].transform =  preRotatez MirrorTransform ObjDifferent[3]
				BoneMirror_Obj[2].transform = translate MirrorTransform ObjDifferent[4]
				)
			)
		--	catch()
		)--镜像计算循环结束
	)
	
--写入骨骼差异值函数
fn BoneMirror_CreatDifferent Bone_Basic_CreatDifferent =
	(
	for i = 1 to Bone_Basic_CreatDifferent.count do
		(
		--取出基础关联数值进行计算
		BoneMirror_Obj_array_CD = (filterstring (getappdata Bone_Basic_CreatDifferent[i] 100) "|")
		--BoneMirror_Obj_Mirror_CD = getnodebyname ( filterstring (getappdata (getnodebyname BoneMirror_Obj_array_CD[2]) 100) "|")[1]
		BoneMirror_Obj_Mirror_CD = getnodebyname BoneMirror_Obj_array_CD[1]
		BoneMirror_Obj_CD = #(Bone_Basic_CreatDifferent[i] ,getnodebyname BoneMirror_Obj_array_CD[1] , getnodebyname BoneMirror_Obj_array_CD[2] , execute BoneMirror_Obj_array_CD[3], getnodebyname ( filterstring (getappdata BoneMirror_Obj_Mirror_CD 100) "|")[2] ,execute ( filterstring (getappdata BoneMirror_Obj_Mirror_CD 100) "|")[3])
		--取得Bone_Basic_CreatDifferent镜像之后基本运动矩阵
		BasicTransform = prerotatez (orthogonalize (BoneMirror_Obj_CD[1].transform * inverse (PreRotate BoneMirror_Obj_CD[3].parent.transform BoneMirror_Obj_CD[4]) * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0]) * (PreRotate BoneMirror_Obj_CD[5].parent.transform BoneMirror_Obj_CD[6]))) 180
		--取得Bone_Mirror镜像物体与基本运动矩阵之间的差值
		ObjDifferent = #()
		ObjDifferent[1] = (BoneMirror_Obj_Mirror_CD.transform.rotation as eulerAngles).x - (BasicTransform.rotation as eulerangles).x
		ObjDifferent[2] = (BoneMirror_Obj_Mirror_CD.transform.rotation as eulerAngles).y - (BasicTransform.rotation as eulerangles).y
		ObjDifferent[3] = (BoneMirror_Obj_Mirror_CD.transform.rotation as eulerAngles).z - (BasicTransform.rotation as eulerangles).z
		ObjDifferent[4] = BoneMirror_Obj_Mirror_CD.transform.pos - BasicTransform.pos
		--继续写入镜像骨骼偏差值
		setappdata BoneMirror_Obj_Mirror_CD 100 ( getappdata BoneMirror_Obj_Mirror_CD 100 +"|"+ ObjDifferent as string )
		--print (getappdata Bone_Basic_CreatDifferent[i] 100)
		)
	)

--初始物体和镜像物体进行关联函数 并写入值 ID:100
fn BoneMirror_ContactOBj Bone_Basic_ContactOBj Bone_Mirror_ContactOBj = 
	(
	--写入基础关联数值
	for i = 1 to Bone_Basic_ContactOBj.count do
		(			
		Bone_Information = BoneMirror_FindRoot Bone_Basic_ContactOBj[i] Bone_Mirror_ContactOBj[i]
		deleteAppData Bone_Basic_ContactOBj[i] 100
		setappdata Bone_Basic_ContactOBj[i] 100 (Bone_Mirror_ContactOBj[i].name + "|" + Bone_Information[1].name as string + "|" +((quat 0 0 0 1) - Bone_Information[1].parent.transform.rotation) as string )
		deleteAppData Bone_Mirror_ContactOBj[i] 100
		setappdata Bone_Mirror_ContactOBj[i] 100 (Bone_Basic_ContactOBj[i].name + "|" + Bone_Information[2].name as string + "|" +((quat 0 0 0 1) - Bone_Information[2].parent.transform.rotation) as string )
		)
	)

--追加选择集内容函数
fn AppendSets NewSets NodesArray =
	(
	OldSets = #()
	if selectionSets[NewSets] != undefined do
		(
		for i = 1 to selectionSets[NewSets].count do OldSets[i] = selectionSets[NewSets][i]
		)
	selectionSets[NewSets] = OldSets + NodesArray
	)
	
--界面区
--rollout firstRollout "动画镜像" width:197 height:240
rollout BoneMirrorTabs "动画镜像工具" width:197 height:314
(
	GroupBox grp2 "" pos:[8,7] width:184 height:283	
	GroupBox grp4 "" pos:[11,12] width:178 height:84	
	GroupBox grp32 "" pos:[11,94] width:178 height:55
	GroupBox grp3 "" pos:[11,146] width:178 height:77
	button btn_Bone_Mirror "骨骼镜像" pos:[23,24] width:95 height:28 toolTip:"将选中的骨骼进行自动镜像复制"
	button btn_ReadMe "说明" pos:[128,24] width:50 height:28 toolTip:"注意事项"
	checkbutton btn_Bone_Mirror_ContactObj "手动关联骨骼" pos:[23,62] width:95 height:28 toolTip:"手动按顺序点击原始骨骼、需要镜像的骨骼，点击完自动进行关联操作，鼠标右键返回"
	checkbutton btn_TestContactObj "检查" pos:[128,62] width:50 height:28 toolTip:"点选任意一根骨骼，检查骨骼是否已关联，正确则两根关联骨骼均显示红色，鼠标右键返回"
	button btn_SetRangeStart "<" pos:[118,109] width:20 height:16 enabled:false tooltip:"将当前帧设定为起始帧"
	button btn_SetRangeEnd ">" pos:[118,128] width:20 height:16 enabled:false tooltip:"将当前帧设定为结束帧"
	button btn_SetRangeAll "<..>" pos:[145,110] width:32 height:33 enabled:false tooltip:"将当前帧范围设定为起始结束帧"
	spinner spn_MirrorRangeStart "起始帧" pos:[33,108] width:80 height:16 enabled:false range:[-9999,9999,0] type:#integer scale:1
	spinner spn_MirrorRangeEnd "结束帧" pos:[33,128] width:80 height:16 enabled:false range:[-9999,9999,0] type:#integer scale:1
	radiobuttons rdo_MirrorRange "镜像范围" pos:[23,163] width:51 height:46 labels:#("全局", "自定") default:1 columns:1
	button btn_SingleFrame_Mirror "单帧镜像" pos:[85,156] width:95 height:25 toolTip:"镜像选中的、已关联的骨骼的单帧状态"
	button Btn_Animation_Mirror "镜像动画" pos:[85,186] width:95 height:32 toolTip:"镜像选中的、已关联的骨骼动画"
	--checkbox chk_Key_Full "满帧" pos:[23,208] width:51 height:22
	label lbl1 "天晴数码动作组专用" pos:[18,235] width:162 height:16 enabled:true
	label lbl11 "Bone动画镜像工具2.0a" pos:[18,251] width:162 height:18
	label lbl3 "- 20170222 - by 刘星 李骅" pos:[45,269] width:140 height:17

	
	
	
	--按钮功能区


	on btn_Bone_Mirror pressed do --镜像骨骼按钮
	(
	--try
		(
		undo on
			(
			animate off
				(
				Bone_Basic = selection as array
				--检查选中的物体中 是否有已被关联的
				for c in Bone_Basic do
					(
					try
						(
						temp_c = getNodebyName ((filterstring (getappdata c 100) "|")[1])
						
						if c == getNodebyName ((filterstring (getappdata temp_c 100) "|")[1]) do
							(
							if queryBox ("选中的骨骼 \""+ c.name +"\" 已被关联 是否继续镜像？") title:"请选择" beep:true then
								(
		 						print (c.name +" ok")
								)
								else return ()
							)
						)
						catch()					
					) 
				maxOps.cloneNodes Bone_Basic offset:[-200,0,0] cloneType:#copy newNodes:&Bone_Mirror --复制骨骼
				Bone_Mirror.wirecolor = color 177 27 88
				--清除被镜像骨骼的关键帧
				deleteKeys Bone_Mirror #allKeys
				--将镜像物体更名
				for i = 1 to Bone_Basic.count do Bone_Mirror[i].name = Bone_Basic[i].name + "_m"		
		
				--分选镜像物体以及末端根节点 并存进相应的选择集
				Bone_Basic_End = #()
				Bone_Mirror_End = #()		
				for c in Bone_Basic do 
					(
					if c.children.count == 0 do 
						(
						append Bone_Basic_End  c
						deleteItem Bone_Basic (findItem Bone_Basic c)
						)
					)
				for c in Bone_Mirror do 
					(
					if c.children.count == 0 do 
						(
						append Bone_Mirror_End  c
						deleteItem Bone_Mirror (findItem Bone_Mirror c)
						)
					)
				 --selectionSets["Bone_Basic"] = Bone_Basic
				 --selectionSets["Bone_Mirror"] = Bone_Mirror
				 --selectionSets["Bone_Basic_End"] = Bone_Basic_End
				 --selectionSets["Bone_Mirror_End"] = Bone_Mirror_End
				--AppendSets "Bone_Basic" Bone_Basic
				--AppendSets "Bone_Mirror" Bone_Mirror
				--AppendSets "Bone_Basic_End" Bone_Basic_End
				--AppendSets "Bone_Mirror_End" Bone_Mirror_End
				 
				 hide Bone_Mirror_End
				 hide Bone_Basic_End
				 select Bone_Basic		
		
				--调用初始物体和镜像物体进行关联函数 并写入值 ID:100
				--出错！！！！！ 在镜像动画之前 就进行差值比对 返回的值不正确 需要在镜像动画之后再进行处理（分离两个函数 使其单独作用？）20111008已解决
				BoneMirror_ContactOBj Bone_Basic Bone_Mirror
				--追加预置的零偏移值 并写入ID:100w
				for i = 1 to Bone_Basic.count do
					(
					objID = filterstring (getappdata Bone_Basic[i] 100) "|"
					setappdata Bone_Basic[i] 100  (objID[1] + "|" + objID[2] + "|" + objID[3] + "|" + #(0, 0, 0, [0,0,0]) as string )
					objID = filterstring (getappdata Bone_Mirror[i] 100) "|"
					setappdata Bone_Mirror[i] 100  (objID[1] + "|" + objID[2] + "|" + objID[3] + "|" + #(0, 0, 0, [0,0,0]) as string )	
					)						
				Bone_Basic = BoneMirror_SortObj Bone_Basic --调用骨骼选择集重新整理排序函数
				--检索参与镜像骨骼所有有带缩放的父物体
				IsScaleNode = fnParentScale Bone_Basic					
				--清除所有所有父物体的缩放值
				fnParentScaleClear IsScaleNode
					
				--保存Bone_Basic的缩放值 并重置缩放
				Bone_Basic_ScaleValue = #()
				for i = 1 to Bone_Basic.count do
					(
					Bone_Basic_ScaleValue[i] = Bone_Basic[i].controller.scale
					Bone_Basic[i].controller.scale = [1,1,1]
					)
				BoneMirror_BeginMirror Bone_Basic --调用动画镜像函数
				--写回缩放值
				for i = 1 to Bone_Basic.count do
					(
					Bone_Basic[i].controller.scale = Bone_Basic_Scalevalue[i]
					(getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1]).controller.scale = Bone_Basic_Scalevalue[i]		
					)
				--	break ()
				print IsScaleNode
				IsScaleNode
				--恢复父物体的缩放值
				fnParentScaleRecover IsScaleNode
				)
			)
		)
	--	catch messagebox "骨骼镜像错误。应该选择整条骨骼链进行镜像，包括根节点。"
	)
	on btn_ReadMe pressed do
		messagebox "注意事项：\n\n1 镜像骨骼的父物体必须保持初始绑点形态。骨骼以其父物体坐标为中心，沿世界坐标的Z轴左右镜像。\n   镜像骨骼时，必须全选需要镜像的骨骼,包括末端。\n   镜像动画时无此要求，选中哪个部分就镜像哪个部分的动作，选择任何一侧的骨骼均有效。  \n\n 2 手动关联骨骼的时候，也必须在骨骼标准绑点状态下进行。\n\n 3 在骨骼上制作单轴缩放动画时，切记选择该物体的Local坐标进行缩放。\n   如果选择的的是Word坐标轴进行单轴缩放，镜像的时候会返回不正确的情况。\n\n 4 骨骼链中，某一根骨骼存在缩放动画时（尤其是单轴缩放）。由于坐标系产生变形，\n   所以镜像动画时，应全选该骨骼以下的所有骨骼一起镜像，否则可能产生不正确的动画 "
	on btn_Bone_Mirror_ContactObj changed state do --手动关联按钮
	(
	undo on
		(
		if state do 
			(
			btn_Bone_Mirror_ContactObj.enabled = false
			while true do 
				(				
				try 
					(
					--写入偏移值函数只对数组变量起作用 所以单个拾取的物体也要用数组的方式定义
					Bone_Basic_Contact = #()
					Bone_Mirror_Contact = #()
					--拾取骨骼
					Bone_Basic_Contact[1] = pickObject select:true  --prompt:"002"
					if Bone_Basic_Contact[1] == undefined do 
						(
						--print "loop exit"
						exit
						)
					--改变颜色
					Basic_WireColor = Bone_Basic_Contact[1].WireColor
					Bone_Basic_Contact[1].WireColor = (color 255 0 0)		
					--拾取镜像骨骼
					Bone_Mirror_Contact[1] = pickObject rubberBand:Bone_Basic_Contact[1].pos 
					
					if Bone_Mirror_Contact[1] == undefined do 
						(
						--print "loop exit"
						Bone_Basic_Contact[1].WireColor = Basic_WireColor
						exit
						)
					selectmore Bone_Mirror_Contact[1]
					Mirror_WireColor = Bone_Mirror_Contact[1].WireColor
					Bone_Mirror_Contact[1].WireColor = (color 255 0 0)				
					--调用写入关联参数函数
					BoneMirror_ContactOBj Bone_Basic_Contact Bone_Mirror_Contact
					--调用写入偏移值函数
					BoneMirror_CreatDifferent Bone_Basic_Contact
					BoneMirror_CreatDifferent Bone_Mirror_Contact
				
				    	print ("关联" + Bone_Basic_contact[1].name + ">> "+ Bone_Mirror_Contact[1].name +"成功~") 
					selectObj = selection as array
					clearSelection()
					--延迟并闪烁3次 共500毫秒
					redrawViews()
					TimeDelay = Timestamp()
					while true do if Timestamp() - TimeDelay > 150 do exit		
					Bone_Basic_Contact[1].WireColor = Basic_WireColor
					Bone_Mirror_Contact[1].WireColor = Mirror_WireColor
					select selectObj
					redrawViews()
					
					TimeDelay = Timestamp()
					while true do if Timestamp() - TimeDelay > 150 do exit		
					Bone_Basic_Contact[1].WireColor = (color 255 0 0)
					Bone_Mirror_Contact[1].WireColor = (color 255 0 0)
					clearSelection()
					redrawViews()
	
					TimeDelay = Timestamp()
					while true do if Timestamp() - TimeDelay > 200 do exit		
					Bone_Basic_Contact[1].WireColor = Basic_WireColor 
					Bone_Mirror_Contact[1].WireColor = Mirror_WireColor
					select selectObj
					redrawViews()					
					)
					catch 
					(
					Bone_Basic_Contact[1].WireColor = Basic_WireColor
					Bone_Mirror_Contact[1].WireColor = Mirror_WireColor
					)
				)				
			btn_Bone_Mirror_ContactObj.checked = false
			btn_Bone_Mirror_ContactObj.enabled = true
			)		
		)
	)
	on btn_TestContactObj changed state do --检查是否关联
	(
	undo off
	(
		if state do
			(
			btn_TestContactObj.enabled = false
			try (
				Test_WireColor = #()
				Test_WireColor_2 = #()
				while true do 
					(		
					--拾取骨骼
					Bone_Test_Contact = pickObject ()  	
					select Bone_Test_Contact		
					try Bone_Test_Contact_2.WireColor = Test_WireColor_2[1] catch()	
					try (getNodebyname (filterstring (getappdata Bone_Test_Contact_2 100) "|")[1]).WireColor = Test_WireColor_2[2]	catch()			
					if Bone_Test_Contact == undefined do exit
					Test_WireColor[1] = Bone_Test_Contact.WireColor
					Bone_Test_Contact.WireColor = (color 255 0 0)
					try 
						(
						 Bone_Test_ContactMirror = getNodebyname (filterstring (getappdata Bone_Test_Contact 100) "|")[1]
						if Bone_Test_Contact == getNodebyName ((filterstring (getappdata Bone_Test_ContactMirror 100) "|")[1]) do
							(					
							Test_WireColor[2] = Bone_Test_ContactMirror.WireColor 
							Bone_Test_ContactMirror.WireColor = (color 255 0 0)
							selectMore Bone_Test_ContactMirror
							)
						)
						catch()
					Bone_Test_Contact_2 = pickObject ()
					select Bone_Test_Contact_2
					try Bone_Test_Contact.WireColor = Test_WireColor[1] catch()	
					try (getNodebyname (filterstring (getappdata Bone_Test_Contact 100) "|")[1]).WireColor = Test_WireColor[2]	catch()			
					if Bone_Test_Contact_2 == undefined do exit
					try Bone_Test_Contact.WireColor = Test_WireColor[1] catch()
					try (getNodebyname (filterstring (getappdata Bone_Test_Contact 100) "|")[1]).WireColor = Test_WireColor[2]	catch()
					Test_WireColor_2[1] = Bone_Test_Contact_2.WireColor
					Bone_Test_Contact_2.WireColor = (color 255 0 0)
					try 
						(
						Bone_Test_ContactMirror_2 = getNodebyname (filterstring (getappdata Bone_Test_Contact_2 100) "|")[1]
						if Bone_Test_Contact_2 == getNodebyname ((filterstring (getappdata Bone_Test_ContactMirror_2 100) "|")[1]) do
							(
							Test_WireColor_2[2] = Bone_Test_ContactMirror_2.WireColor 
							Bone_Test_ContactMirror_2.WireColor = (color 255 0 0)
							selectMore Bone_Test_ContactMirror_2
							)
						)
						catch()		
					)
				)
				catch()
			try Bone_Test_Contact.WireColor = Test_WireColor[1] catch()
			try (getNodebyname (filterstring (getappdata Bone_Test_Contact 100) "|")[1]).WireColor = Test_WireColor[2]	catch()
			try Bone_Test_Contact_2.WireColor = Test_WireColor_2[1] catch()
			try (getNodebyname (filterstring (getappdata Bone_Test_Contact_2 100) "|")[1]).WireColor = Test_WireColor_2[2]	catch()
			clearSelection()
			)
		btn_TestContactObj.checked = false
		btn_TestContactObj.enabled = true
		)
	)
	on rdo_MirrorRange changed state do --镜像范围选择
	(
		case state of
		(
		1: (
			spn_MirrorRangeStart.enabled = false
			spn_MirrorRangeEnd.enabled = false
			btn_SetRangeStart.enabled = false
			btn_SetRangeEnd.enabled = false
			btn_SetRangeAll.enabled = false
			)
		2: (
			spn_MirrorRangeStart.enabled = true
			spn_MirrorRangeEnd.enabled = true 
			btn_SetRangeStart.enabled = true
			btn_SetRangeEnd.enabled = true
			btn_SetRangeAll.enabled = true
			spn_MirrorRangeStart.value = animationRange.start
			spn_MirrorRangeEnd.value = animationRange.end
			)
		)
	)
	on btn_SetRangeStart pressed do --指定当前帧为帧范围开始按钮
	(
	spn_MirrorRangeStart.value = int sliderTime
	if spn_MirrorRangeEnd.value <= spn_MirrorRangeStart.value do spn_MirrorRangeEnd.value = spn_MirrorRangeStart.value + 1
	)
	on btn_SetRangeEnd pressed do --指定当前帧为帧范围结束按钮
	(
	spn_MirrorRangeEnd.value = int sliderTime
	if spn_MirrorRangeStart.value >=  spn_MirrorRangeEnd.value do spn_MirrorRangeStart.value = spn_MirrorRangeEnd.value - 1
	)
	on spn_MirrorRangeStart changed val do
	(
	if spn_MirrorRangeEnd.value <= spn_MirrorRangeStart.value do spn_MirrorRangeEnd.value = spn_MirrorRangeStart.value + 1
	)
	on spn_MirrorRangeEnd changed val do
	(
	if spn_MirrorRangeStart.value >=  spn_MirrorRangeEnd.value do spn_MirrorRangeStart.value = spn_MirrorRangeEnd.value - 1	
	)
	on btn_SetRangeAll pressed do 
		(
		spn_MirrorRangeStart.value = animationRange.start
		spn_MirrorRangeEnd.value = animationRange.end
		)
	on Btn_Animation_Mirror pressed do 	--开始镜像动画按钮
		(	
		undo on 
			(
			--try			
				(
				--disableSceneRedraw()
				animate on
					(
					if selection.count > 0 do 
						(
						--调用骨骼选择集重新整理排序函数
						Bone_Basic = BoneMirror_SortObj (selection as array) 				
						--检查父物体是否被选中 如有则清除
						for o in Bone_Basic do 
							(
							if (getappdata o 100) == "" or (getappdata o 100) == undefined do 
								deleteItem Bone_Basic (findItem aa o)
								)
						--保存Bone_Basic的缩放值 并重置缩放
						
						Bone_Basic_ScaleValue = #()
						for i = 1 to Bone_Basic.count do
							(
							--判断 如果不是IK解算器物体 则开始进行缩放值记录
							
							--断点20140612
							
							--判断控制器类型 进行分别处理
							case classof Bone_Basic[i].controller of
								(
								IKControl: Bone_Basic_ScaleKey = Bone_Basic[i].controller.FK_Sub_Control.scale.keys
								prs: Bone_Basic_ScaleKey =  Bone_Basic[i].controller.scale.keys
								)
						
							--Bone_Basic_ScaleKey = Bone_Basic[i][3][3].keys
							TempScaleValue = #()
							for ScaleKeyTime in 1 to Bone_Basic_ScaleKey.count do 
								at time Bone_Basic_ScaleKey[ScaleKeyTime].time
									(
									TempScaleValue[ScaleKeyTime] = Bone_Basic[i].controller.scale
									Bone_Basic[i].controller.scale = [1,1,1]
									)
							Bone_Basic_Scalevalue[i] = TempScaleValue
								
							)
						--print ("缩放值 = "+Bone_Basic_Scalevalue as string)
						--检索参与镜像骨骼所有有带缩放的父物体
						IsScaleNode = fnParentScale Bone_Basic					
						--清除所有所有父物体的缩放值
						fnParentScaleClear IsScaleNode
						
						--删除另一侧骨骼的所有动画
						--20170222 修改为根据选项来确定 范围之外不清除对象的关键帧
						case rdo_MirrorRange.state of
							(
							1:
								(
								try 
									(
									for i = 1 to Bone_Basic.count do	deleteKeys (getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1]) #allKeys
									)
								catch() 
								)
							2:
								(							
								try 
									(
									for i = 1 to Bone_Basic.count do	
										(
										MirrorObj = (getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1])
										deselectKeys MirrorObj
										selectKeys MirrorObj (spn_MirrorRangeStart.value as time) (spn_MirrorRangeEnd.value as time)
										deleteKeys MirrorObj #selection
										)
									)
								catch() 	
								)
							)
											--(
						--	messagebox "镜像物件不存在，请检查场景"
						--	enableSceneRedraw()
						--	redrawViews()
						--	return()
							--)
						--动画范围内循环满帧镜像
						-- 20170222 添加镜像范围判断
						--取得工作区间的帧范围
						TimeRange  = #(0f,0f)
						case rdo_MirrorRange.state of
							(
							1:
								(
								AllObjkeyRange = fn_AllKeyRange Bone_Basic
								TimeRange[1] = AllObjkeyRange[1]
								TimeRange[2] = AllObjkeyRange[2]
								)
							2:
								(
								TimeRange[1] = spn_MirrorRangeStart.value as time
								TimeRange[2] = spn_MirrorRangeEnd.value as time
								)
							)
						for x in TimeRange[1] to TimeRange[2] do 
							(
							at time (x as time)
								BoneMirror_BeginMirror Bone_Basic --调用动画镜像函数
							)
						--写回原始骨骼的缩放值
						for i = 1 to Bone_Basic.count do
							(
							try
								(
								Bone_Basic_ScaleKey = Bone_Basic[i][3][3].keys									
								for ScaleKeyTime in 1 to Bone_Basic_ScaleKey.count do 
									(
									at time Bone_Basic_ScaleKey[ScaleKeyTime].time
										(
										Bone_Basic[i].controller.scale = Bone_Basic_Scalevalue[i][ScaleKeyTime]
										
										--20170222添加范围判断 超过范围则对目标不写入缩放关键帧
										case rdo_MirrorRange.state of
											(
											1:
												(getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1]).controller.scale = Bone_Basic_Scalevalue[i][ScaleKeyTime]
											2:
												if Bone_Basic_ScaleKey[ScaleKeyTime].time <= spn_MirrorRangeEnd.value do
														(getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1]).controller.scale = Bone_Basic_Scalevalue[i][ScaleKeyTime]
											)
										)
									)
								)
								catch ()			
							)				
						--判断满帧是否勾选 否则删除另一侧骨骼的多余关键帧 20170222 删除满帧功能
						-- if not chk_Key_Full.checked do
							(
							for i = 1 to Bone_Basic.count do
								(
								try
									(
										/*
									--取得工作区间的帧范围
									TimeRange  = #(0f,0f)
									case rdo_MirrorRange.state of
									(
										1:
										(
										
											TimeRange[1] = animationRange.start
											TimeRange[2] = animationRange.end
											
											)
										2:
										(
											TimeRange[1] = spn_MirrorRangeStart.value as time
											TimeRange[2] = spn_MirrorRangeEnd.value as time
											
											--test
											--TimeRange[1] = 0 as time
											--TimeRange[2] = 20 as time
											
											)
										
										)
										*/
									for controller_Type = 1 to 3 do --对位移、旋转、缩放三种控制器进行操作的循环
										(
										--取得源物体的关键帧数组
										Key_Time = #()
										--for Key_count = 1 to Bone_Basic[i][3][controller_Type].keys.count do Key_Time[Key_count] = Bone_Basic[i][3][controller_Type].keys[Key_count].time					
										case controller_Type of
											(
											1: for Key_count = 1 to Bone_Basic[i].position.controller.keys.count do Key_Time[Key_count] = Bone_Basic[i].position.controller.keys[Key_count].time
											2: for Key_count = 1 to Bone_Basic[i].rotation.controller.keys.count do Key_Time[Key_count] = Bone_Basic[i].rotation.controller.keys[Key_count].time
											3: for Key_count = 1 to Bone_Basic[i].scale.controller.keys.count do Key_Time[Key_count] = Bone_Basic[i].scale.controller.keys[Key_count].time
											)
										--取得目标物体的Keys
										case controller_Type of
											(
											1: Keys_MirrorObjKeys =  (getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1]).position.controller.keys
											2: Keys_MirrorObjKeys =  (getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1]).rotation.controller.keys
											3: Keys_MirrorObjKeys =  (getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1]).scale.controller.keys	
											)
										
										--比对关键帧循环
										
										for y = 1 to Keys_MirrorObjKeys.count do
											(
											--比对 并选中需要删除的关键帧
											Keys_MirrorObjKeys[y].selected = false
											if (finditem Key_Time Keys_MirrorObjKeys[y].time) == 0 do Keys_MirrorObjKeys[y].selected = true
											--添加工作区域范围之外的关键帧选择判断
											if Keys_MirrorObjKeys[y].time <= TimeRange[1] or Keys_MirrorObjKeys[y].time >= TimeRange[2] do Keys_MirrorObjKeys[y].selected = false
											-- 再加一条 判断源物体的最后一个关键帧
											)
										--删除选中的多余关键帧
										deleteKeys Keys_MirrorObjKeys #selection
										)
									)
									catch()
								)
							)	
						--专门针对IK的旋转角度进行对称处理
						for o in Bone_Basic do 
							(
							if classof o == IK_Chain_Object do 
								(				 
								IK_Mirror =  (getnodebyname (filterstring (getappdata o 100) "|")[1])
								
								--给镜像端的ik 的旋转 加上 #keys() 属性 使其不为 undefined
								animButtonState = true
								IK_Mirror.controller.swivelangle = IK_Mirror.controller.swivelangle +1
								sliderTime = currentTime  + 1
								IK_Mirror.controller.swivelangle = IK_Mirror.controller.swivelangle +1
								deleteKeys IK_Mirror.controller.swivelangle.keys #allKeys
								animButtonState = false
								--添加 #keys() 完毕								
								 for i = 1 to o.controller.swivel_angle.keys.count do 
									(
									addnewkey IK_Mirror.controller o.controller.swivel_angle.keys[i].time
									IK_Mirror.controller.swivel_angle.keys[i].value = -o.controller.swivel_angle.keys[i].value
									)
								)
							)
						--恢复父物体的缩放值
						fnParentScaleRecover IsScaleNode
						)
					)
				)
			--catch()
			--	(
			--	messagebox "镜像骨骼选择错误，请检查（没有关联的骨骼无法进行镜像）"
			--	)
			)
		enableSceneRedraw()
		redrawViews()
		)

		

	on btn_SingleFrame_Mirror pressed do 	--单帧镜像按钮
		(	
		undo on 
			(
			--try			
				(
				--disableSceneRedraw()
				animate on
					(
					if selection.count > 0 do 
						(
						--调用骨骼选择集重新整理排序函数
						Bone_Basic = BoneMirror_SortObj (selection as array) 				
						--检查父物体是否被选中 如有则清除
						for o in Bone_Basic do 
							(
							if (getappdata o 100) == "" or (getappdata o 100) == undefined do 
								deleteItem Bone_Basic (findItem aa o)
								)
						--保存Bone_Basic的缩放值 并重置缩放
						Bone_Basic_ScaleValue = #()
						for i = 1 to Bone_Basic.count do
							(
							--判断 如果不是IK解算器物体 则开始进行缩放值记录
							
							--断点20140612
							
						--	if classof Bone_Basic[i] ! = IK_Chain_Object do
						--		(
								--判断控制器类型 进行分别处理
								case classof Bone_Basic[i].controller of
									(
									IKControl: Bone_Basic_ScaleKey = Bone_Basic[i].controller.FK_Sub_Control.scale.keys
									prs: Bone_Basic_ScaleKey =  Bone_Basic[i].controller.scale.keys
									)
							
								--Bone_Basic_ScaleKey = Bone_Basic[i][3][3].keys
								TempScaleValue = #()
								for ScaleKeyTime in 1 to Bone_Basic_ScaleKey.count do 
									at time Bone_Basic_ScaleKey[ScaleKeyTime].time
										(
										TempScaleValue[ScaleKeyTime] = Bone_Basic[i].controller.scale
										Bone_Basic[i].controller.scale = [1,1,1]
										)
								Bone_Basic_Scalevalue[i] = TempScaleValue
								）		
							)
						print ("缩放值 = "+Bone_Basic_Scalevalue as string)

						--检索参与镜像骨骼所有有带缩放的父物体
						IsScaleNode = fnParentScale Bone_Basic					
						--清除所有所有父物体的缩放值
						fnParentScaleClear IsScaleNode
						
							
						--单帧镜像
						at time sliderTime
							BoneMirror_BeginMirror Bone_Basic --调用动画镜像函数
						
						--写回缩放值 20170222 旧的写回缩放值功能 是取帧上面的缩放值 镜像单帧的功能当前不一定有关键帧
						for i = 1 to Bone_Basic.count do
							(
							try
								(
								Bone_Basic_ScaleKey = Bone_Basic[i][3][3].keys							
									
								for ScaleKeyTime in 1 to Bone_Basic_ScaleKey.count do 
									(
									at time Bone_Basic_ScaleKey[ScaleKeyTime].time
										(
										Bone_Basic[i].controller.scale = Bone_Basic_Scalevalue[i][ScaleKeyTime]
										)
									)							
								(getnodebyname (filterstring (getappdata Bone_Basic[i] 100) "|")[1]).controller.scale = Bone_Basic[i].controller.scale
								)
								catch ()
							)

						
							
							
							--专门针对IK的旋转角度进行对称处理
						for o in Bone_Basic do 
							(
							if classof o == IK_Chain_Object do 
								(				 
								IK_Mirror =  (getnodebyname (filterstring (getappdata o 100) "|")[1])
								
								--给镜像端的ik 的旋转 加上 #keys() 属性 使其不为 undefined
								animButtonState = true
								IK_Mirror.controller.swivelangle = IK_Mirror.controller.swivelangle +1
								sliderTime = currentTime  + 1
								IK_Mirror.controller.swivelangle = IK_Mirror.controller.swivelangle +1
								deleteKeys IK_Mirror.controller.swivelangle.keys #allKeys
								animButtonState = false
								--添加 #keys() 完毕								
								 for i = 1 to o.controller.swivel_angle.keys.count do 
									(
									addnewkey IK_Mirror.controller o.controller.swivel_angle.keys[i].time
									IK_Mirror.controller.swivel_angle.keys[i].value = -o.controller.swivel_angle.keys[i].value
									)
								)
							)
						--恢复父物体的缩放值
						fnParentScaleRecover IsScaleNode
						)
					)
				)
			--catch()
			--	(
			--	messagebox "镜像骨骼选择错误，请检查（没有关联的骨骼无法进行镜像）"
			--	)
			)
		enableSceneRedraw()
		redrawViews()
		)
)








createDialog BoneMirrorTabs 200 297 --300 500
















