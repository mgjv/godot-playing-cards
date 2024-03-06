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

## Whether to automatically add a DraggableUI node
##
## This will add DraggableUI animations to the draggable
## with the default settings. If you want to control the settings
## yourself, explicitly create the node, and configure it.
@export var add_ui := true


## emitted at the start and end of a dragging operation
##
## The parameter offset is the offset of the click to the (0,0)
## position. This can be used to implement following the mouse
signal start_drag
# TODO FIXME This is also emitted on a drop, which is technically correct
# but probably not great to handle
signal stop_drag

# TODO This signal should include the item dropped and the draggable

# emitted when the item is dropped
signal dropped(droppable: Droppable)

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

## This is the current drop target (read only)
var drop_target : Droppable:
	get:
		return _get_current_drop_target()
	set(_v):
		pass

# ----- Evemnt handlr=ers and callbacks

func _ready():
	if Engine.is_editor_hint():
		return
	
	# Add ourselves to pur group
	add_to_group(GROUP, true)

	# Connect to the detection signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	# Add a DraggableUI node if requested, and if we don't already have one
	if add_ui and not get_children().filter(func(n): return n is DraggableUI):
		#print("Adding UI")
		var draggable_ui = DraggableUI.new()
		add_child(draggable_ui)


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

# ----- ACTUAL METHODS -----------------

# Yuck. This is a bit of a hack until I figure out a better way to do this
var _move_func: Callable
## Move the controlled node to the given position
func move_to(pos: Vector2):
	#print("Moving to %s" % pos)
	if _move_func:
		_move_func.call(pos)
	else:
		controlled_node.global_position = pos

# ----- HANDLE DRAGGING BEHAVIOURS ------------------

# Called when this Draggable is dropped
func _drop():
	if drop_target:
		drop_target.receive_drop(self)
		dropped.emit(drop_target)
	else:
		cancel_drag()
	_end_drag()


# Called when a drag ends. Responsible for all state handling
func _end_drag():
	if dragging:
		stop_drag.emit()
	if drop_target:
		drop_target.untarget(self)
	dragging = false
	mouse_down = false


# Called to start a drag. Responsible for all state handling
func _start_drag():
	if not active:
		return
	offset = get_global_mouse_position() - self.controlled_node.global_position
	drag_position = self.controlled_node.global_position
	dragging = true
	start_drag.emit()
	if drop_target:
		drop_target.target(self)


## Call this to cancel the drag (for example if the drop happens
## in a non-interesting area.
func cancel_drag():
	_end_drag()
	# Return the item to its start position
	move_to(drag_position)


# ------- INTERACT WITH DROPPABLES -----------

var _droppables : Array[Droppable] = []

# Getter for drop_target property
func _get_current_drop_target() -> Droppable:
	return _droppables[0] if _droppables and active else null


# Called to determine whether the targeting status needs to change
func _update_drop_target(old: Droppable, new: Droppable):
	if not dragging:
		return
	#print("Evaluating %s vs %s" % [old, new])
	# Inform droppables about whether they're targeted or not
	if old and old != new:
		old.untarget(self)
	if new and new != old:
		new.target(self)


# Called when we enter a [Droppable]
func _enter_drop_zone(droppable: Droppable):
	if OS.is_debug_build() and droppable in _droppables:
		print_debug("Droppable %s is already present in %s" % [droppable, self])

	# If the droppable doean't want us, return
	if not droppable.can_receive(self):
		return
	if not droppable in _droppables:
		#print("Adding %s" % droppable)
		var previous_drop_target = drop_target
		_droppables.append(droppable)
		_droppables.sort_custom(Util.cmp_render_order)
		_update_drop_target(previous_drop_target, drop_target)


# Called when we exit a [Droppable]
func _exit_drop_zone(droppable: Droppable):
	if droppable in _droppables:
		#print("Removing %s" % droppable)
		var previous_drop_target := drop_target
		_droppables.erase(droppable)
		_update_drop_target(previous_drop_target, drop_target)


# Generic untype signal handler
func _on_area_entered(area: Area2D):
	if area is Droppable:
		_enter_drop_zone(area as Droppable)


# Generic untype signal handler
func _on_area_exited(area: Area2D):
	if area is Droppable:
		_exit_drop_zone(area as Droppable)


#-------- SOME BASIC SRTUFF ---------------

func _to_string() -> String:
	# Node.name is type StringName not String
	var cname: String = self.controlled_node.name if self.controlled_node else &"<null>"
	return "Draggable{%s}" % cname


func _get_configuration_warnings():
	var warnings = []
	if !controlled_node:
		warnings.append("A controlled node needs to be set.\nMost likely you want to select the parent node.")
	return warnings
