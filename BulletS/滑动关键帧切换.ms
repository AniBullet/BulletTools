--------------------------制作：S.银色子弹------------------------------------
--------------------------时间：2019.05.28-----------------------------------
--------------------------更新：2019.06.18-----------------------------------
--------------------------感谢大佬:Crazyone----------------------------------

if FnKeys != undefined then closeRolloutFloater FnKeys
FnKeys=newrolloutfloater "FnKeys" 296 150

rollout C_FnKeys "滑动帧切换 v1.1" width:296 height:150
(
	checkbox chk1 "左手" pos:[24,20] width:50 height:20 color:Blue
	checkbox chk2 "右手" pos:[96,20] width:50 height:20 color:Green
	checkbox chk3 "左脚" pos:[24,60] width:50 height:20 color:Blue checked:true
	checkbox chk4 "右脚" pos:[96,60] width:50 height:20 color:Green checked:true
	button btn1 "固定关键帧" pos:[184,10] width:80 height:24 toolTip:"Set Planted Key"
	button btn2 "滑动关键帧" pos:[184,50] width:80 height:24 toolTip:"Set Sliding Key"
	button btn3 "自由关键帧" pos:[184,90] width:80 height:24 toolTip:"Set Free Key"
	label lbl1 "[2019.05.28]  Bullet.S" pos:[24,98] width:120 height:16 color:Green

	
	Fn SetPlantedKey = 
	(
		sliderTime = animationRange.start
		for obj in selection where classof obj.baseObject == Biped_Object do
		(
			bipCtrl = obj.controller
	    	if chk1.checked then 
	    	(
	  	  		sel_obj1 = (biped.getNode bipCtrl #larm)
	  	  		k = numKeys sel_obj1.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj1.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetPlantedKey sel_obj1
						)
					)
	  	  	)
	    	if chk2.checked then 
	    	(
	    		sel_obj2 = (biped.getNode bipCtrl #rarm)
	    		k = numKeys sel_obj2.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj2.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetPlantedKey sel_obj2
						)
					)
	    	)
	    	if chk3.checked then 
	    	(
	    		sel_obj3 = (biped.getNode bipCtrl #lleg)
	    		k = numKeys sel_obj3.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj3.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetPlantedKey sel_obj3
						)
					)
	    	)
	    	if chk4.checked then 
	    	(
	    		sel_obj4 = (biped.getNode bipCtrl #rleg)
	    		k = numKeys sel_obj4.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj4.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetPlantedKey sel_obj4
						)
					)
	    	)
	    )
	)

	Fn SetSlidingKey = 
	(
		sliderTime = animationRange.start
		for obj in selection where classof obj.baseObject == Biped_Object do
		(
			bipCtrl = obj.controller
	    	if chk1.checked then 
	    	(
	  	  		sel_obj1 = (biped.getNode bipCtrl #larm)
	  	  		k = numKeys sel_obj1.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj1.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetSlidingKey sel_obj1
						)
					)
	  	  	)
	    	if chk2.checked then 
	    	(
	    		sel_obj2 = (biped.getNode bipCtrl #rarm)
	    		k = numKeys sel_obj2.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj2.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetSlidingKey sel_obj2
						)
					)
	    	)
	    	if chk3.checked then 
	    	(
	    		sel_obj3 = (biped.getNode bipCtrl #lleg)
	    		k = numKeys sel_obj3.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj3.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetSlidingKey sel_obj3
						)
					)
	    	)
	    	if chk4.checked then 
	    	(
	    		sel_obj4 = (biped.getNode bipCtrl #rleg)
	    		k = numKeys sel_obj4.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj4.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetSlidingKey sel_obj4
						)
					)
	    	)
	    )	
	)

	Fn SetFreeKey = 
	(
		sliderTime = animationRange.start
		for obj in selection where classof obj.baseObject == Biped_Object do
		(
			bipCtrl = obj.controller
	    	if chk1.checked then 
	    	(
	  	  		sel_obj1 = (biped.getNode bipCtrl #larm)
	  	  		k = numKeys sel_obj1.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj1.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetFreeKey sel_obj1
						)
					)
	  	  	)
	    	if chk2.checked then 
	    	(
	    		sel_obj2 = (biped.getNode bipCtrl #rarm)
	    		k = numKeys sel_obj2.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj2.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetFreeKey sel_obj2
						)
					)
	    	)
	    	if chk3.checked then 
	    	(
	    		sel_obj3 = (biped.getNode bipCtrl #lleg)
	    		k = numKeys sel_obj3.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj3.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetFreeKey sel_obj3
						)
					)
	    	)
	    	if chk4.checked then 
	    	(
	    		sel_obj4 = (biped.getNode bipCtrl #rleg)
	    		k = numKeys sel_obj4.controller
					for i=1 to k do
					(
					t = (biped.getkey sel_obj4.controller i).time
						slidertime = t
						with animate on --at time t		
						(
							biped.SetFreeKey sel_obj4
						)
					)
	    	)
	    )	
	)
	
	on btn1 pressed  do
	(
		SetPlantedKey ()
	)
	
	on btn2 pressed  do
	(
		SetSlidingKey ()
	)
	
	on btn3 pressed  do
	(
		SetFreeKey ()
	)
	
)
addrollout C_FnKeys FnKeys
clearListener()