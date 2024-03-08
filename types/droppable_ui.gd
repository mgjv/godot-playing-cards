@tool
class_name DroppableUI
extends Node

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
	scale_cnode(UIConfig.scale_animation_size)


func _on_untargeted():
	scale_cnode(1.0)


func scale_cnode(new_scale: float):
	var tween = get_tree().create_tween()
	tween.set_trans(UIConfig.scale_animation_type)
	tween.tween_property(droppable.control_node, "scale", new_scale * Vector2.ONE, UIConfig.scale_animation_duration)


func _get_configuration_warnings():
	var warnings = []
	var parent = get_parent()
	if not (parent and parent is Droppable):
		warnings.append("Can only be a child of a Droppable.")
	return warnings


func _to_string():
	if get_parent():
		return "UI(%s)" % get_parent()
	else:
		# because we might not be in a tree yet
		return super.to_string()
