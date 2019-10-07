--2018/5/14 QQ :738746223

rollout bone_scale "biped 缩放_v2" width:200 height:80
(
    button bt_do_11 "添加缩放控制" --pos:[65,65] width:50

    button bt_do_22 "去除缩放控制" --pos:[65,90] width:50

    HyperLink lbl_01 "帮助" address:"https://github.com/4698to/Joetime.linetool.bar/tree/master/biped_tool" align:#center
    on bt_do_11 pressed do
    (
        if (selection.count != 0) then
        (
            --.transform.controller.Biped_SubAnim.controller.BipScaleList.controller.Available.controller = ScaleXYZ ()
            for i in selection do
            (
                if (classOf i ==Biped_Object) and (i.transform.controller[1].name != "Vertical") do --质心不作缩放
                (
                    undo "bipedscale" on
                    (try
                        (
                        bip_ed = i.transform.controller.rootnode
                        bip_ed.transform.controller.enableSubAnims = true
                        i.transform.controller[1][1][1].controller = ScaleXYZ ()
                        )catch()
                    )
                )
            )
        )
        else
        (
            messagebox "请选择一根或多根 Biped 骨骼!\n\r" beep:true title:"选择有误！"
        )
    )

    on bt_do_22 pressed do
    (
        if (selection.count != 0) then
        (
            for i in selection do
            (
                if (classOf i ==Biped_Object) and (i.transform.controller[1].name != "Vertical") do --质心不作缩放
                (
                    undo "bipedscale_key" on --删除缩放帧 ，
                    (
                        --deletekeys i.transform.controller[1][1][1].controller.keys #allKeys
                        lstctr = i.transform.controller[1][1]
                        try (lstctr.delete 1)catch()
                    )
                )
            )
        )
        else
        (
            messagebox "请选择一根或多根 Biped 骨骼!\n\r" beep:true title:"选择有误！"
        )
    )


)
createDialog bone_scale