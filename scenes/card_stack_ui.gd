class_name CardStackUI
extends Node2D

var cardUIScene = preload("res://scenes/card_ui.tscn")


func add_card(card: Card) -> CardUI:
	var new_card: CardUI = cardUIScene.instantiate()		
	new_card.card = card
	add_child(new_card)
	return new_card


# Open the top card
func top_card() -> CardUI:
	return get_child(-1)


func bottom_card() -> CardUI:
	return get_child(0)
