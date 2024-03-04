extends Node2D

func _on_droppable_received_drop(node: Node2D):
	print("%s should not have received %s" % [self.name, node.name])


func _on_clickable_click():
	print("Clicked on %s" % self.name)
	pass # Replace with function body.
