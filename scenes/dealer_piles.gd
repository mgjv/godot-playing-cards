extends Node2D

@onready var deck:  CardStackUI = $DeckPile/CardStackUI
@onready var stack: CardStackUI = $DiscardPile/CardStackUI


# Turn over the top card
func _turn_top_card():
	var card := deck.top_card()
	#print("Working on %s" % card)
	if card:
		card.open()
		card.draggable.active = true
		stack.add_card(card)
		card.move_to(stack.global_position)


# Flip the cards from the stack back to the deck
func _reset_cards():
	# get the stack
	var cards := stack.cards()
	# flip the stack over
	cards.reverse()
	# move the cards, and flip each of them
	for card in cards:
		card.close()
		deck.add_card(card)
		card.move_to(deck.global_position)


# Called when the player clicks on the deck
func _on_deck_click():
	if deck.size() > 0:
		_turn_top_card()
	else:
		_reset_cards()
