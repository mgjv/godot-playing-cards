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
## TODO implement
@export var hierarchical := false

## Is this a stack of cards facing up (open) or down (closed)
@export var open := false


# TODO Implement signals when the card stack changes?
#      because cards can be taken off the stack without
#      going through a method here, we probably need to 
#      handlers for the child_order_changed signal. This
#      will be hard for hierarchical stacks
#
#		Another alternative is to only allow add_card
# 		to move cards between stacks.

## Emitted when the stack changes
##
## added will be set to true if one or more cards were added, false if
## one or more cards were lost.
## NOTE that this signal is not emiited for every card
signal stack_changed(added: bool)

const GROUP = "card_stacks"

func _ready():
	add_to_group(GROUP)


## Called when a card is taken from this stack by anmother stack
func _lost_card(_card: CardUI):
	#print("%s got told they lost %s" % [get_path(), _card])
	stack_changed.emit(false)


## add a card to the stack (on top)
##
## Note that this does NOT move the card. The caller is 
## responsible for moving it, by either explicitly
## moving the card, or by letting a droppable do it
func add_card(card: CardUI):
	_add_card(card)
	stack_changed.emit(true)

# TODO Check and maybe fix for hierarchical stack
# Private version of add_card, to avoid 
func _add_card(card: CardUI):
	#print("%s adding card %s" % [get_path(), card])
	if card.get_parent():
		var old_stack := card.stack
		card.reparent(self)
		card.stack = self
		old_stack._lost_card(card)
	else:
		add_child(card)

	if self.open:
		card.open()
	else:
		card.close()
	
	# TODO Need to take offsets into account for 
	# Hierarchical stacks?
	await card.move_to(global_position)

# TODO Fix for hierarchical stack
## Get an array of the cards in this stack
##
## This may be useful if you want to iterate over them, maybe to 
## all move them to a different stack, one by one.
func cards() -> Array[CardUI]:
	var _cards: Array[CardUI] = []
	for n in get_children():
		_cards.append(n)
	return _cards

# TODO Fix for hierarchical stack
## How many cards are on the stack?
func size() -> int:
	# TODO We should ensure that we never have children that are not
	# of type CardUI, or we have to filter here
	return get_child_count()


## Is this card stack empty?
func is_empty() -> bool:
	return get_child_count() == 0

# TODO Fix for hierarchical stack
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
