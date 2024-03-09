@icon("res://icons/card.svg")
class_name CardUI
extends Node2D

## Abstraction of a card from a UI perspective.
##
## A CardUI instance should pretty much always be in a
## stack, except immediately after instantiation.

@onready var front: AnimatedSprite2D = $Front
@onready var back: Sprite2D = $Back
@onready var draggable: Draggable = $Draggable

const flip_animation_name := "flip_card"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var flip_animation: Animation = animation_player.get_animation(flip_animation_name)

# TODO Work out how to make this more immutable
## The card that this UI is currently representing
var card: Card

## The stack the card currently is in
var stack: CardStackUI

## True if the card is still moving
var moving := false

## The preferred constructor for this scene/class
#
## This class shouldn'[t be used outside of the scene, and the scene shouldn't be 
## used without holding a card. So, you should use this constructor
## only
static func new_instance(
			_stack: CardStackUI, 
			_card: Card
		) -> CardUI:
	# FIXME I can't seem to be able top ruse preload here
	# 
	var my_scene: PackedScene = load("res://scenes/card_ui.tscn")
	var new_card_ui: CardUI = my_scene.instantiate() as CardUI
	new_card_ui.stack = _stack
	new_card_ui.card = _card
	new_card_ui.name = new_card_ui.to_string()
	return new_card_ui


func _ready():
	front.set_card(card)

## Move the card to this location
##
## This is controlled by the draggable, so see the configuration
## of the animation over there.
func move_to(pos: Vector2):
	#print("Start move")
	moving = true
	await draggable.move_to(pos)
	moving = false
	#print("End move")

# --- VISUAL STUFF -----

# TODO All of this relying on the visiblility of the back
# creates mild race conditions. The animation might still be playing
# when asked to close again. However, it's very unlikely
# this ever happens, and I don't think it can lead to real bugs,
# just incorrect  replays of animations
func is_closed() -> bool:
	return back.visible
func is_open() -> bool:
	return not is_closed()


## Show the front of the card
func open():
	if not is_node_ready():
		await self.ready
	if is_closed():
		animation_player.speed_scale = UIConfig.flip_animation_speed_scale
		animation_player.play(flip_animation_name)
		#print("Set animation scale to %d (from %d)" % [animation_player.speed_scale, UIConfig.flip_animation_speed_scale])


## Show the backl of the card
func close():
	if not is_node_ready():
		await self.ready
	if is_open():
		animation_player.speed_scale = UIConfig.flip_animation_speed_scale
		animation_player.play_backwards(flip_animation_name)
		#print("Set animation scale to %d" % animation_player.speed_scale)


## Flip the card over to the other side
func flip():
	if is_closed():
		open()
	else:
		close()


## Returns true if thios card is in the given stack
func is_in_stack(s: CardStackUI) -> bool:
	#return s.is_ancestor_of(card)
	return s == stack

# ---- Methods to deal with hierarchical stacks of cards
# ----- For flexibility we will allow multiple children
# ----- even though we don't need them yet
#
# ----- These functions mirror some of the [Node] functions

# For adding and removing, add_child() and remove_child() 
# can be used. No special handling required

## Get all the child cards
##
## Used by the hierarchical card stacks
func get_child_cards() -> Array[CardUI]:
	var out: Array[CardUI] = []
	for c in get_children().filter(func(n): return n is CardUI):
		out.append(c)
	return out


## Does this card have child cards?
##
## Used by the hierarchical card stacks
func has_child_card() -> bool:
	return not get_child_cards().is_empty()


## How many child cards does this array have?
##
## Used by the hierarchical card stacks
func get_child_card_count() -> int:
	return not get_child_cards().size()


# When debugging is enabled, this allows
# some keys to manipulate cards that are being 
# hovered over
func _unhandled_input(event: InputEvent):
	if not UIConfig.debug:
		return
	if event.is_action_pressed("debug_flip"):
		if draggable.hovering and draggable.on_top(Draggable.GROUP):
			print("Flipping %s in stack %s" % [self, self.stack.get_path()])
			flip()


func _to_string() -> String:
	return "CardUI(%s)" % card
