/*
 * @Description: 源自网络 https://forums.cgsociety.org/t/assign-action-to-keyboard-shortcut-through-script/1395733/47
 * @Author: Bullet.S
 * @Date: 2019-10-10 13:03:15
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-10-10 22:49:56
 * @Email: animator.bullet@foxmail.com
 */

fn getKeyMacroKBD name category file: =
(
    local pattern = "*" + name + "`" + category + "*" + "647394" + "*"
    local hots = #()
        
    if file == unsupplied do file = actionMan.getKeyboardFile()
    if (ss = openfile file) != undefined do
    (
        a = skipToString ss "shortcut"
        if a as string == "OK" do
        (
            while not eof ss do
            (
                str = readline ss
                sss = filterstring str "=\""
                if sss[2] != undefined then
                (
                    k = sss[2] as integer
                    c = sss[4] as integer
                    i = sss[sss.count - 1] as integer
                    if matchpattern str pattern:pattern do
                    (
                        ch = toUpper (bit.intaschar c)
                        if bit.get k 5 do ch = "ALT+" + ch 
                        if bit.get k 4 do ch = "CTRL+" + ch 
                        if bit.get k 3 do ch = "SHIFT+" + ch 
                        append hots ch
                    )
                )
            )
        )
        close ss
    )		
    hots
)