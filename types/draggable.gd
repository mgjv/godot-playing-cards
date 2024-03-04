@tool
class_name Draggable
extends Hoverable

## Handle dragging for any Node2D
##
## Add this as a child for a node you want to be draggable. Configure the 
## [member Draggable.controlled_node] to indicate which node you want
## to be the one that gets moved and can be dropped on a [Droppable].
##
## This component will handle much of the normal movement, animations and 
## reactions associated with dragging and dropping, including 
## returning an item to its original position when dropped without a 
## target that can accept it.
##
## Also see [Droppable]

@export var controlled_node : Node2D:
	set(node):
		controlled_node = node
		update_configuration_warnings()

@export var active := true

## Control the type and length of the animation for cancellation of a drag
## See the documentation for [Tween]
@export var move_animation_type: Tween.TransitionType
@export_range(0.0, 1.5, 0.05) var move_animation_duration: float = 0.25

## Emitted when a full click has occured
signal click

## emitted at the start and end of a dragging operation
##
## The parameter offset is the offset of the click to the (0,0)
## position. This can be used to implement following the mouse
signal start_drag
signal stop_drag

# TODO This signal should include the item dropped and the draggable

# emitted when the item is dropped
signal drop

# The group we use to identify these nodes
# Things will break if someone else uses the same group name
const GROUP = "draggable_group"

## tracks whether the mouse button is pressed.
## you probably don't need to look at this, ever.
var mouse_down := false

## Indicates whether the item is currently being dragged
var dragging := false

## The offset of the initial click to the position
## of the Controlled Node
var offset := Vector2.ZERO

## This is the position the controlled node
## orignally was before dragging
var drag_position := Vector2.ZERO

## This is the current drop target
## This is managed by the Droppable class entirely
var drop_target : Droppable


func _ready():
	if Engine.is_editor_hint():
		return

	# Add ourselves to pur group
	add_to_group(GROUP, true)
	

# Update position while dragging
func _process(_delta: float):
	if Engine.is_editor_hint():
		return

	if dragging:
		self.controlled_node.global_position = get_global_mouse_position() - offset


# Process mouse events we're interested in
func _input_event(_viewport, event, _shape_idx):
	# If the mouse button is down and we move, start a drag
	if not dragging and mouse_down and event is InputEventMouseMotion:
		_start_drag()
		return
	
	# For performance reasons we do not process any mouse motion after this line
	if event is InputEventMouseMotion:
		return
	
	# If we're not the top node in our group, we don't
	# want to process 
	#if not on_top(GROUP):
	#	return
		
	# Process mouse buttons
	if event is InputEventMouseButton:
		if event.pressed:
			if on_top(GROUP):
				mouse_down = true  
		else:
			mouse_down = false
			if dragging:
				_drop()


# Process keys that we're interested in
func _unhandled_input(event):
	if dragging and event.is_action_pressed("ui_cancel"):
		cancel_drag()


func _drop():
	# FIXME: Should this be done by listening to the signal instead?
	#Droppable.process_drop(self)
	dragging = false
	mouse_down = false
	stop_drag.emit()
	drop.emit()
	if drop_target:
		drop_target.receive_drop(self)
		drop_target = null
	else:
		cancel_drag()


func _start_drag():
	if not active:
		return
	offset = get_global_mouse_position() - self.controlled_node.global_position
	drag_position = self.controlled_node.global_position
	dragging = true
	start_drag.emit()


## Call this to cancel the drag (for example if the drop happens
## in a non-interesting area.
func cancel_drag():
	# Stop following the mouse, and rest click state
	if dragging:
		stop_drag.emit()
	dragging = false
	mouse_down = false
	# Return the item to its start position
	if self.controlled_node:
		move_to(drag_position)


func move_to(pos: Vector2):
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(move_animation_type)
	tween.tween_property(self.controlled_node, "global_position", pos, move_animation_duration)


func _to_string() -> String:
	# Node.name is type StringName not String
	var cname: String = self.controlled_node.name if self.controlled_node else &"<null>"
	return "Draggable{%s}" % cname

func _get_configuration_warnings():
	var warnings = []
	if !controlled_node:
		warnings.append("A controlled node needs to be set.\nMost likely you want to select the parent node.")
	return warnings
