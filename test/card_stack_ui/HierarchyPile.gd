extends Node2D

@onready var stack := $HierarchicalCardStackUI

func _can_receive_drop(node: Node2D) -> bool:
	var card: CardUI = node as CardUI
	
	if stack.has_card(card):
		return false
	
	return true

func _on_droppable_received_drop(node):
	stack.add_card(node as CardUI)
