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
	ace = 0,
	two, three, four, five, six, seven, eight, nine, ten,
	jack, queen, king,
}

var suit : SUITS
var value : VALUES

func _init(s: SUITS, v: VALUES):
	suit = s
	value = v

func _to_string() -> String:
	return VALUES.keys()[value] + " of " + SUITS.keys()[suit]
