class_name UIConfigClass
extends Node

## UI configuration.
##
## This is an Autoload Singleton SCENE to hold configuration for 
## animation properties across the application
##
## This his a scene, so we can configure it in the Godot editor.


## Switch on all debug displays
##

@export var debug := false:
	set(v):
		debug = v
		if is_node_ready():
			setup_debug_nodes()


## Nodes that are in this group ("debug") will be taken into
## account
const DEBUG_GROUP := "debug"

## How much to increase the Z index while dragging
@export_range(0, 50, 5) var z_index_lift: int = 25

## How dropped items get moved around
@export_group("Move Animation", "move_animation_")
@export var move_animation_type: Tween.TransitionType = Tween.TRANS_CUBIC
@export_range(0.0, 1.0, 0.05) var move_animation_duration: float = 0.25

## How dragged and dropped items scale up and back
@export_group("Scale Animation", "scale_animation_")
@export var scale_animation_type: Tween.TransitionType  = Tween.TRANS_CUBIC
@export_range(0.0, 1.0, 0.05) var scale_animation_duration: float = 0.25
@export_range(1.0, 1.5, 0.05) var scale_animation_size: float = 1.2

const CARD_SIZE := Vector2i(100, 140)
const CARD_CENTRE := CARD_SIZE/2

func setup_debug_nodes():
	for node in get_tree().get_nodes_in_group(DEBUG_GROUP):
		node.visible = debug
