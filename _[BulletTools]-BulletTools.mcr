macroScript BulletTools
category:"_[BulletTools]"
buttonText:"_BulletTools_Start"
toolTip:"_BulletTools_Start"
Icon:#("Systems",2)
(
	on execute do
	(
		fileIn ((getDir #Scripts)+"\\"+"BulletTools.ms")
	)
)