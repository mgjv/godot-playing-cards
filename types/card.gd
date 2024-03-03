class_name Card
extends Resource

## Card represents the data needed for a playing card
##
## A Card instance is immutable, so the constructor
## takes a suit and value.
##

enum SUITS {
	clubs, diamonds, hearts, spades,
}

enum VALUES {
	ace = 1,
	two, three, four, five, six, seven, eight, nine, ten,
	jack, queen, king,
}

var suit : SUITS
var value : VALUES

func _init(s: SUITS, v: VALUES):
	suit = s
	value = v

func _to_string() -> String:
	return VALUES.keys()[value - VALUES.ace] + " of " + SUITS.keys()[suit]
