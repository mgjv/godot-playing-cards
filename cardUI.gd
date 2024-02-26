class_name CardUI
extends Node2D

@onready var front := $Front
@onready var back := $Back
@onready var animation_player = $AnimationPlayer

var card: Card:
	set(new_card):
		card = new_card
		if card:
			front.set_card(card)
		else:
			back.visible = true
		print("SET ", card)

func _ready():
	# trigger the setter
	card = card

func flip():
	if not card:
		return
	if back.visible:
		animation_player.play("flip_card")
	else:
		animation_player.play_backwards("flip_card")

func _input(event: InputEvent):
	if not card:
		return
	if event.is_action_pressed("FLIP") and not animation_player.is_playing():
		flip()
		get_viewport().set_input_as_handled()
	else:
		if event.is_action_pressed("debug_decrease_value"):
			card = card.get_previous()
		elif event.is_action_pressed("debug_increase_value"):
			card = card.get_next()
		elif event.is_action_pressed("debug_rotate_suit"):
			card = card.get_next_suit()

