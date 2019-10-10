/*
 * @Description: 源自网络 https://forums.cgsociety.org/t/assign-action-to-keyboard-shortcut-through-script/1395733/47
 * @Author: Bullet.S
 * @Date: 2019-10-10 13:03:15
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-10-10 14:30:55
 * @Email: animator.bullet@foxmail.com
 */
fn makeMacroKBD name category char shift:off ctrl:off alt:off =
(
	local ss = stringstream ""
	local kb = 3
	if shift do kb = bit.set kb 3 on
	if ctrl do kb = bit.set kb 4 on
	if alt do kb = bit.set kb 5 on
	
	format "-1=% % %`% 647394" kb (bit.charasint (toUpper char)) name category to:ss
	ss as string
)
fn isTakenKBD char shift:off ctrl:off alt:off file: macrosOnly:on =
(
	local act
	local ch = (bit.charasint (toUpper char))
	local kb = 3
	if shift do kb = bit.set kb 3 on
	if ctrl do kb = bit.set kb 4 on
	if alt do kb = bit.set kb 5 on
		
	if file == unsupplied do file = actionMan.getKeyboardFile()
	if (ss = openfile file) != undefined do
	(
		skipToString ss "=" 
		while not eof ss and act == undefined do
		(
			str = filterstring (readline ss) " "
			k = execute str[1]
			c = execute str[2]
			i = execute str[str.count]
			if k == kb and c == ch and (not macrosOnly or i == 647394) then act = on else (skipToString ss "=") 
		)
		close ss
		if act == undefined do act = off
	)		
	act
)
fn addMacroKBD name category char shift:off ctrl:off alt:off file: check:on = 
(
	local act = #failed, taken = off
	if file == unsupplied do file = actionMan.getKeyboardFile()
	if (new = not doesfileexist file) or not check or (isTakenKBD char shift:shift ctrl:ctrl alt:alt file:file) != true then
	(
		str = makeMacroKBD name category char shift:shift ctrl:ctrl alt:alt
		ss = if new then createfile file else openFile file mode:"a+"
		if ss != undefined do
		(
			format "%
" str to:ss
			flush ss
			close ss
			act = #added
		)
	)
	else act = #taken
	if act == #added do
	(
		actionMan.loadKeyboardFile file
		actionMan.saveKeyboardFile file
	)
	act
)