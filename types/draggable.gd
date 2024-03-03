@tool
class_name Draggable
extends Area2D

## Handle dragging for any Node2D
##
## Add this as a child for a node you want to be draggable. Configure the 
## [member Draggable.controlled_node] to indicate which node you want
## to be the one that gets moved and can be dropped on a [Droppable].
##
## Also see [Droppable]

## The node that will be used to implement the drag
## move and animations. If you don't set this, you will
## have to handle drag movements yourself
@export var controlled_node : Node2D:
	set(n):
		controlled_node = n
		update_configuration_warnings()

## Is this a draggable item?
@export var active := true
## Is this a clickable item?
@export var clickable := true

## Control the type and length of the animation for cancellation of a drag
## See the documentation for [Tween]
@export var cancel_drag_animation_type: Tween.TransitionType
@export_range(0.0, 1.5, 0.05) var cancel_drag_animation_duration: float = 0.5

## Emitted when a full click has occured
signal click

## emitted at the start of a dragging operation
##
## The parameter offset is the offset of the click to the (0,0)
## position. This can be used to implement following the mouse
signal drag

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

## Indicates whether the mouse is over the item
var hovering := false

## The offset of the initial click to the position
## of the Controlled Node
var offset := Vector2.ZERO

## This is the position the controlled node
## orignally was before dragging
var drag_position := Vector2.ZERO


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
		controlled_node.global_position = get_global_mouse_position() - offset


# Process mouse events we're interested in
func _input_event(_viewport, event, _shape_idx):
	# If the mouse button is down and we move, start a drag
	if not dragging and mouse_down and event is InputEventMouseMotion:
		_start_drag()
		return
	
	# For performance reasons we do not process any 
	# Mouse motion after this line
	if event is InputEventMouseMotion:
		return
	
	# If we're not the top node in our group, we don't
	# want to process 
	if not on_top():
		return
		
	# Process mouse buttons
	if event is InputEventMouseButton:
		if event.pressed:
			mouse_down = true  
		else: 
			mouse_down = false
			if dragging:
				_drop()
			else:
				_detect_click()


# Process keys that we're interested in
func _unhandled_input(event):
	if dragging and event.is_action_pressed("ui_cancel"):
		cancel_drag()


# TODO See shape_clicker.gd for a possible different approach

# Of all the Draggables under the mouse, am I the top one?
func on_top() -> bool:
	var draggables: Array[Node] = get_tree().get_nodes_in_group(GROUP) \
			.filter( func(node): return node.hovering )
	draggables.sort_custom(Util.cmp_nodes_by_overlap)
	if draggables[0] == self:
		#print("%s is on top" % self)
		return true
	return false


func _detect_click():
	if clickable:
		click.emit()


func _drop():
	# FIXME: Should this be done by listening to the signal instead?
	Droppable.process_drop(self)
	drop.emit()
	dragging = false


func _start_drag():
	if not active:
		return
	offset = get_global_mouse_position() - controlled_node.global_position
	drag_position = controlled_node.global_position
	dragging = true
	drag.emit()


## Call this to cancel the drag (for example if the drop happens
## in a non-interesting area.
func cancel_drag():
	# Stop following the mouse, and rest click state
	dragging = false
	mouse_down = false
	# Return the item to its start position
	if controlled_node:
		var tween = get_tree().create_tween()
		tween.set_trans(cancel_drag_animation_type)
		tween.tween_property(controlled_node, "global_position", drag_position, cancel_drag_animation_duration)
		await tween.finished


# Keep track of when the mouse is hovering over us
func _mouse_enter():
	if active:
		hovering = true
		#print("Hovering over %s" % controlled_node)

func _mouse_exit():
	if active:
		hovering = false
		#print("Hovering over %s" % controlled_node)


func _to_string() -> String:
	# Node.name is type StringName not String
	var cname: String = controlled_node.name if controlled_node else &"<null>"
	return "Draggable{%s}" % cname


func _get_configuration_warnings():
	var warnings = []
	if !controlled_node:
		warnings.append("A controlled node needs to be set.\nMost likely you want to select the parent node.")
	return warnings
	
