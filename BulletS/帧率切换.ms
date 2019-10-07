----------------------简单制作：S.银色子弹-------------------------------
--------------------------时间：2019.05.15-----------------------------------

global SetFps
try (destroyDialog SetFps) catch()

pos_x = mouse.screenpos.x  
pos_y = mouse.screenpos.y

rollout SetFps "设置帧率" width:143 height:123
(
	groupBox grp1 "设置帧率" pos:[8,8] width:125 height:103
	button btn1 "30" pos:[23,32] width:40 height:32
	button btn2 "60" pos:[78,32] width:40 height:32
	label lbl1 "[2019.05.15]" pos:[55,75] width:70 height:15
	label lbl2 "by: Bullet.S" pos:[65,90] width:60 height:15
	on btn1 pressed  do
		framerate = 30
	on btn2 pressed  do
		framerate = 60
)
createdialog SetFps 143 123 pos_x pos_y