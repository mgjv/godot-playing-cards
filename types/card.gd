@icon("res://icons/card.svg")
class_name Card
extends Resource

## Card represents the data needed for a playing card
##
## A Card instance is immutable, so the constructor
## takes a suit and value.
##

# NOTE The order and value of both of these enums is 
# important. There have been internal assumptions made.
# Do not change without checking the code
enum SUITS {
	clubs, diamonds, spades, hearts,
}

enum VALUES {
	ace = 1,
	two, three, four, five, six, seven, eight, nine, ten,
	jack, queen, king,
}

enum COLORS {
	red, black
}

## The suit of this card (Read Only)
var suit : SUITS
## The value of this card (Read Only)
var value : VALUES
## The color of this card (Read Only)
var color : COLORS:
	get:
		if suit == SUITS.spades or suit == SUITS.clubs:
			return COLORS.black
		else:
			return COLORS.red


## Constructor
func _init(s: SUITS, v: VALUES):
	suit = s
	value = v


func _card_diff(other: Card, ace_is_low: bool) -> int:
	var diff = value - other.value
	if not ace_is_low:
		if value == VALUES.ace:
			diff += 13
		if other.value == VALUES.ace:
			diff -= 13
	return diff


## Returns true if this card is next in order and of the same suit
##
## by default the ace is regarded as smaller than the two,
## which can be changed with the optional ace_is_low argument
func is_next(other: Card, ace_is_low = true) -> bool:
	var diff := _card_diff(other, ace_is_low)
	if diff == 1 and suit == other.suit:
		return true
	else:
		return false


## Returns true if this card is previous in order and of the same suit
## 
## Also see [method is_next]
func is_previous(other: Card, ace_is_low = true) -> bool:
	return other.is_next(self, ace_is_low)


## Returns true if this card is next in order and of a different colour
## 
## This one is common for solitaire games
##
## by default the ace is regarded as smaller than the two,
## which can be changed with the optional ace_is_low argument
func is_next_rb(other: Card, ace_is_low = true) -> bool:
	var diff := _card_diff(other, ace_is_low)
	if diff == 1 and color != other.color:
		return true
	else:
		return false


## Returns true if this card is previous in order and of a different colour
## 
## Also see [method is_next_rb]
func is_previous_rb(other: Card, ace_is_low = true) -> bool:
	return other.is_next_rb(self, ace_is_low)


## Returns true if this card is the same as the given one
func is_same_as(card: Card) -> bool:
	if suit == card.suit and value == card.value:
		return true
	else:
		return false


func _to_string() -> String:
	return VALUES.keys()[value - VALUES.ace] + " of " + SUITS.keys()[suit]
