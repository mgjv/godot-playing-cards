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
## member you defined on that side.
## 
## To process any drops, connect to the [signal Droppable.received_drop].
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

## emitted when something is dropped
##
## The payload is the conrolled node of the drag controller
signal received_drop(node: Node2D)

# The group we use to identify these nodes
# Things will break if someone else uses the same group name
const GROUP = "droppable_group"


# The assumption is that there is ever one active draggabl;e
# at any time.
# These three variables track which of the droppables are currently
# possible targets, 
static var drop_targets : Array[Droppable] = []
static var drop_target : Droppable:
	get:
		return drop_targets[0] if drop_targets else null

## Called by a draggable when it is dropped
static func process_drop(draggable: Draggable):
	if drop_targets:
		drop_target._receive_drop(draggable)
		

func _ready():
	if Engine.is_editor_hint():
		return

	# Add ourselves to pur group
	add_to_group(GROUP, true)
	
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


## Called when a drop is received 
func _receive_drop(draggable: Draggable):
	received_drop.emit(draggable.controlled_node)
	#print("%s is receiving drop from %s" % [self, draggable])


func _enter_drop_zone(draggable: Draggable):
	# Only process this in the node that is being dragged
	if not active:
		return
	# If the other node cannot reeive this drop, return
	if not can_receive(draggable):
		return
	# Add ourselves to the list of possible targets
	# Make sure the drop targets are in sorted order
	if not self in drop_targets:
		drop_targets.append(self)
		drop_targets.sort_custom(Util.cmp_nodes_by_overlap)
		#print("Drop target set to %s (out of %d)" % [drop_target, drop_targets.size()])


func _exit_drop_zone(_draggable: Draggable):
	# Only process this in the node that is being dragged
	if not active:
		return
	drop_targets.erase(self)
	#print("Drop target set to %s (out of %d)" % [drop_target, drop_targets.size()])


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

func _get_configuration_warnings():
	var warnings = []
	if !controlled_node:
		warnings.append("A controlled node needs to be set.\nMost likely you want to select the parent node.")
	return warnings
	
