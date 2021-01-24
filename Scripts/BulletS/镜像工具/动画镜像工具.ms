-- 2019.1.15
-- E-mail:738746223@qq.com
try(destroyDialog copy_mirror_transform)catch()

rollout copy_mirror_transform "动画镜像工具v.3.0" width:192 height:240
(
  group "设置镜像轴：" (
        radiobuttons radioAxis ""  width:74 height:62 labels:#("X", "XY", "Y", "YZ", "Z", "ZX") columns:2 align:#left
        radiobuttons mirrorFlip "翻转" width:65 height:30 labels:#("Z", "Y") default:1  align:#right offset:[0,-68] --columns:2

        label lab_01 "" --占位
    )

  group "基准轴对象" (
        button bt_Axis "拾取"  width:160 height:32 tooltip:"设置为选中对象" align:#cneter --offset:[0,1]
  )

  group "动画" (
        radiobuttons mirror_type "" labels:#("动画", "姿势") default:2
        button bt_copy_select_A "复制"  width:80 height:24 toolTip:"复制选中控制器动画" across:2 align:#left
        button bt_mirror_select_A "黏贴"  width:80 height:24 toolTip:"镜像黏贴动画" align:#right
  )

  HyperLink lbl_01 "更新" address:"https://github.com/4698to/Joetime.linetool.bar/tree/master/anim_mirror"  align:#center
  -----------------------------------------------------------------------------
  local AxisNode,copy_form,paste_to
  -----------------------------------------------------------------------------
  fn mirrorMatrixFn
        --axis:"x"  --Axis to mirror over
        --flip:"z"  --Axis to flip
        tm:(matrix3 1)  --Matrix to mirror
        pivotTm:(matrix3 1) --Matrix to mirror around
     =
  (
      fn FetchReflection_flip axis_ =
      (

        case axis_ of (
        3: [-1,1,1]  -- x    reflect in YZ plane
        2: [1,-1,1]  -- y    in ZX plane
        1: [1,1,-1]  -- z    in XY plane
        )

      )
     fn FetchReflection a =
     (

        _axis = [1,1,1]
        if  (a <= 2 or a == 6 ) do  _axis.x = (-1)
        if  (a >= 2 and a<= 4 ) do _axis.y = (-1)
        if (a >= 4 ) do _axis.z = (-1)
        return _axis
     )
     aReflection = scalematrix (FetchReflection radioAxis.state)

     --aReflection = scalematrix (FetchReflection axis)
     --fReflection = scalematrix (FetchReflection flip)
     fReflection = scalematrix (FetchReflection_flip mirrorFlip.state)
     --calculate the mirroredTM
     fReflection * (tm * (inverse pivotTm)) * aReflection * pivotTm
  )
  fn mirror_Three a_ b_ c_=
  (
    flippedTM = mirrorMatrixFn pivotTm:b_.transform tm:a_.transform
    c_.transform = flippedTM
  )
  fn mirror_pose a_ b_ c_ =
  (
    set animate on--off
    (
      mirror_Three a_ b_ c_
    )
  )
  fn mirror_anim a_ b_ c_ =
  (
      set animate on
      (
        for t = animationrange.start to animationrange.end do
        (
          at time t (mirror_Three a_ b_ c_)
        )
      )
  )

  -----------------------------------------------------------------------------
      on bt_Axis pressed do--选择基准轴对象
      (
          if selection.count != 0 do
          (
              AxisNode = selection[1]
              bt_Axis.text = AxisNode.name
          )
      )
      on bt_copy_select_A pressed do --复制
      (
          if selection.count != 0 do
          (
              copy_form = selection as array
          )
      )
      on bt_mirror_select_A pressed do --黏贴
      (
          if selection.count != 0 do
          (
            if (IsValidNode AxisNode) then
            (
              paste_to = selection as array
              if mirror_type.state == 1 then
              (
                undo "add mirror anim" on
                (
                  for i=1 to copy_form.count do
                  (
                    try (mirror_anim copy_form[i] AxisNode paste_to[i])catch(print "复制对象出错")
                  )
                )
              )
              else
              (
                undo "add mirror pose" on
                (
                  for i=1 to copy_form.count do
                  (
                    try (mirror_pose copy_form[i] AxisNode paste_to[i])catch(print "复制对象出错")
                  )
                )

              )
            )
            else
            (
                bt_Axis.text = ""
                messageBox "请设置 基准轴 对象  \n\r ."
            )
          )
      )
)
createDialog copy_mirror_transform