try(destroydialog rolloutSelfIllumAmount)catch()

Global selfValue = 100
Global arrSelObj = #()


fn jugdeSel =
(
	if (selection.count == 0) then
	(
		arrSelObj = #()
		for i in objects do (append arrSelObj i)
	)
	else
	(
		arrSelObj = #()
		for i in selection do (append arrSelObj i)
	)
)

rollout rolloutSelfIllumAmount "自发光调节" width:290 height:100
(
	edittext edtValue "自发光"  pos:[12,10] width:127.6 usePercentageWidth:true percentageWidth:44.0 labelOnTop:false text:"100" bold:false readOnly:false --自发光数值
	slider sldValue ""  pos:[20,35] align:#center range:[0,100,0] type:#integer tooltip:"设置自发光数值"
	button btnSet "执行"  pos:[153,8] width:38
	button btnSet0 "0"  pos:[206,8] width:30
	button btnSet100 "100"  pos:[250,8] width:30
	label labTips "调节选中物体, 否则调节全部. ( 前提含材质球 )" pos:[25,76] align:#center

	fn fnSetSelfIllumAmount arrSelObj val = 
	(
		for i in arrSelObj do
		(
			if (classof i.mat == Multimaterial) do  
			(
				for s = 1 to i.mat.materialList.count do  i.mat.materialList[s].selfIllumAmount = val
			)
			if (classof i.mat == Standardmaterial) do 
			(
				i.mat.selfIllumAmount = val
			)
		)
	)

	on edtValue entered val do
	(
		jugdeSel ()
		if ((val != ".") and (val as integer != undefined) and (val != "") and (val as integer <= 100) and (val as integer >= 0)) then
		(
			sldValue.value = (val as integer)
		)
	)

	on sldValue changed val do (jugdeSel ();fnSetSelfIllumAmount arrSelObj val;edtValue.text = val as string)

	on btnSet pressed do 
	(
		jugdeSel ()
		if ((edtValue.text != ".") and (edtValue.text as integer != undefined) and (edtValue.text != "") and (edtValue.text as integer <= 100) and (edtValue.text as integer >= 0)) then
		(
			fnSetSelfIllumAmount arrSelObj (edtValue.text as integer)
			sldValue.value = (edtValue.text as integer)
		)
		else messagebox "-------------------------\r\n请输入0-100的整数数值\r\n"
	)
	on btnSet0 pressed do (jugdeSel ();fnSetSelfIllumAmount arrSelObj 0;sldValue.value = 0;edtValue.text = "0")

	on btnSet100 pressed do (jugdeSel ();fnSetSelfIllumAmount arrSelObj 100;sldValue.value = 100;edtValue.text = "100")

)
Createdialog rolloutSelfIllumAmount fgcolor:(color 255 20 147)