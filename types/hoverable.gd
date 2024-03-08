class_name Hoverable
extends Area2D

## Base class to detect mouse presence for Area2D
##
## Also see [Clickable], [Draggable] and [Droppable]

## Indicates whether the mouse is over the item
var hovering := false


## Of all the Hoverables under the mouse, am I the top one?
func on_top(group: String) -> bool:
	var group_nodes: Array[Node] = get_tree().get_nodes_in_group(group) \
			.filter( func(node): return node.hovering )
	var top := Util.top_canvas_item(group_nodes)
	if top == self:
		#print("%s is on top" % self)
		return true
	return false


# Keep track of when the mouse is hovering over us
func _mouse_enter():
	hovering = true
	#print("Hovering over %s" % get_parent().name)

func _mouse_exit():
	hovering = false
	#print("Stop hovering over %s" % get_parent().name)


