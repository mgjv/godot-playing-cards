extends Node2D

@onready var stack = $CardStackUI

func _on_droppable_received_drop(node):
	var card: CardUI = node as CardUI
	stack.add_card(card)


func _can_receive_drop(node: Node2D) -> bool:
	var card: CardUI = node as CardUI
	# Do not accept stacks of cards
	if card.has_child_card():
		return false
	
	return true
