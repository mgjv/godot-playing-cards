@tool
class_name DragDropController
extends Area2D

## Handle input events related to mouse movement
##
## Specifically control clicking, dragging and dropping
## abstractions
##
## Add this as a child for a node you want to be draggable
## and/or a drop target. Configure the DragDropController
## with this node, and some other options. 
##
## To interat with the dropping of other DragDropController 
## items on yours, you need to implement some of these methods
##
## For any node this is configured to be a drop target
## 
## can_drop(other_node: Node2D) -> bool
##
##    this method should return true if your node is happy to 
##    receive a drop of the other_node
##

## The node that will be used to implement the drag
## move and animations. If you don't set this, you will
## have to handle drag movements yourself
@export var controlled_node : Node2D:
	set(n):
		controlled_node = n
		update_configuration_warnings()

## Is this a drop target?
@export var is_drop_target := false
## Is this a draggable item?
@export var draggable := true
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

# emitted when the item is dropped
signal drop

# The group we use to identify these nodes
# Things will break if someone else uses the same group name
const GROUP = "drag_drop_group"

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

# All current possible drop targets
var drop_targets : Array[DragDropController] = []
# And the currently selected drop target, which is reall
var drop_target : DragDropController:
	get:
		return drop_targets[0] if drop_targets else null


func _ready():
	if Engine.is_editor_hint():
		return

	# Add ourselves to pur group
	add_to_group(GROUP, true)
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


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


# Sort function for DragDropControllers. Sorts the top 
# ddc at the start
func cmp_ddc(a: DragDropController, b: DragDropController):
	if a.controlled_node.z_index > b.controlled_node.z_index:
		return true
	return a.is_greater_than(b)


# TODO Make on_top() more efficient by caching the result
# Cache should be invalidated when the tree changes (three signals in get_tree()
# or when something is added to the group or removed from it (which should never happen!)
# Howver, this does not eseem possible to be notified of.

# TODO See shape_clicker for a possible different approach

# Of all the DragDropControllers under the mouse, am I the top one?
func on_top() -> bool:
	var dds: Array[Node] = get_tree().get_nodes_in_group(GROUP) \
			.filter( func(node): return node.hovering )
	dds.sort_custom(cmp_ddc)
	if dds[0] == self:
		print("It's me", self)
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
		

## Determine whether this DragDropController can receive
## the given item from a drop. This uses the configuration
## of this DragDropController, and the logic possibly implemented 
## in the can_drop() method of the controlled node
func can_receive(other_ddc: DragDropController) -> bool:
	if not is_drop_target:
		return false
	# If there is no controlled node, just use 
	if not controlled_node.has_method("can_drop"):
		return is_drop_target
		
	return controlled_node.can_drop(other_ddc.controlled_node)



func _enter_drop_zone(ddc: DragDropController):
	# Only process this in the node that is being dragged
	if not dragging:
		return
	# If the other node cannot reeive this drop, return
	if not ddc.can_receive(self):
		return
	# Add the other node to the list of possible targets
	# Make sure the drop targets are in sorted order
	if not ddc in drop_targets:
		drop_targets.append(ddc)
		drop_targets.sort_custom(cmp_ddc)
		#print("%s set drop target to %s" % [self, drop_target])


func _exit_drop_zone(ddc: DragDropController):
	# Only process this in the node that is being dragged
	if not dragging:
		return
	drop_targets.erase(ddc)
	#print("%s set drop target to %s" % [self, drop_target])


# These two just exist to map the generic signals from Area2D
# to typed calls for DragDropController
func _on_area_entered(area: Area2D):
	if area is DragDropController:
		_enter_drop_zone(area as DragDropController)

func _on_area_exited(area: Area2D):
	if area is DragDropController:
		_exit_drop_zone(area as DragDropController)


# Keep track of when the mouse is hovering over us
func _mouse_enter():
	if draggable:
		print("Enter %s" % controlled_node)
	hovering = true

func _mouse_exit():
	if draggable:
		print("Exit %s" % controlled_node)
	hovering = false


func _to_string() -> String:
	# Node.name is type StringName not String
	var cname: String = controlled_node.name if controlled_node else &"<null>"
	return "DragDropController{%s}" % cname


func _get_configuration_warnings():
	var warnings = []
	if !controlled_node:
		warnings.append("A controlled node needs to be set.\nMost likely you want to select the parent node.")
	return warnings
	
