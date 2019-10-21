/*
 * @Description: 源自网络 https://forums.cgsociety.org/t/assign-action-to-keyboard-shortcut-through-script/1395733/47
 * @Author: Bullet.S
 * @Date: 2019-10-10 13:03:15
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-10-21 22:02:05
 * @Email: animator.bullet@foxmail.com
 */

fn makeMacroKBD nameKBD category char shift:off ctrl:off alt:off =
(
	local ss = stringstream ""
	local kb = 3
	if shift do kb = bit.set kb 3 on
	if ctrl do kb = bit.set kb 4 on
	if alt do kb = bit.set kb 5 on
	
	format "    <shortcut fVirt=\"%\" accleleratorKey=\"%\" actionID=\"%`%\" actionTableID=\"647394\" />" kb (bit.charasint (toUpper char)) nameKBD category to:ss
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
		skipToString ss "shortcut"
		while not eof ss and act == undefined do
		(
			sss = readline ss
			str = filterstring sss "=\""
			if str.count >= 4 then
			(
				k = str[2] as integer
				c = str[4] as integer
				i = str[str.count - 1] as integer
				if k == kb and c == ch and (not macrosOnly or i == 647394) then act = on else (skipToString ss "shortcut") 
			)
		)
		close ss
		if act == undefined do act = off
	)		
	act
)
fn addMacroKBD nameKBD category char shift:off ctrl:off alt:off file: check:on = 
(
	local linesAll = #()
	-- local tempFile
	local act = #failed
	local taken = off
	local linenum = 1
	local n = 1
	if file == unsupplied do 
	(
		file = actionMan.getKeyboardFile()
		-- tempFile = (getFileNamePath file) + "temp.kbdx"
	)

	if (new = not doesfileexist file) or not check or (isTakenKBD char shift:shift ctrl:ctrl alt:alt file:file) != true then
	(
		str = makeMacroKBD nameKBD category char shift:shift ctrl:ctrl alt:alt
		print str
		ss = if new then (createfile file) else openFile file mode:"r+"
		if ss != undefined do
		(
			flush ss
			close ss
			linesAll = (dotNetClass "System.IO.File").ReadAllLines file
			linenum = 1
			n = 1
			-- format "%" str to:ss
			for i = 1 to linesAll.count do
			(
		-- 		nameKBD = "*StartBippy*"
				if matchpattern linesAll[i] pattern:("*" + nameKBD + "*") then
				(
					lineNum = n
				)
				else
				(
					n += 1
				)
			)
			deleteItem linesAll lineNum
			insertItem str linesAll lineNum
			(dotNetClass "System.IO.File").WriteAllLines file linesAll
-- 			flush ss
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


-- fn deleteLine nameKBD linenum = 
-- (
-- 	local fileKBD = actionMan.getKeyboardFile()
-- 	local linesAll = (dotNetClass "System.IO.File").ReadAllLines fileKBD
-- 	local n = 1
-- 	for i = 1 to linesAll.count do
-- 	(
-- -- 		nameKBD = "*StartBippy*"
-- 		if matchpattern linesAll[i] pattern:nameKBD then
-- 		(
-- 			lineNum = n
-- 		)
-- 		else
-- 		(
-- 			n += 1
-- 		)
-- 	)
-- 	deleteItem linesAll lineNum
-- 	(dotNetClass "System.IO.File").WriteAllLines fileKBD linesAll
-- )
-- deleteLine "*StartBippy*" lineNum


-- addMacroKBD "StartBippy" "BIPPY" "D" shift:on ctrl:on alt:off

-- -- removeAction
-- fn deleteLine fileKBD linenum = 
-- (
-- 	local linesAll = (dotNetClass "System.IO.File").ReadAllLines fileKBD
-- 	deleteItem linesAll linenum
-- 	(dotNetClass "System.IO.File").WriteAllLines fileKBD linesAll
-- )