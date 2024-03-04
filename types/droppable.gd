@tool
class_name Droppable
extends Area2D

## A node that will handle droppability of any [Draggable]
##
## Make one of these a child of one of your nodes, and
## configure that node to [member Droppable.controlled_node]
##
## If you want to be able to control which nodes can de dropped, define a method 
## with signature [code]_can_receive_drop(node: Node2D) -> bool[/code]. 
## The [param node] patameter will be the [member Draggable.controlled_node]
## member you defined on that side. Return true if you're willing and able to accept
## a drop of the given item.
## 
## To process the actual drop, connect to the [signal Droppable.received_drop].
##
## Note that the assumption is that if [code]can_receive()[/code] returned true
## that you will handle any further movement of the dropped item.
##
## Also see [Draggable] for the other half of the story.

## The node that will be used to implement the drag
## move and animations. If you don't set this, you will
## have to handle drag movements yourself
@export var controlled_node : Node2D:
	set(n):
		controlled_node = n
		update_configuration_warnings()

## Are we actively listening for drops
@export var active := true

## Whether to align the dropped item with this drop target 
## when dropped. 
##
## Set this to false if you want to handle the 
## alignment animation yourself.
##
## This provides symmetry for the case where a Draggable is dropped
## outside of a suitable target (which wil autmatically move it back
## to where it was picked up).
##
## Note that the dropped item remains in the same place in the scene tree.
## You need to handle that stuff yourself by implementing a handler
## for [signal Droppable.received_drop]
@export var align_dropped_item := true

## Emitted when something is dropped
##
## The payload is the conrolled node of the drag controller
signal received_drop(node: Node2D)

# The group we use to identify these nodes
# Things will break if someone else uses the same group name
const GROUP = "droppable_group"


func _ready():
	if Engine.is_editor_hint():
		return
	
	# Add ourselves to pur group and the global; list of droppables
	add_to_group(GROUP, true)
	_all_droppables.append(self)

	# Connect to the detection signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


# TODO We need drop animation/indication
# Update position while dragging
func _process(_delta: float):
	if Engine.is_editor_hint():
		return


## Determine whether this DragDropController can receive
## the given item from a drop. This uses the configuration
## of this DragDropController, and the logic possibly implemented 
## in the can_drop() method of the controlled node
func can_receive(draggable: Draggable) -> bool:
	#print("%s reporting to %s" % [self, draggable])
	if not active:
		return false

	# If there is no controlled node, assume all draggables are valid
	if not controlled_node.has_method("_can_receive_drop"):
		return true
		
	return controlled_node._can_receive_drop(draggable.controlled_node)


# All currently active droppables
static var _all_droppables: Array[Droppable]
# The draggables that are currently on this droppable
var _draggables: Array[Draggable]


static func _set_drop_target(draggable: Draggable):
	var droppables := _all_droppables.filter(
			func(d: Droppable): return d.active and draggable in d._draggables
		)
	droppables.sort_custom(Util.cmp_render_order)
	draggable.drop_target = droppables[0] if droppables else null
	#print("Drop target set to %s (out of %d)" % [draggable.drop_target, droppables.size()])


# Called when a drop is received 
func receive_drop(draggable: Draggable):
	if not active:
		# TODO This should of course never happen
		push_error("Item dropped on inactive %s" % self)
		return
	if align_dropped_item:
		draggable.move_to(controlled_node.global_position)
	received_drop.emit(draggable.controlled_node)
	#print("%s is receiving drop from %s" % [self, draggable])


## Called when a [Draggable] enters this [Droppable]
func _enter_drop_zone(draggable: Draggable):
	if not active:
		return
	# If we cannot reeive this drop, return
	if not can_receive(draggable):
		return
	_draggables.append(draggable)
	Droppable._set_drop_target(draggable)

## Called when a [Draggable] leaves this [Droppable]
func _exit_drop_zone(draggable: Draggable):
	if not active:
		return
	_draggables.erase(draggable)
	Droppable._set_drop_target(draggable)


# These two just exist to map the generic signals from Area2D
# to typed calls for DragDropController
func _on_area_entered(area: Area2D):
	if area is Draggable:
		_enter_drop_zone(area as Draggable)

func _on_area_exited(area: Area2D):
	if area is Draggable:
		_exit_drop_zone(area as Draggable)


func _to_string() -> String:
	# Node.name is type StringName not String
	var cname: String = controlled_node.name if controlled_node else &"<null>"
	return "Droppable{%s}" % cname


	
