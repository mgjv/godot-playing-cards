extends Node2D

@onready var stack = $CardStackUI

func _on_droppable_received_drop(node):
	var card: CardUI = node as CardUI
	stack.add_card(card)
