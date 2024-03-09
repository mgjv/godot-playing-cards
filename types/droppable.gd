@tool
@icon("res://icons/droppable.svg")
class_name Droppable
extends Area2D

## A node that will handle droppability of any [Draggable]
##
## Make one of these a child of one of your nodes, and
## configure that node to [member Droppable.control_node]
##
## If you want to be able to control which nodes can de dropped, define a method 
## with signature 
##
## [code]_can_receive_drop(node: Node2D) -> bool[/code].
##
## The [param node] parameter will be the [member Draggable.control_node]
## member you defined on that side. Return true if you're willing and able to accept
## a drop of the given item.
## 
## To process the actual drop, connect to the [signal Droppable.received_drop].
##
## Also see [Draggable] for the other half of the story.

## The node that will be used to implement the drag
## move and animations. If you don't set this, you will
## have to handle drag movements yourself
@export var control_node : Node2D:
	set(n):
		control_node = n
		update_configuration_warnings()

## Are we actively listening for drops
@export var active := true


## Whether to automatically align the dropped item with [member control_node]
##
## If true, this will change the global_position of the dropped item
## to that of the [member control_node], possibly with an animation. 
## If you want to handle moving the item yourself, set this to false.
##
## This provides symmetry for the case where a Draggable is dropped
## outside of a suitable target (which wil autmatically move it back
## to where it was picked up).
##
## Note that this [i]does not[/i] change the p[osition in the scene tree.
## You have to do that yourself.
@export var align_dropped_item := false

## Whether to automatically add a DroppableUI node
##
## This will add DroppableUI animations to the droppable
## with the default settings.
@export var add_ui := true

## Emitted when something is dropped
##
## The payload is the conrolled node of the drag controller
signal received_drop(node: Node2D)

## Emitted when this node is selected as a drop target
signal targeted
## Emitted when this node is no longer selected as a drop target
signal untargeted

# The group we use to identify these nodes
# Things will break if someone else uses the same group name
const GROUP = "droppable_group"


func _ready():
	if Engine.is_editor_hint():
		return
	
	# Add ourselves to pur group and the global; list of droppables
	add_to_group(GROUP, true)

	# Connect to the detection signals
	#area_entered.connect(_on_area_entered)
	#area_exited.connect(_on_area_exited)
	monitoring = false
	monitorable = true
	
	# Add a DraggableUI node if requested, and if we don't already have one
	if add_ui and not get_children().filter(func(n): return n is DroppableUI):
		var droppable_ui = DroppableUI.new()
		add_child(droppable_ui)

# Allow can_receive to be overriddedn from outside of the 
# control_node as well
var _override_can_receive: Callable

## Determine whether this DragDropController can receive
## the given item from a drop. This uses the configuration
## of this DragDropController, and the logic possibly implemented 
## in the can_drop() method of the controlled node
##
## The order in which decisions are made is
## - [member _override_can_receive]()
## - [member _control_node][code]._can_receive()[/code]
## - [member active]
func can_receive(draggable: Draggable) -> bool:
	#print("%s reporting to %s" % [self, draggable])
	if not active:
		return false
	
	# We don't want to drop something on ourselves
	if control_node == draggable.control_node:
		return false

	# If an overriden can_receive method is implemented, use it
	if _override_can_receive:
		return _override_can_receive.call(draggable.control_node)
		
	# If there is no controlled node, assume all draggables are valid
	if not control_node.has_method("_can_receive_drop"):
		return active # which is always true here
	
	return control_node._can_receive_drop(draggable.control_node)


# Called when a drop is received 
func receive_drop(draggable: Draggable):
	if not active:
		# TODO This should of course never happen
		push_error("Item dropped on inactive %s" % self)
		return
	if align_dropped_item:
		draggable.move_to(control_node.global_position)
	received_drop.emit(draggable.control_node)
	#print("%s is receiving drop from %s" % [self, draggable])


## Called by [Draggable] when we're the drop target
func target(_draggable: Draggable):
	#print("%s is being targeted by %s" % [self, _draggable])
	targeted.emit()


## Called by [Draggable] when we're no longer the drop target
func untarget(_draggable: Draggable):
	#print("%s is no longer targeted by %s" % [self, _draggable])
	untargeted.emit()


# ----- Some basics ----------


func _to_string() -> String:
	if control_node and get_path():
		# Node.name is type StringName not String
		var cname: String = control_node.to_string() if control_node.has_method("_to_string") else str(control_node.get_path())
		return "Droppable{%s}" % [cname]
	else:
		# If we're not yet in a tree
		return super.to_string()


func _get_configuration_warnings():
	var warnings = []
	if !control_node:
		warnings.append("You must configure a controlled node.\nMost likely you want to select the parent node.")
	return warnings
