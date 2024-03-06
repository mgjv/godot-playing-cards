class_name AcePile
extends Node2D

@onready var stack: CardStackUI = $CardStackUI

# Called to check whether we're happy to receive a drop
func _can_receive_drop(node: Node2D) -> bool:
	if not node is CardUI:
		return false 
	
	var card: Card = node.card
	if stack.size() == 0:
		if card.value == Card.VALUES.ace:
			return true
	else:
		var top_card := stack.top_card().card
		if card.is_next(top_card):
			return true
	
	return false

# Called to actually receive the drop
func _on_received_drop(node: Node2D):
	#print("Got %s" % node)
	stack.add_card(node as CardUI)
	
