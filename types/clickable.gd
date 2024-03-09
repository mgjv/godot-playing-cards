@icon("res://icons/clickable.svg")
class_name Clickable
extends Hoverable

## Handle mouse clicks
##
## Emits a signal when a full normal click has occured.
## In this case a click is a mouse down, followed by a m,ouse up, 
## without any mouse movement in between (because that would be a 
## drag)
##
## When multiple of these detectors are on top, only the top one
## will emit a signal, where the top is determined by the 
## Z position of the controlled node, and the 
##
## TODO: 
##   - double-clicking
##
## Also see [Draggable] and [Droppable]

@export var active := true

## Emitted when a full click has occured
signal click

# The group we use to identify these nodes
# Things will break if someone else uses the same group name
const GROUP = "clickable_group"

## tracks whether the mouse button is pressed.
## you probably don't need to look at this, ever.
var mouse_down := false


func _ready():
	if Engine.is_editor_hint():
		return

	# Add ourselves to pur group
	add_to_group(GROUP, true)


# Process mouse events we're interested in
func _input_event(_viewport, event, _shape_idx):
	# If the mouse button is down and we move, cancel the click
	if mouse_down and event is InputEventMouseMotion:
		mouse_down = false
		return	
		
	# For performanc reasons, skip any further mouse motion processing
	if event is InputEventMouseMotion:
		return
	
	# If we're not the top node in our group, we don't want to process 
	if not on_top(GROUP):
		return
		
	# Process mouse buttons
	if event is InputEventMouseButton:
		if event.pressed:
			mouse_down = true  
		else: 
			if mouse_down:
				_detect_click()
				mouse_down = false


func _detect_click():
	if active:
		# print("%s clicked" % self)
		click.emit()


func _to_string() -> String:
	# Node.name is type StringName not String
	var cname: String = get_parent().name
	return "Clickable{%s}" % cname
