extends Node2D

@onready var deck: CardStackUI = %DeckPile/FullCardStackUI
@onready var end_pile: CardStackUI = %EndPile/CardStackUI

func _ready():
	print("Got a deck with %d cards" % [deck.size()])
	print("Top card is %s" % [deck.top_card()])


func _on_clickable_click():
	if deck.size() > 0:
		var card := deck.top_card()
		card.draggable.active = true
		end_pile.add_card(card)
	else:
		# get the stack
		var cards := end_pile.cards()
		# flip the stack over
		cards.reverse()
		# move the cards, and flip each of them
		for card in cards:
			deck.add_card(card)
