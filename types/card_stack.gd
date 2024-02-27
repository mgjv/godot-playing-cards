class_name CardStack
extends Resource

## Manage a stack of playing cards
##
## Cards are added at the bottom, "open" (i.e. the front of 
## the card is visible) side, and taken from the top, 
## "closed" side.


# In the below, this is the mapping of words:
#
#  deck   |  Array  |  card
# --------+---------+--------------
#  top    |  back   |  closed/back
#  bottom |  front  |  open/front


var cards: Array[Card]

## The top card on the stack
var top_card: Card:
	get:
		return cards.back()
	set(c):
		push_error("Cannot set top card")
		
## The bottom card on the stack
var bottom_card: Card:
	get:
		return cards.front()
	set(c):
		push_error("Cannot set bottom card")

## Take a card from the top
func take_card() -> Card:
	return cards.pop_back()
	
## Add a card to the bottom
func add_card(card: Card) -> void:
	cards.push_front(card)

func size() -> int:
	return cards.size()

func shuffle():
	cards.shuffle()
