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
		#print("SET ", card)

func _ready():
	# trigger the setter so display is correct
	card = card

func flip():
	if not card:
		return
	if back.visible:
		animation_player.play("flip_card")
	else:
		animation_player.play_backwards("flip_card")

#func _input(event: InputEvent):
	#if not card:
		#return
