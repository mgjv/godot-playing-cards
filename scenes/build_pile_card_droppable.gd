extends Node2D

# The CardDroppable container starts out, and firmly belongs to
# the BuildPile. However, during operation, it will be 
# attached to (made a child of) whatever the top open card 
# on the pile is, so that we can properly 

@onready var droppable: Droppable = $Droppable

## Where do we start life, so that we can return there when 
## we need to
var home_node: Node2D
var current_card: CardUI


func _ready():
	home_node = get_parent()
	droppable.active = false
	droppable._override_can_receive = _can_receive_drop


## Go back to the home node and go to sleep
func detach_from_current_card():
	if not current_card:
		return
	#print("Detaching %s from %s" % [get_path().get_name(3), current_card])
	# Move back home, adopting the home position
	reparent(home_node, false)
	# Disconnect the signals
	current_card.draggable.start_drag.disconnect(_on_start_drag)
	current_card.draggable.stop_drag.disconnect(_on_stop_drag)
	current_card.draggable.dropped.disconnect(_on_card_dropped)
	current_card = null
	# Deativate the droppable
	droppable.control_node = home_node
	droppable.active = false


## Attach to the given card and listen for drop events
##
## set global position to the card
func attach_to_card(card: CardUI):
	# First, remove any previous associations
	detach_from_current_card()
	# Move to the given card, adopting the new position
	reparent(card, false)
	# Connect the signals
	current_card = card
	current_card.draggable.start_drag.connect(_on_start_drag)
	current_card.draggable.stop_drag.connect(_on_stop_drag)
	current_card.draggable.dropped.connect(_on_card_dropped)
	# Activate the droppable
	droppable.control_node = card
	droppable.active = true
	#print("Attached %s to %s" % [get_path().get_name(3), current_card])


func _on_start_drag():
	droppable.active = false

func _on_stop_drag():
	droppable.active = true

func _on_card_dropped(node: Node2D):
	if node == self:
		push_error("Cannot drop onto myself! This should not have happened")
	# Only detach if we're not dropped on nothing
	if node:
		detach_from_current_card()


## This gets called to work out whether we can receive a drop
## 
## This can only happen when we're currently attached to a 
## CardUI instance as a parent.
func _can_receive_drop(node: Node2D) -> bool:
	if not droppable.active:
		return false
	
	# FIXME TODO FIXME
	# Because of animations, we could be active while we're still moving.
	# I _should_ fix that, and will, at some point in the future
	# by keeping move state.
	# For now, I am going to check whether I am "close to" the home node.
	if global_position.distance_squared_to(home_node.global_position) > 5 * 5:
		return false
	
	if not node is CardUI:
		return false
		
	# This is probably not needed, but maybe a bit more efficient
	if not (node as CardUI).draggable.dragging:
		return false
		
	var drag_card := (node as CardUI).card
	var drop_card := (get_parent() as CardUI).card
	if drag_card.is_previous_rb(drop_card):
		return true

	return false
