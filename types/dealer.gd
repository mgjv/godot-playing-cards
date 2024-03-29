@tool
class_name Dealer
extends Node2D

# TODO This is all quite messy and ad-hoc. It would
# probably be better if this were a scene, rather than 
# a class trying to be generic

## Manage two piles for dealing
##
## Add this to your node tree. Configure a source deck 
## ([FullCardStackUI)] and a stack to turn the cards onto
## ([CardStackUI)], and the [Clickable]
## that catches a click on the source deck

## The cdeck to take cards from. 
##
## This should be comnfigured to initialise itself with a 
## full deck
@export var deck: FullCardStackUI:
	set(s):
		deck = s
		update_configuration_warnings()

## The stack to turn 
@export var stack: CardStackUI:
	set(s):
		stack = s
		update_configuration_warnings()


## The clickable to connect to
@export var clickable: Clickable:
	set(c):
		clickable = c
		update_configuration_warnings()



func _ready():
	if Engine.is_editor_hint():
		#_check_config_repeat()
		return
	
	if not deck or not stack or not clickable:
		print_debug("Dealer %s not configured correctly!")
		
	clickable.click.connect(_on_deck_click)


# Turn over the top card
func _turn_top_card():
	var card := deck.top_card()
	#print("Working on %s" % card)
	if card:
		card.open()
		card.draggable.active = true
		stack.add_card(card)


# Flip the cards from the stack back to the deck
func _reset_cards():
	# get the stack
	var cards := stack.cards()
	# flip the stack over
	cards.reverse()
	# move the cards, and flip each of them
	for card in cards:
		card.close()
		deck.add_card(card)
		card.move_to(deck.global_position)


# Called when the player clicks on the deck
func _on_deck_click():
	if deck.size() > 0:
		_turn_top_card()
	else:
		_reset_cards()


# ---- Just iused for tool script

# Unfortunately, there is no way to detect when the 
# deck and stack have changed in anmy way in the editor
# so the only way to rerun this is to switch away to another
# tab and switch back.
func _get_configuration_warnings():
	var warnings = []
	if !deck:
		warnings.append("I need a deck to be configured.")
	else:
		if not deck.initialise_full_deck:
			warnings.append("Attached deck will not initialise itself")
		if deck.open:
			warnings.append("Attached deck should not be open")

	if !stack:
		warnings.append("I need a stack to be configured.")
	else:
		if not stack.open:
			warnings.append("Attached stack should be open")

	if !clickable:
		warnings.append("I need a clickable to be configured.")
	return warnings
