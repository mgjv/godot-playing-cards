class_name Deck
extends Resource

## Represents a deck of cards.
##
## Contains a full set of playing cards
##

var cards: Array[Card]

var top_card: Card:
	get:
		return cards[0]
	set(c):
		push_error("Cannot set top card")

func _init():
	# Iterate over all the suits and values and instantiate cards
	# When iterating over an enum, Godot uses keys() by default
	# so explicitly ask for values()
	for suit in Card.SUITS.values():
		for value in Card.VALUES.values():
			cards.append(Card.new(suit, value))

func shuffle():
	cards.shuffle()
