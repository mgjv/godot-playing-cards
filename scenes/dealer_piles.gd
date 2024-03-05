extends Node2D

@onready var deck:  CardStackUI = $DeckPile/CardStackUI
@onready var stack: CardStackUI = $DiscardPile/CardStackUI

func _ready():
	_turn_top_card()

# Turn over the top card
func _turn_top_card():
	var card := deck.top_card()
	#print("Working on %s" % card)
	if card:
		card.open()
		card.draggable.active = true
		stack.add_card(card)

# Flip the cards from the stack back to the deck
func _reset_cards():
	stack.move_cards_to(deck, true)

# Called when the player clicks on the deck
func _on_deck_click():
	if deck.size() > 0:
		_turn_top_card()
	else:
		_reset_cards()
