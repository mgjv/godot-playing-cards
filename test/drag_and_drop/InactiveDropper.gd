extends Node2D

@onready var empty_spot: EmptySpot = $EmptySpot
@onready var droppable: Droppable = $Droppable


func _on_droppable_received_drop(node: Node2D):
	var affirm = "" if droppable.active else " should not have"
	print("%s%s received %s" % [self.name, affirm, node.name])
	

func _on_clickable_click():
	if droppable.active:
		droppable.active = false
		empty_spot.color = Color.WEB_GRAY
	else:
		droppable.active = true
		empty_spot.color = Color.WEB_GREEN
