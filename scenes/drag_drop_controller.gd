class_name DragDropController
extends Area2D

## Handle input events related to mouse movement
##
## Specifically control clicking, dragging and dropping
## abstractions
##
## Add it to your scene tree, configure the Controlled Node 
## (Normally the top level item you want to drag around), and 
## implement handlers for the signals you need to 
## react to.
##
## Under normal circumstances, it should be possible to only
## configure the Controlled Node to implement most 
## functionality, including following the mouse on dragging

# TODO
#  - icorporate drop detection (probably requires area2d)
#  - implement reset animation

## The node that will be used to implement the drag
## move and animations. If you don't set this, you will
## have to handle drag movements yourself
@export var controlled_node : Node2D

## Is this a draggable item?
@export var draggable := true
## Is this a clickable item?
@export var clickable := true

## Emitted when a full click has occured
signal click

## emitted at the start of a dragging operation
##
## The parameter offset is the offset of the click to the (0,0)
## position. This can be used to implement following the mouse
signal drag

# emitted when the item is dropped
signal drop

# The group we use to identify these nodes
# Things will break if someone else uses the same group name
const GROUP = "drag_drop_group"

## tracks whether the mouse button is pressed.
## you probably shouldn't look at this
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
	# Add ourselves to pur group
	add_to_group(GROUP, true)

	# TODO We probably should default to the parent?
	if not controlled_node:
		print_debug("No controlled node configured")


# Update position while dragging
func _process(_delta: float):
	if dragging and controlled_node:
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

# TODO Make on_top() more efficient by caching the result
# Cache should be invalidated when the tree changes (three signals in get_tree()
# or when something is added to the group or removed from it (which should never happen!)
# Howver, this does not eseem possible to be notified of.

# Of all the DragDropControllers under the mouse, am I the top one?
func on_top() -> bool:
	var dds: Array[Node] = get_tree().get_nodes_in_group(GROUP) \
			.filter( func(node): return node.hovering )
	dds.sort_custom(func(dd1, dd2): return dd1.is_greater_than(dd2) )
	if dds[0] == self:
		return true
	return false


func _detect_click():
	if clickable:
		click.emit()


func _drop():
	drop.emit()
	dragging = false


func _start_drag():
	if not draggable:
		return
	if controlled_node:
		offset = get_global_mouse_position() - controlled_node.global_position
		drag_position = controlled_node.global_position
	dragging = true
	drag.emit()


## Call this to cancel the drag (for example if the drop happens
## in a non-interesting area.
func cancel_drag():
	dragging = false
	mouse_down = false
	if controlled_node:
		controlled_node.global_position = drag_position

# Keep track of when the mouse is hovering over us
func _mouse_enter():
	#print("Enter ", controlled_node.name)
	hovering = true

func _mouse_exit():
	#print("Exit ", controlled_node.name)
	hovering = false
