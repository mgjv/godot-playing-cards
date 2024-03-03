extends Node2D


func _on_droppable_received_drop(node: Node2D):
	print("%s received %s" % [self.name, node.name])
