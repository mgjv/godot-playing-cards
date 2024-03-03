class_name Util
extends Object

## A collection of static functions for general use

## Can be used to sort nodes in a scenetree
## to determine the "display order". This takes Z index
## and position in the tree into account
static func cmp_nodes_by_overlap(a: Node, b: Node) -> bool:
	if a.controlled_node.z_index > b.controlled_node.z_index:
		return true
	return a.is_greater_than(b)
