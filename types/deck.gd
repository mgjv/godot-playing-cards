class_name Deck
extends Resource

## Represents a full deck of cards.
##
## Initially contains a full set of playing cards
## which can then be popped off and added to
##

var cards: Array[Card]

func _init():
	# Iterate over all the suits and values and instantiate cards
	# When iterating over an enum, Godot uses keys() by default
	# so explicitly ask for values()
	for suit in Card.SUITS.values():
		for value in Card.VALUES.values():
			cards.append(Card.new(suit, value))


## Shuffle the cards randomly
func shuffle():
	cards.shuffle()
