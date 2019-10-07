----脚本来源：http://www.cnblogs.com/sitt/archive/2011/06/30/2094864.html----
----------------------界面按钮制作：S.银色子弹-------------------------------
--------------------------时间：2018.10.19-----------------------------------

rollout C_OutRangeKeys "清除无限帧v0.1" width:186 height:70
(
	button btn1 "清除无限帧" pos:[24,10] width:100 height:30 toolTip:"点击清除时间轴外所有帧"
	label lbl1 "[20181019] - S.银色子弹 整理" pos:[21,50] width:158 height:15
	button btn2 "  ？" pos:[143,22] width:20 height:18 toolTip:"脚本来源（不确定是否原作者）"
	Fn CleanOutRangeKeys inputObject = 
	(
	    startTime = AnimationRange.Start
	    endTime = AnimationRange.End
	    for i = 1 to inputObject.numSubs do
	    (
	        tempSubAnim = GetSubAnim inputObject i
	        tempController = tempSubAnim.Controller
	        
	        if tempController != undefined do
	        (
	            tempKeyList = tempController.Keys
	            
	            outEndKeysIndex = for i = 1 to tempKeyList.Count where tempKeyList[i].Time > endTime collect i
	            if outEndKeysIndex.Count > 0 do for i = 1 to outEndKeysIndex.Count do DeleteKey tempKeyList tempKeyList.count
	            
	            outStartKeysIndex = for i = 1 to tempKeyList.Count where  tempKeyList[i].Time < startTime collect i
	            for i = 1 to outStartKeysIndex.Count do DeleteKey tempKeyList 1
	        )
	        if tempSubAnim.numSubs > 0 do CleanOutRangeKeys tempSubAnim
	    )
	)
	on btn1 pressed  do
	(
	for tempObject in Objects as Array do CleanOutRangeKeys tempObject
	)
	on btn2 pressed  do
	(
		shellLaunch "https://www.cgjoy.com/forum.php?mod=viewthread&tid=215660" ""
	)
)
createdialog C_OutRangeKeys 186 70