extends Node2D


func _can_receive_drop(node: Node2D) -> bool:
	#print("Can %s receive %s" % [self.name, node.name])
	return false

func _on_droppable_received_drop(node: Node2D):
	print("%s received %s" % [self.name, node.name])
