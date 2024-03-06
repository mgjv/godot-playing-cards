extends Node2D

@export var source_deck : CardStackUI
@export var initial_number_of_cards := 1

@onready var closed: CardStackUI = $ClosedCards
@onready var open:   CardStackUI = $OpenCards

# Called when the node enters the scene tree for the first time.
func _ready():
	if not source_deck:
		push_error("No Source Deck set for %s" % get_path())
		get_tree().quit()
	
	for i in initial_number_of_cards - 1:
		_add_clossed_card(source_deck.top_card())
	_add_open_card(source_deck.top_card())


func _add_clossed_card(card: CardUI):
	closed.add_card(card)
	card.move_to(global_position)


func _add_open_card(card: CardUI):
	open.add_card(card)
	card.move_to(global_position)
	card.open()
	card.draggable.active = true
