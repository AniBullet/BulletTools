Global SIOFile = dotNetClass "System.IO.File"			---文件操作
Global SIODir = dotNetClass "System.IO.Directory"		---文件夹操作

fn fnDelFiles fileDel =
(
	if (SIOFile.Exists fileDel) == true do
	(
		if getFileAttribute fileDel #readOnly == true or getFileAttribute fileDel #hidden == true do
		(
			setFileAttribute fileDel #readOnly false ; setFileAttribute fileDel #hidden false
		)
		try (SIOFile.Delete(fileDel);(print ("已删除: "+ filenameFromPath fileDel)))
		catch (print ("删除失败: "+ filenameFromPath fileDel + ". 请尝试手动删除.");print "删除失败")
	)
)

fn fnDelDir dirDel =
(
	if (SIODir.Exists dirDel) == true do
	(
		if getFileAttribute dirDel #readOnly == true or getFileAttribute dirDel #hidden == true do
		(
			setFileAttribute dirDel #readOnly false ; setFileAttribute dirDel #hidden false
		)
		try (SIODir.Delete(dirDel);(print ("已删除: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹")))
		catch (print ("删除失败: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹. 请尝试手动删除.");print "删除失败")
	)
)