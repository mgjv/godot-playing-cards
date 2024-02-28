class_name DragDropController
extends Control

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
#  - implement drag cancellation
#  - implement mouse following? Requires different inheritance
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

func ready():
	if not controlled_node:
		print_debug("No controlled node configured")

## tracks whether the mouse button is pressed.
## you probably shouldn't look at this
var mouse_down := false

## Indicates whether the 
var dragging := false

## The offset of the initial click to the position
## of the Controlled Node
var offset := Vector2.ZERO

## This is the position the controlled node
## orignally was before dragging
var drag_position := Vector2.ZERO

# TODO
# Control nodes are not Node2D children. Need to 
# use a different inheritance, probably Area2D
func process(_delta: float):
	if dragging and controlled_node:
		#print("Drag ", get_local_mouse_position())
		controlled_node.global_position = get_global_mouse_position() - offset

func _on_gui_input(event: InputEvent):
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
	# If the mouse button is down and we move, start a drag
	if not dragging and mouse_down and event is InputEventMouseMotion:
		_start_drag()
	
	if event.is_action_pressed("ui_cancel"):
		print("Got cancellation")
		cancel_drag()
		

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

func cancel_drag():
	dragging = false
	if controlled_node:
		controlled_node.global_position = drag_position
