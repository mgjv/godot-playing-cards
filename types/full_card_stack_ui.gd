class_name FullCardStackUI
extends CardStackUI

## A [CardStackUI] that can be filled with a full deck

## Whether this stack should initialise itself with a full randomised deck
##
## defaults to true
@export var initialise_full_deck := true


func _ready():
	super._ready()
	print("_ready for %s" % get_path())
	if initialise_full_deck:
		add_full_deck()


## Add a full deck of cards to this stack
##
## By default the deck will be randomly shuffled. Set the 
## [param shuffle] argument to false to prevent this
func add_full_deck(shuffle := true):
	var deck = Deck.new()
	if shuffle:
		deck.shuffle()
	for card in deck.cards:
		var new_card := CardUI.new_instance(self, card)
		_add_card(new_card)
	stack_changed.emit(true)
