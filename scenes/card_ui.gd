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

func open():
	if card:
		animation_player.play("flip_card")

func close():
	if card:
		animation_player.play_backwards("flip_card")

func flip():
	if back.visible:
		open()
	else:
		close()

#func _input(event: InputEvent):
	#if not card:
		#return
