class_name CardStackUI
extends Node2D

## A Card Stack managing CardUI instances
##
## The only children of one of these nodes should be CardUI instances
## ideally, no one else mucks around with the children.

## Add a full deck of cards to this stack
##
## By default the deck will be randomly shuffled. Set the 
## [param shuffle] argument to false to prevent this
func add_full_deck(shuffle := true):
	var deck = Deck.new()
	if shuffle:
		deck.shuffle()
	for card in deck.cards:
		var new_card := CardUI.new_from_card(card)
		add_card(new_card)


## add a card to the stack (on top)
func add_card(card: CardUI):
	# TODO If this card already has another parent, 
	# we need to reparent it
	if card.get_parent():
		card.reparent(self)
		card.move_to(global_position)
	else:
		add_child(card)


## Get an array of the cards in this stack
##
## This may be useful if you want to iterate over them, maybe to 
## all move them to a different stack, one by one.
func cards() -> Array[CardUI]:
	var _cards: Array[CardUI] = []
	for n in get_children():
		_cards.append(n)
	return _cards


## How many cards are on the stack?
func size():
	# TODO We should ensure that we never have children that are not
	# of type CardUI, or we have to filter here
	return get_child_count()


## Get the top card
func top_card() -> CardUI:
	return get_child(-1)


## Get the bottom card
func bottom_card() -> CardUI:
	return get_child(0)


## Move all cards from this stack to another
## optionally inverting their order (which you would
## need if the whole stack needs to be flopped from open 
## to closed or the other way around
## If flip is true, the cards will also be flipped
func move_cards_to(stack: CardStackUI, flip := false):
	var movers := cards()
	if flip:
		movers.reverse()
	for mover in movers:
		if flip:
			mover.flip()
		stack.add_card(mover)
