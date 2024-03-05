@tool
class_name DroppableUI
extends Node

@export_group("Scale Animation", "scale_animation_")
@export var scale_animation_type: Tween.TransitionType  = Tween.TRANS_CUBIC
@export_range(0.0, 1.0, 0.05) var scale_animation_duration: float = 0.25
@export_range(1.0, 1.5, 0.05) var scale_animation_size: float = 1.2

## Add-on functionality for a draggable
## 
## Drag this in as the child of a draggable, and configure it.
## wiring up should happen automatically

# The below will crash if the parent isn't a Draggable
@onready var droppable: Droppable = get_parent()

func _ready():
	if Engine.is_editor_hint():
		return
	
	droppable.targeted.connect(_on_targeted)
	droppable.untargeted.connect(_on_untargeted)


func _on_targeted():
	scale_cnode(scale_animation_size)


func _on_untargeted():
	scale_cnode(1.0)


func scale_cnode(new_scale: float):
	var tween = get_tree().create_tween()
	tween.set_trans(scale_animation_type)
	tween.tween_property(droppable.controlled_node, "scale", new_scale * Vector2.ONE, scale_animation_duration)


func _get_configuration_warnings():
	var warnings = []
	var parent = get_parent()
	if not (parent and parent is Droppable):
		warnings.append("Can only be a child of a Droppable.")
	return warnings
