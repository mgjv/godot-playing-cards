@tool
#class_name BuildPileCardDroppable
extends Droppable

# The CardDroppable starts out, and firmly belongs to
# the BuildPile. However, during operation, it will be 
# attached to (made a child of) whatever the top open card 
# on the pile is, so that we can properly process the drops 
# on the stack, which will only happen on the root, or on the top
# card.

# TODO: Should we simply always have a droppable attached to
# a card, and interact with it instead? Means we'd have to 
# activate and deactivate it, and connect signals correctly all the time
# Not sure whether that is more or less work


## Where do we start life, so that we can return there when 
## we need to
var home_node: Node2D
var current_card: CardUI


func _ready():
	super._ready()
	
	if Engine.is_editor_hint():
		return
	
	# Save the originally configured control_node
	home_node = control_node
	active = false
	_override_can_receive = _can_receive_drop


## Go back to the home node and go to sleep
func detach_from_current_card():
	if not current_card:
		return
	#print("%s/CardDroppable detached from %s" % [home_node.name, current_card])
	# Move back home, adopting the home position
	reparent(home_node, false)
	# Disconnect the signals
	current_card.draggable.start_drag.disconnect(_on_start_drag)
	current_card.draggable.stop_drag.disconnect(_on_stop_drag)
	current_card.draggable.dropped.disconnect(_on_card_dropped)
	current_card = null
	# Deativate the droppable
	control_node = home_node
	active = false


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
	control_node = card
	active = true
	#print("%s/CardDroppable attached to %s" % [home_node.name, current_card])


func _on_start_drag():
	active = false

func _on_stop_drag():
	active = true

func _on_card_dropped(node: Node2D):
	if node == self:
		push_error("Cannot drop onto myself! This should not have happened")
	# Only detach if we're not dropped on nothing
	if node:
		detach_from_current_card()


# TODO: Now that we inherit direct\ly from Droppable
# We should be able to simply override Droppable.can_receive
# instead of using this mechanism
#
## This gets called to work out whether we can receive a drop
## 
## This can only happen when we're currently attached to a 
## CardUI instance as a parent.
func _can_receive_drop(node: Node2D) -> bool:
	#print("_can_receive_drop(%s)" % node)
	if not active:
		return false
	
	if not node is CardUI:
		return false
	
	# If we're still moving somewhere, don't do anything
	# TODO should this rather be done with signals and ative?
	if (control_node as CardUI).moving:
		return false
		
	# This is probably not needed, but maybe a bit more efficient
	if not (node as CardUI).draggable.dragging:
		return false
	
	var drag_card := (node as CardUI).card
	var drop_card := (get_parent() as CardUI).card
	#print("Comparing %s and %s" % [drag_card, drop_card])
	if drag_card.is_previous_rb(drop_card):
		return true

	return false
