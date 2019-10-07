
-- for i = 0 to layerManager.count-1 do
-- (
--   ilayer = layerManager.getLayer i
--   layerName = ilayer.name
--   layer = ILayerManager.getLayerObject i
--   layerNodes = refs.dependents layer
--   format "Layer: %; nodes: %\n" layerName layerNodes
-- )
---------------------------------------------------------------
--a = #()
-- i = LayerManager.count  --当前场景所有层计数
-- LayerManager.current
-- a = (LayerManager.getLayer 0).name --当前层名称
-- a = LayerManager.getLayer 0  --当前层所有属性
-- a.name
-- a.current --当前层是否被激活
-- a.current = true    --设置当前层是为激活
-- a.nodes &theNodes   --Nodes加入到theNodes集合
-- theNodes  --返回当前层内所有的Nodes。值为集合#()
-- LayerManager.deleteLayerByName
-- LayerManager.deleteLayerByName a
-------------------------------------------------------------------
LayerZero = LayerManager.getLayer 0
LayerZero.current = true
DL = #()   /*DL = DeleteLayers*/

for i = 0 to LayerManager.count-1 do
(	
-- 	print i
	layerC = LayerManager.getLayer i
	layerC.nodes &theNodes
	layerName = layerC.name
-- 	theNodes.count
-- 	NodesCount = theNodes.count
-- 	print layerName	
-- 	print theNodes.count
	  if theNodes.count == 0 then 
		(
			append DL layerName
			--print DL.count
			--print DL
			--try (print layerName) catch()
			--try (LayerManager.deleteLayerByName layerName) catch()	
		)
)

for d in DL do LayerManager.deleteLayerByName d