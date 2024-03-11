class_name UIConfigClass
extends Node

## UI configuration.
##
## This is an Autoload Singleton SCENE to hold configuration for 
## animation properties across the application
##
## This his a scene, so we can configure it in the Godot editor.

## Nodes that are in this group ("debug") can be controlled from here
const DEBUG_GROUP := "debug"

## Switch on or off all debug displays
##
@export var debug := false:
	set(v):
		debug = v
		if is_node_ready():
			setup_debug_nodes()


## How much to increase the Z index while dragging
@export_range(0, 50, 5) var z_index_lift: int = 25


@export_group("Move Animation", "move_animation_")
## In what way cards get moved around
@export var move_animation_type: Tween.TransitionType = Tween.TRANS_CUBIC
## How quickly cards get moved around
@export_range(0.0, 1.0, 0.05) var move_animation_duration: float = 0.25


@export_group("Scale Animation", "scale_animation_")
## How dragged and dropped items scale up and back
@export var scale_animation_type: Tween.TransitionType  = Tween.TRANS_CUBIC
## How fast dragged and dropped items scale up and back
@export_range(0.0, 1.0, 0.05) var scale_animation_duration: float = 0.25
## How much dragged and dropped items scale up and back
@export_range(1.0, 1.5, 0.05) var scale_animation_size: float = 1.2


## What speedscale should we use for the card flip
## animation 
##
## Note that this is directly dependent on (reciprocal to) 
## [member move_animation_duration]
var flip_animation_speed_scale: float:
	get:
		return 1.0/move_animation_duration
	set(v):
		move_animation_duration = 1.0/v


## Size of a card
const CARD_SIZE := Vector2(100, 140)


func _ready():
	await get_tree().current_scene.ready
	setup_debug_nodes()


## Set up all debug nodes (identified by DEBUG_GROUP)
## according to current settings
func setup_debug_nodes():
	for node in get_tree().get_nodes_in_group(DEBUG_GROUP):
		node.visible = debug
