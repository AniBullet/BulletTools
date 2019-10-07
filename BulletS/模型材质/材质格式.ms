clearlistener()
try(destroydialog matformater)catch()
rollout matformater "Mat Formater" (
	fn getMaterials MaterialClass = (
		local matArray=#(),m=undefined
		if MaterialClass!=undefined then (
			case (classof MaterialClass) of (
				(StandardMaterial): (matArray=#(MaterialClass))
				(MultiMaterial): (
					for m in MaterialClass do (
						if (classof m) != StandardMaterial do (
							m = StandardMaterial()
							)
						append matArray m
						)
					)
				default: (
					messagebox (
						"Error:\t\Invalid Material Class: " + (MaterialClass as string)
						)
					--meditMaterials[activeMeditSlot]
					--MaterialClass.material = StandardMaterial()
					--matArray=#(MaterialClass)
					)
				)
			)
		else (
			MaterialClass = StandardMaterial()
			MaterialClass.Diffuse = selection[1].wirecolor
			matArray=#(MaterialClass)
			)
		matArray
		)
	fn stripTexPaths slotObject fixedPath = (
		local fpath = ""
		
		if fixedPath!=undefined do (
			fpath = fixedPath
			if matchPattern fpath pattern:"*\\*" do (
				if fpath[fpath.count] != "\\" do (
					fpath+="\\"
					)
				)
			)
		try (
			if slotObject!=undefined do (
				if slotObject.filename!=undefined do (
					slotObject.filename = filenameFromPath slotObject.filename
					slotObject.filename = fpath + slotObject.filename
					)
				)
			)
		catch (
			format "Error:\n\tInvalid Material Object.\n"
			)
		true
		)
	fn getFilePath = (
		local ff=""
		ff = GetOpenFileName caption:"Open a File" types:"All Files (*.*)|*.*"
		if ff!=undefined and ff!="" then (
			ff = getFilenamePath ff
			)
		else (
			ff=""
			)
		ff
		)
	group "Operation" (
		button btn_format "FORMAT" width:130 height:40
		checkbutton cb_fmtObj "On Selected Objects" checked:true width:136 height:20 \
			highlightColor:[100,100,0] align:#center
		checkbutton cb_fmtMat "On Open in Material Editor" checked:false width:136 height:20 \
			highlightColor:[100,100,0] align:#center
		checkbox chk_tex "Update Texture Settings" checked:true align:#left
		checkbox chk_col "Update Colour Settings" checked:false align:#left
		checkbox chk_shd "Update Shader Settings" checked:false align:#left
		button btn_collect "Get From Material Editor" width:136 height:20 align:#center
		)
	group "Texture Settings" (
		checkbutton cb_texAlpha "Texture with Alpha" checked:false width:136 height:20 \
			highlightColor:[100,100,0] align:#center
		checkbutton cb_texPath "Strip & Replace Path" checked:false width:136 height:20 \
			highlightColor:[225,64,0] align:#center
		label lbl1 "  Base Path:" align:#left
		edittext edt_fixedpath "" align:#center
		button btn_setpath "Browse" align:#right
		)
	group "Shader Settings" (
		checkbox chk_2sided "2-Sided" align:#left
		dropdownlist ddl_shader_types "" selection:2 align:#center \
			items:#(
				"Anisotropic",
				"Blinn","Metal",
				"Multi-Layer",
				"Oren-Nayer-Blinn",
				"Phong",
				"Strauss",
				"Translucent Shader"
				)
		)
	group "Colour Settings" (
		colorPicker cp_amb "Ambient:" color:[150,150,150] width:130 height:25 align:#right
		colorPicker cp2_diff "Diffuse:  " color:[150,150,150] width:130 height:25 align:#right
		colorPicker cp3_spc "Specular:" color:[230,230,230] width:130 height:25 align:#right
		checkbutton cb_col_loc "Lock Amb &  Diff" checked:true highlightColor:[100,100,100] align:#center
		spinner spn_spc "Spec Level: " range:[0,999,0] type:#integer align:#right
		spinner spn_gls "Glossiness:  " range:[0,100,10] type:#integer align:#right
		spinner spn_opa "Opacity:      " range:[0,100,100] type:#integer align:#right
		)
	local mat=undefined,mats=#(),obj=undefined,m=undefined,state=false
	on btn_collect pressed do (
		try(
			mat = medit.GetCurMtl()
			--mat = selection[1].material
			if mat!=undefined do (
				ddl_shader_types.selection = mat.shaderType + 1
				chk_2sided.checked = mat.twoSided
				cp_amb.color = mat.ambient
				cp2_diff.color = mat.Diffuse
				cp3_spc.color = mat.Specular
				cb_col_loc.checked = mat.adLock
				spn_spc.value = mat.specularLevel
				spn_gls.value = mat.glossiness
				spn_opa.value = mat.opacity
				cb_texAlpha.checked = if mat.opacityMap!=undefined then true else false
				if mat.DiffuseMap!=undefined do (
					if mat.DiffuseMap.filename!=undefined do (
						edt_fixedpath.text = getFilenamePath mat.DiffuseMap.filename
						)
					)
				--MatEditor.open()
				)
			)
		catch(
			messagebox "Error:\n\tNot Standard Material."
			)
		)
	on btn_format pressed do (
		mats=#()
		if cb_fmtObj.checked then (
			if selection.count>0 then (
				for obj in selection do (
					if obj.material == undefined do (
						obj.material = StandardMaterial()
						obj.material.Diffuse = obj.wirecolor
						)
					join mats (getMaterials obj.material)
					)
				)
			else (
				messagebox "Error:\n\tNothing Selected?\n\tSelect Somthing!\n"
				)
			)
		else (
			mats = getMaterials(medit.GetCurMtl())
			)
		undo on (
			for m in mats do (
				if chk_shd.checked do (
					if m.shaderType!= (ddl_shader_types.selection - 1) do (
						m.shaderType = ddl_shader_types.selection - 1
						)
					m.twoSided = chk_2sided.checked
					)
				if chk_col.checked do (
					try (
						m.ambient = cp_amb.color
						m.Diffuse = cp2_diff.color
						m.Specular = cp3_spc.color
						m.adLock = cb_col_loc.checked
						m.specularLevel = spn_spc.value
						m.glossiness = spn_gls.value
						m.opacity = spn_opa.value
						)
					catch (
						format "Error:\n\tFailed to commit changes to material\n"
						)
					)
				if chk_tex.checked do (
					if cb_texAlpha.checked do (
						if m.diffuseMap!=undefined do (
							if m.diffuseMap.filename!=undefined do (
								m.diffuseMap.alphaSource = 2
								--m.diffuseMap.name = "Dif " + m.diffuseMap
								m.opacityMap = Bitmaptexture fileName:m.diffuseMap.filename
								--m.opacityMap.name = "opa " + m.diffuseMap
								m.opacityMap.monoOutput = 1
								m.opacityMap.rgbOutput = 1
								m.opacityMap.preMultAlpha = off
								m.opacityMap.alphaSource = 0
								m.twoSided = on
								)
							)
						)
					if cb_texPath.checked do (
						try(
							stripTexPaths m.DiffuseMap edt_fixedpath.text
							stripTexPaths m.OpacityMap edt_fixedpath.text
							)
						catch (
							format "Error:\n\tFailed to commit changes to material\n"
							)
						)
					)
				)
			)
		)
	on btn_setpath pressed do (
		edt_fixedpath.text = getFilePath()
		)
	on cb_fmtObj changed state do (
		if state then cb_fmtMat.checked = false else cb_fmtMat.checked = true
		)
	on cb_fmtMat changed state do (
		if state then cb_fmtObj.checked = false else cb_fmtObj.checked = true
		)
	);createdialog matformater