class_name Util
extends Object

## A collection of static functions for general use


## Composed z index, for nodes that potentially control other nodes
static func c_z_index(c: CanvasItem) -> int:
	if "controlled_node" in c:
		return abs_z_index(c.controlled_node)
	else:
		return abs_z_index(c)


## Absolute z index, taking into account tree inheritance
static func abs_z_index(c: CanvasItem) -> int:
	var abs_z = c.z_index
	if c.z_as_relative and c.get_parent() is CanvasItem:
		abs_z += abs_z_index(c.get_parent())
	return abs_z


## Can be used to sort nodes in a scenetree
## to determine the "display order". This takes Z index
## and position in the tree into account
##
## After the sort, the first element is the one on tthe top 
## (so this method sorts "backwards")
static func cmp_render_order(a: CanvasItem, b: CanvasItem) -> bool:
	var z_index_cmp = Util.c_z_index(a) - Util.c_z_index(b)
	if z_index_cmp != 0:
		if z_index_cmp > 0:
			return true
	else: 
		if a.is_greater_than(b):
			return true
	
	return false


## Return a list of all nodes starting with the given start_node.,
## applying the optional filter.
static func get_filtered_nodes(start_node: Node, \
			filter : Callable = func(_n): return true, \
			nodes : Array[Node] = [] \
		) -> Array[Node]:
	if filter.call(start_node):
		nodes.append(start_node)
	for child in start_node.get_children():
		get_filtered_nodes(child, filter, nodes)
	return nodes


## Convert the given array to a typed Array[CanvasItem
## throwing away any elements that don't fit
static func array_to_canvas_items(array: Array[Variant]) -> Array[CanvasItem]:
	var out : Array[CanvasItem] = []
	for e in array:
		var c: CanvasItem = e as CanvasItem
		if c:
			out.append(c)
	return out
	

## Find the top CanvasItem
##
## If items have a "controlled_node" member, then it will be used
## for the order determination instead of the node itself.
##
## It doesn't make sense to call this with anything else than
## CanvasItem nodes in the list. Anything that isn't a CanvasItem
## will be silently ignored
##
## This takes a more flexibly typed input to be compatible with 
## the various collection methods on [Node] and [SceneTree], as well 
## as any typed arrays you may have
##
static func top_canvas_item(nodes: Array[Variant]) -> CanvasItem:
	var cis := array_to_canvas_items(nodes)
	# FIXME: seems a bug that I need to specify the class here
	cis.sort_custom(Util.cmp_render_order)
	return cis[0] if cis else null

