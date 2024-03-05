extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func find_top_node() -> CanvasItem:
	var nodes = Util.get_filtered_nodes(get_tree().root, \
			func(n): return n is Draggable or n is Droppable)
	nodes.push_front(Node.new())
	return Util.top_canvas_item(nodes)


func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		#report_nodes()
		var top = find_top_node()
		print("Found %s" % top)
