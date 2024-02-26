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

var suit : SUITS = SUITS.spades
	#set(v):
		#push_error("Card is immutable")
var value : VALUES = VALUES.ace
	#set(v):
		#push_error("Card is immutable")

func _init(s: SUITS, v: VALUES):
	suit = s
	value = v

func _to_string() -> String:
	return VALUES.keys()[value] + " of " + SUITS.keys()[suit]

# DEBUG ######################################################

## TODO: Deal with the problem of the ace being both the 
##       lowest and highest card.
##		Unless, of course, I won't actually need these functions.
## Returns the card one higher, null if this is the highest
#func get_next() -> Card:
	#if value == VALUES.king:
		#return null
	#return new(suit, value + 1)
	#
## Returns the card one lower, null if this is the lowest
#func get_previous() -> Card:
	#if value == VALUES.ace:
		#return null
	#return new(suit, value - 1)
#
## return the same card in a different suit
#func get_next_suit() -> Card:
	#return new((suit + 1) % 4, value)

