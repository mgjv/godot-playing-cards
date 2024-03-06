class_name CardUI
extends Node2D

@onready var front: AnimatedSprite2D = $Front
@onready var back: Sprite2D = $Back
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var draggable: Draggable = $Draggable
@onready var droppable: Droppable = $Droppable

const my_scene: PackedScene = preload("res://scenes/card_ui.tscn")

# TODO Work out how to make this more immutable
# TODO Allow choice about which direction(s0) the card rotation goes in

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


## The preferred constructor for this scene/class
#
## This class shouldn'[t be used outside of the scene, and the scene shouldn't be 
## used without holding a card. So, you should use this constructor
## only
static func new_from_card(_card: Card) -> CardUI:
	var new_card_ui: CardUI = my_scene.instantiate() as CardUI
	new_card_ui.card = _card
	return new_card_ui


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


## Move the card to this location
##
## This is cpnrolled by the draggable, so see the configuration
## of the animation over there.
func move_to(pos: Vector2):
	draggable.move_to(pos)


func _to_string() -> String:
	return "CardUI(%s)" % card
