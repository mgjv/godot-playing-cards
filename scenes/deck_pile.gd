extends Node2D

@onready var stack: CardStackUI = $CardStackUI

func _ready():
	new_deck()
	print("Created deck with %d cards" % stack.get_child_count())
	print("Top card is %s and bottom %s" % [stack.top_card(), stack.bottom_card()])
	show_top_card()

func new_deck():
	var deck = Deck.new()
	deck.shuffle()
	
	for card_value in deck.cards:
		var new_card := stack.add_card(card_value)
		new_card.dragdrop.draggable = false
		new_card.dragdrop.is_drop_target = false
		# FIXME DEBUG
		#new_card.front.position.x -= 15 * stack.get_child_count()
		#new_card.back.position.x -= 15 * stack.get_child_count()
		#new_card.back.position.y -= 50

func show_top_card():
	var top_card := stack.top_card()
	if top_card:
		print("Opening on top card %s" % top_card )
		top_card.open()
		top_card.dragdrop.draggable = true
	else:
		print("whoops, The deck is empty")

	#stack.bottom_card().open()
