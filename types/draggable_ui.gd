@tool
class_name DraggableUI
extends Node

## How much to increase the Z index while dragging
@export_range(0, 50, 5) var z_index_lift: int = 25

@export_group("Move Animation", "move_animation_")
@export var move_animation_type: Tween.TransitionType = Tween.TRANS_CUBIC
@export_range(0.0, 1.0, 0.05) var move_animation_duration: float = 0.25

@export_group("Scale Animation", "scale_animation_")
@export var scale_animation_type: Tween.TransitionType  = Tween.TRANS_CUBIC
@export_range(0.0, 1.0, 0.05) var scale_animation_duration: float = 0.25
@export_range(1.0, 1.5, 0.05) var scale_animation_size: float = 1.2

## Add-on functionality for a draggable
## 
## Drag this in as the child of a draggable, and configure it.
## wiring up should happen automatically

# The below will crash if the parent isn't a Draggable
@onready var draggable: Draggable = get_parent()

func _ready():
	if Engine.is_editor_hint():
		return
	
	draggable.start_drag.connect(_on_start_drag)
	draggable.stop_drag.connect(_on_stop_drag)
	draggable.dropped.connect(_on_dropped)
	
	draggable._move_func = move_cnode_to

# We need to ensure that a draggable is always at the top
# while being dragged
var _previous_z_index := 0


func _on_start_drag():
	_previous_z_index = draggable.controlled_node.z_index
	draggable.controlled_node.z_index += z_index_lift
	scale_cnode(scale_animation_size)

	
func _on_stop_drag():
	# Wait until the scaling animation is finished 
	# before resetting the z index.
	# This isn't a guarantee that it'll be allright,
	# but it will be as long as people don't set the animation
	# speeds to stupid values.
	await scale_cnode(1.0)
	draggable.controlled_node.z_index = _previous_z_index


func _on_dropped(droppable: Droppable):
	if false and not droppable:
		move_cnode_to(draggable.drag_position)


func move_cnode_to(pos: Vector2):
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(move_animation_type)
	tween.tween_property(draggable.controlled_node, "global_position", pos, move_animation_duration)


func scale_cnode(new_scale: float):
	var tween = get_tree().create_tween()
	tween.set_trans(scale_animation_type)
	tween.tween_property(draggable.controlled_node, "scale", new_scale * Vector2.ONE, scale_animation_duration)
	await tween.finished


func _get_configuration_warnings():
	var warnings = []
	var parent = get_parent()
	if not (parent and parent is Draggable):
		warnings.append("Can only be a child of a Draggable.")
	return warnings
