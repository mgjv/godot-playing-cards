class_name CardCounter
extends Node2D

## Displays the card count of the configured node
##
## If this is not set, will use the first "sibling"
## CardStackUI.
@export var stack: CardStackUI

var label: Label

func _ready():
	# We're a debug node
	if not OS.is_debug_build():
		queue_redraw()
		return
	add_to_group(UIConfig.DEBUG_GROUP)
	
	if not stack:
		# Look for a CardStackUI sibling
		for node in get_parent().get_children():
			if node is CardStackUI:
				stack = node
				break
		
		# If we didn;'t find anything, we die
		if not stack:
			push_error("%s has nothing to count. Removing myself" % self.path)
			queue_free()
			return

	label = Label.new()
	_set_count(stack.size())
	add_child(label)
	# We have to do this after adding the label
	var label_height := label.get_rect().size.y
	label.position.x = - UIConfig.CARD_CENTRE.x
	label.position.y = - UIConfig.CARD_CENTRE.y - label_height
	
	#print("Counting children of %s" % node_to_count.get_path())
	stack.child_entered_tree.connect(_on_child_entered)
	stack.child_exiting_tree.connect(_on_child_exiting)


func _set_count(count: int):
	label.text = "%d" % count


func _on_child_entered(_node: Node):
	# The child has already entered the tree
	_set_count(stack.size())


func _on_child_exiting(_node: Node):
	# The child is _about to_ leave the node
	_set_count(stack.size() - 1)
