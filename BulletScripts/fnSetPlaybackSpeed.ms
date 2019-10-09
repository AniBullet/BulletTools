/*
 * @Description: 修改动画播放速率
 * @Author: Bullet.S
 * @Date: 2019-10-09 13:10:54
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-10-09 13:44:22
 * @Email: animator.bullet@foxmail.com
 */

Global valuePlaySpeed = ""

fn judgePlaySpeedValue =
(
    case of
    (
        (timeConfiguration.playbackSpeed == 1):(valuePlaySpeed = "--1/4x--")
        (timeConfiguration.playbackSpeed == 2):(valuePlaySpeed = "--1/2x--")
        (timeConfiguration.playbackSpeed == 3):(valuePlaySpeed = "-- 1x --")
        (timeConfiguration.playbackSpeed == 4):(valuePlaySpeed = "-- 2x --")
        (timeConfiguration.playbackSpeed == 5):(valuePlaySpeed = "-- 4x --")
    )
)

fn fnSetSpeed numSpeed =
(
    timeConfiguration.playbackSpeed = numSpeed
    judgePlaySpeedValue ()
)

rcmenu menuSetSpeed
(
    menuItem menuCurrentSpeed "" enabled:false
    menuItem menuSet14Speed "-- 1/4x --"
    menuItem menuSet12Speed "-- 1/2x --"
    separator menuSepSpeedLow
    menuItem menuSet1Speed "--  1x  --"
    separator menuSepSpeedHigh
    menuItem menuSet2Speed "--  2x  --"
    menuItem menuSet4Speed "--  4x  --"

    on menuSetSpeed open do 
    (
        judgePlaySpeedValue ()
        menuSetSpeed.menuCurrentSpeed.text = "当前: " + valuePlaySpeed
    )

    on menuSet14Speed picked do 
    (
        fnSetSpeed 1
    )
    on menuSet12Speed picked do
    (
        fnSetSpeed 2
    )
    on menuSet1Speed picked do 
    (
        fnSetSpeed 3
    )
    on menuSet2Speed picked do 
    (
        fnSetSpeed 4
    )
    on menuSet4Speed picked do 
    (
        fnSetSpeed 5
    )
)