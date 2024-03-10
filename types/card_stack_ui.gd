@icon("res://icons/card.svg")
class_name CardStackUI
extends Node2D


## A Card Stack managing CardUI instances
##
## The only children of one of these nodes should be CardUI instances
## Ideally, no one else mucks around with the children.

## Manage children as a hierarchy
##
## A normal stack manages its children as a pile. Yu can take things 
## from the top or you can take things from the bottom
##
## When [member hierarchical] is true, the cards are managed
## as a hierarchy. This generally means that when you pick up a 
## child in the middle, that you also get all opf its children.
##


## Is this a stack of cards facing up (open) or down (closed)
@export var open := false


## Emitted when the stack changes
##
## added will be set to true if one or more cards were added, false if
## one or more cards were lost.
## NOTE that this signal is not emiited for every card
signal stack_changed(added: bool)

const GROUP = "card_stacks"

func _ready():
	#print("%s ready" % get_path())
	add_to_group(GROUP)


## Called when a card is taken from this stack by anmother stack
func _lost_card(_card: CardUI):
	#print("%s lost %s" % [Util.trimmed_path(self), _card])
	stack_changed.emit(false)
	
	_validate_stack()


## add a card to the stack (on top)
##
## Note that this does NOT move the card. The caller is 
## responsible for moving it, by either explicitly
## moving the card, or by letting a droppable do it
func add_card(card: CardUI):
	#print("Adding %s to %s" % [card, self.get_path()])
	_add_card(card)
	stack_changed.emit(true)
	
	_validate_stack()


func _validate_stack():
	for c in cards():
		if c.stack != self:
			push_error("%s is in %s, but thinks %s" % [c, Util.trimmed_path(self), Util.trimmed_path(c.stack)])


func _add_card(card: CardUI):
	#print("%s adding card %s" % [Util.trimmed_path(self), card])
	var old_stack := card.stack
	
	_add_card_as_child_and_move(card)
	
	card.stack = self
	# Inform the previous stack, if there was one
	if old_stack:
		old_stack._lost_card(card)
	
	if self.open:
		card.open()
	else:
		card.close()
	


# actually place the child in the stack
# this is a separate function so it can be easily overriden
func _add_card_as_child_and_move(card):
	if card.get_parent():
		# Use reparent here instead of remove_child()
		# followed by add_child() to preserve the global_position
		card.reparent(self, true)
	else:
		add_child(card)
	
	card.move_to(global_position)


## Get an array of the cards in this stack
##
## This may be useful if you want to iterate over them, maybe to 
## all move them to a different stack, one by one.
func cards() -> Array[CardUI]:
	var _cards: Array[CardUI] = []
	for n in get_children():
		_cards.append(n)
	return _cards


## Returns true is the given card is in this stack
##
func has_card(card: CardUI) -> bool:
	#return is_ancestor_of(card)
	return card.stack == self
	

## How many cards are on the stack?
func size() -> int:
	# TODO We should ensure that we never have children that are not
	# of type CardUI, or we have to filter here
	return get_child_count()


## Is this card stack empty?
# This should work for any implementation that only has 
# CardUI children, no matter how they're organised
func is_empty() -> bool:
	return get_child_count() == 0


## Get the top card
func top_card() -> CardUI:
	return get_child(-1)

## DEBUG ONLY. THIS COULD CREATE PROBLEMS. DO NOT CALL

func _DEBUG_KILL():
	# Nuke all the cards on this stack.
	# Only here for debugging purposes
	for c in get_children():
		remove_child(c)
		c.queue_free()
	stack_changed.emit(false)
