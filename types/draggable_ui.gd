@tool
@icon("res://icons/draggable.svg")
class_name DraggableUI
extends Node


## Add-on functionality for a draggable
## 
## You probably never have to explicitly instantiate this.
## Draggables and Droppables have properties to include this
## 

# TODO  add possibilities to override 
# the UIConfig properties in individual instances
# We should probably use a boolean to control whether
# the whole thing is overriden, and if so, implement
# a "get_property()" that validates against 
# properties in UIConfig

# The below will crash if the parent isn't a Draggable
@onready var draggable: Draggable = get_parent()

func _ready():
	if Engine.is_editor_hint():
		return
	
	if not get_parent() is Draggable:
		push_error("Parent is not a Draggable! Exiting")
		queue_free()
	
	draggable.start_drag.connect(_on_start_drag)
	draggable.stop_drag.connect(_on_stop_drag)
	draggable.dropped.connect(_on_dropped)
	
	draggable._move_func = move_cnode_to

# We need to ensure that a draggable is always at the top
# while being dragged
var _previous_z_index := 0


func _on_start_drag():
	_previous_z_index = draggable.control_node.z_index
	draggable.control_node.z_index += UIConfig.z_index_lift
	scale_cnode(UIConfig.scale_animation_size)

	
func _on_stop_drag():
	# Wait until the scaling animation is finished 
	# before resetting the z index.
	# This isn't a guarantee that it'll be allright,
	# but it will be as long as people don't set the animation
	# speeds to stupid values.
	await scale_cnode(1.0)
	draggable.control_node.z_index = _previous_z_index


func _on_dropped(droppable: Droppable):
	if false and not droppable:
		move_cnode_to(draggable.drag_position)


func move_cnode_to(pos: Vector2):
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(UIConfig.move_animation_type)
	tween.tween_property(draggable.control_node, "global_position", pos, UIConfig.move_animation_duration)
	await tween.finished
	

func scale_cnode(new_scale: float):
	var tween = get_tree().create_tween()
	tween.set_trans(UIConfig.scale_animation_type)
	tween.tween_property(draggable.control_node, "scale", new_scale * Vector2.ONE, UIConfig.scale_animation_duration)
	await tween.finished


func _get_configuration_warnings():
	var warnings = []
	var parent = get_parent()
	if not (parent and parent is Draggable):
		warnings.append("Can only be a child of a Draggable.")
	return warnings


func _to_string():
	if get_parent():
		return "UI(%s)" % get_parent()
	else:
		# because we might not be in a tree yet
		return super.to_string()
