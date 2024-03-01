class_name CardUI
extends Node2D

@onready var front := $Front
@onready var back := $Back
@onready var animation_player := $AnimationPlayer
@onready var dragdrop := $DragDropController

## The card that this UI is currently representing
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


## Show the front of the card
func open():
	if card:
		animation_player.play("flip_card")


## Show the backl of the card
func close():
	if card:
		animation_player.play_backwards("flip_card")


## Flip the card over to the other side
func flip():
	if back.visible:
		open()
	else:
		close()


func process(_delta: float):
	dragdrop.process(_delta)


func _on_ddc_click():
	print("Clicked")
	pass


func _on_ddc_drag():
	print("Drag offset ", dragdrop.offset, ", coming from ", dragdrop.drag_position)
	pass


func _on_ddc_drop():
	print("Dropped at ", get_global_mouse_position())
	#global_position = dragdrop.drag_position
	dragdrop.cancel_drag()
	

