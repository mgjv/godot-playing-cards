class_name HierarchicalCardStackUI
extends CardStackUI

## A CardStackUI that presents its cards as an open hierarchy
##
## The main application for a stack like this is to 
## play games like solitaire, where an open stack is presented
## with the cards partially overlapping, allowing you to 
## pick up a subset of the cards as a whole, and move them.
##
## See [CardStackUI] for the documentatiopn on what the methods
## do.


# TODO
# This is all going to be a little hacky because cards will become 
# children of cards (so I get scaling, dragging, movements etc for free
# but it seems that we shoul db able to make it less
# hacky with the 'internal' mode for Node.add_child().
#
# For now, I'll implement a method in CardUI that returns its CardUI 
# children.

## The vector by which to offset overlapping cards
@export var offset: Vector2 = Vector2.DOWN * 25

# This is a major change to the implementation of the parent,

# In a hierarchical stack, the cards are children of each other
# and each child os offset in the ui. This offset is normally a
# Vector down, but can go in any direction.
#
# The top card is always the last card in the hierarchy


# actually place the child in the stack
# this is a separate function so it can be easily overriden
#
# This returns how many children we now have
func _add_card_as_child_and_move(card: CardUI):
	var top = _hierarchy_top()
	var pre_drop_size = size()
	if card.get_parent():
		#print("Reparenting card %s to %s (%d)" %[card, top, pre_drop_size])
		card.reparent(top, true)
	else:
		#print("Adding card %s to %s (%d)" %[card, top, pre_drop_size])
		top.add_child(card)
	
	# FIXME
	# The responsibility for this for this card lies with the 
	# superclass, so it's icky that I'm doing it here
	for c in card.flatten_child_cards():
		c.stack = self
	
	card.move_to(global_position + offset * (pre_drop_size))


# This returns the top of the hierarchy, which is
# either a card, or the stack itself.
func _hierarchy_top() -> Node:
	var top := top_card()
	return top as Node if top else self as Node


func cards() -> Array[CardUI]:
	var out: Array[CardUI] = []
	if get_child_count():
		for card: CardUI in get_children().filter(func(n): return n is CardUI):
			_append_next_card(card, out)
	return out


func _append_next_card(card: CardUI, out: Array[CardUI]):
	for child_card in card.get_child_cards():
		_append_next_card(child_card, out)
	out.append(card)


func size() -> int:
	return cards().size()


func top_card() -> CardUI:
	if get_child_count() == 0:
		return null
	return _get_top_card(get_child(-1) as CardUI)


# recursively walk down the cards and return the tail
func _get_top_card(card: CardUI) -> CardUI:
	if not card.has_child_card():
		return card
	else:
		return _get_top_card(card.get_child_cards()[0])
		

