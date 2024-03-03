class_name CardUI
extends Node2D

@onready var front: AnimatedSprite2D = $Front
@onready var back: Sprite2D = $Back
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var draggable: Draggable = $Draggable

## The card that this UI is currently representing
var card: Card:
	set(new_card):
		card = new_card
		if not is_node_ready():
			await self.ready
		if card:
			front.set_card(card)
		else:
			# If the card was open, make sure it's closed again
			back.visible = true
		#print("SET ", card)


func _ready():
	# trigger the setter so display is correct
	card = card


## Show the front of the card
func open():
	if card:
		if not is_node_ready():
			await self.ready
		animation_player.play("flip_card")


## Show the backl of the card
func close():
	if card:
		if not is_node_ready():
			await self.ready
		animation_player.play_backwards("flip_card")


## Flip the card over to the other side
func flip():
	if back.visible:
		open()
	else:
		close()


func _on_draggable_click():
	print("Clicked")
	pass


func _on_draggable_drag():
	print("Drag offset ", draggable.offset, ", coming from ", draggable.drag_position)
	pass


func _on_draggable_drop():
	print("Dropped at ", get_global_mouse_position())
	#global_position = dragdrop.drag_position
	draggable.cancel_drag()
	

func _to_string() -> String:
	return "CardUI(%s)" % card
