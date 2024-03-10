@tool
class_name BuildPile
extends Node2D

@export var source_deck : FullCardStackUI:
	set(s):
		source_deck = s
		update_configuration_warnings()

@export var initial_number_of_cards := 0

@onready var closed: CardStackUI = $ClosedCards
@onready var open:   CardStackUI = $OpenCards
@onready var card_droppable := $CardDroppable

const GROUP = "build_piles"

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		return
	
	if not source_deck:
		print_debug("No Source Deck set for %s" % get_path())
		queue_free()
		return
	
	add_to_group(GROUP)
	_take_initial_cards()


func _take_initial_cards():
	if source_deck.size() < initial_number_of_cards:
		push_error("There are no cards for me to pick up. I am probably being initialised before ")
	if initial_number_of_cards > 0:
		for i in initial_number_of_cards - 1:
			_add_closed_card(source_deck.top_card())
		_add_open_card(source_deck.top_card())


func _add_closed_card(card: CardUI):
	closed.add_card(card)


func _add_open_card(card: CardUI):
	open.add_card(card)
	card.draggable.active = true


# FIXME We should manage the droppables better, so this only gets called
# when both stacks are empty, rather than all the time. 
# This will require state maintenance on the stacks. Maybe I need
# signals on CardStackUI?


# We will only receive a drop if we're empty and 
# the dragged card is a king
func _can_receive_drop(node: Node2D):
	if not node is CardUI:
		push_error("%s received non-CardUI drop: %s(%s)" % [get_path(), node, node.get_path()])
		return false

	if open.is_empty() and closed.is_empty():
		var card := (node as CardUI).card
		if card.value == Card.VALUES.king:
			return true

	return false


## Called when a card is dropped on either the 
## empty stack, or the top card.
func _on_received_drop(node):
	var card: CardUI = node as CardUI
	open.add_card(card)


## Called when cards are added or removed from 
## the open stack
func _on_open_cards_stack_changed(_added: bool):
	if open.is_empty():
		# Open the next card from the closed stack
		if not closed.is_empty():
			var card = closed.top_card()
			open.add_card(card)
			card.draggable.active = true
			card.open()
	else:
		# The top card actively listen for drops
		card_droppable.attach_to_card(open.top_card())


func _get_configuration_warnings():
	var warnings = []
	if !source_deck:
		warnings.append("A Source Deck needs to be set.")
	return warnings
