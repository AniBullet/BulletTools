clearlistener()
try(destroydialog uvw_xform_array_helper)catch()
rollout uvw_xform_array_helper "UVW Xform Helper" width:340 height:128 (
	editText edt1 "X Axis" pos:[24,32] width:94 height:16 align:#left text:"1"
	groupBox grp1 "Number of Textures" pos:[8,8] width:134 height:72 align:#left
	editText edt3 "Y Axis" pos:[24,54] width:94 height:16 align:#left text:"1"
	groupBox grp2 "Direction" pos:[152,8] width:64 height:72 align:#left
	checkButton btn1 "TL" pos:[165,32] width:20 height:20 align:#left checked:false
	checkButton btn2 "BL" pos:[165,53] width:20 height:20 align:#left checked:false
	checkButton btn3 "TR" pos:[186,32] width:20 height:20 align:#left checked:true
	checkButton btn4 "BR" pos:[186,53] width:20 height:20 align:#left checked:false
	button btn5 "Apply" pos:[8,88] width:208 height:32 align:#left
	groupBox grp7 "Adjustment" pos:[224,9] width:106 height:111 align:#left
	button btn16 "U" pos:[265,26] width:24 height:32 align:#left
	button btn17 "D" pos:[265,82] width:24 height:32 align:#left
	button btn18 "L" pos:[233,58] width:32 height:24 align:#left
	button btn19 "R" pos:[289,58] width:32 height:24 align:#left
	local state=false
	fn getModifier msh mclass  = (
		local mods=#(),amod=undefined
		mods = for o in msh.modifiers where (classof o) == mclass collect o
		if mods.count>0 then (
			mods[1]
			)
		else (
			amod = mclass()
			addModifier msh amod
			amod
			)
		)
	fn apply_xform_array array_size direction = (
		local pitch = [0,0],i=1,uvw_xform_mod = undefined
		local objs = #(), o = undefined, xpos=0,ypos=0
		local tmp = #(), doSorting=true
		pitch = 1.0 / array_size
		if array_size[1]>0 or array_size[2]>0 then (
			if selection.count >0 then (
				if doSorting then (
					tmp = for o in selection collect o.name
					sort tmp
					for o in tmp do (
						append objs (getNodeByName o exact:true)
						)
					)
				else (
					objs = for o in selection collect o
					)
				undo on (
					for i = 1 to objs.count do (
						uvw_xform_mod = getModifier objs[i] (UVW_Xform)
						uvw_xform_mod.U_Tile = pitch[1]
						uvw_xform_mod.V_Tile = pitch[2]
						uvw_xform_mod.U_Offset = xpos * pitch[1]
						uvw_xform_mod.V_Offset = ypos * pitch[2]
						case direction of (
							#TL: (
								uvw_xform_mod.U_Offset=-uvw_xform_mod.U_Offset
								)
							#BL: (
								uvw_xform_mod.U_Offset=-uvw_xform_mod.U_Offset
								uvw_xform_mod.V_Offset=-uvw_xform_mod.V_Offset
								)
							#BR: (
								uvw_xform_mod.V_Offset=-uvw_xform_mod.V_Offset
								)
							)
						xpos+=1
						if (mod xpos array_size[1])==0 do (
							ypos+=1
							xpos=0
							)
						)
					)
				messagebox "DONE !"
				)
			else (messagebox "Warning:\n\tNothing Selected?")
			)
		else (messagebox "Warning:\n\tArray Size Must be Larger then 0")
		)
	fn adjust_xform_array array_size direction = (
		local pitch = [0,0],i=1,uvw_xform_mod = undefined
		local xpos=0,ypos=0, objs = #(), o = undefined, i= 1
		pitch = 1.0 / array_size
		if array_size[1]>0 or array_size[2]>0 then (
			if selection.count >0 then (
				objs = for o in selection collect o
				undo on (
					for o in objs do (
						uvw_xform_mod = getModifier o (UVW_Xform)
						case direction of (
							#UP: (uvw_xform_mod.V_Offset=mod (uvw_xform_mod.V_Offset + pitch[2]) 1)
							#DOWN: (uvw_xform_mod.V_Offset=mod (uvw_xform_mod.V_Offset - pitch[2]) -1)
							#RIGHT: (uvw_xform_mod.U_Offset=mod (uvw_xform_mod.U_Offset + pitch[1]) 1)
							#LEFT: (uvw_xform_mod.U_Offset=mod (uvw_xform_mod.U_Offset - pitch[1]) -1)
							)
						--format "[%,%]\n" uvw_xform_mod.U_Offset uvw_xform_mod.V_Offset
						)
					)
				)
			else (messagebox "Warning:\n\tNothing Selected?")
			)
		else (messagebox "Warning:\n\tArray Size Must be Larger then 0")
		)
	on btn1 changed state do (btn2.checked = btn3.checked = btn4.checked = false)
	on btn2 changed state do (btn1.checked = btn3.checked = btn4.checked = false)
	on btn3 changed state do (btn1.checked = btn2.checked = btn4.checked = false)
	on btn4 changed state do (btn1.checked = btn2.checked = btn3.checked = false)
	on btn16 pressed do (adjust_xform_array (try([(edt1.text as float),(edt3.text as float)])catch([1,1])) #UP)
	on btn17 pressed do (adjust_xform_array (try([(edt1.text as float),(edt3.text as float)])catch([1,1])) #DOWN)
	on btn18 pressed do (adjust_xform_array (try([(edt1.text as float),(edt3.text as float)])catch([1,1])) #LEFT)
	on btn19 pressed do (adjust_xform_array (try([(edt1.text as float),(edt3.text as float)])catch([1,1])) #RIGHT)
	on btn5 pressed do (
		if (try(execute edt1.text)catch(undefined))!=undefined \
		and (try(execute edt3.text)catch(undefined))!=undefined then (
			try (
				apply_xform_array(
					try (
						[(edt1.text as float),(edt3.text as float)]
						)
					catch (
						edt1.text = edt3.text = "1"
						[1,1]
						)
					) \
					(
					if btn1.checked then (
						#TL
						)
					else if btn2.checked then (
						#BL
						)
					else if btn3.checked then (
						#TR
						)
					else if btn4.checked then (
						#BR
						)
					)
				)
			catch (messagebox "Error:\n\tUnknown Error, Contact Admin")
			)
		else (messagebox "Error:\n\tInvalid Number In X/Y")
		)
	)
createdialog uvw_xform_array_helper