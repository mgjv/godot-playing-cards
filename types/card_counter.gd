class_name CardCounter
extends Node2D

## Displays the card count of the configured node
##
## If this is not set, will use the first "sibling"
## CardStackUI.
@export var stack: CardStackUI

## By how far to move the label from its current position
@export var offset: Vector2 = Vector2.ZERO

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
	
	_add_label()
	
	#print("Counting children of %s" % node_to_count.get_path())
	stack.child_entered_tree.connect(_on_child_entered)
	stack.child_exiting_tree.connect(_on_child_exiting)


func _add_label():
	#A box large enough for any text we might have
	var label_bounds = Vector2(25.0, 25)
	label = Label.new()
	label.size = label_bounds
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_set_count(stack.size())
	add_child(label)
	
	# place the label at the top left corner, aligned for top right text
	label.position -= UIConfig.CARD_CENTRE
	label.position += offset
	label.position.x -= label_bounds.x + 2


func _set_count(count: int):
	label.text = "%d" % count


func _on_child_entered(_node: Node):
	# The child has already entered the tree
	_set_count(stack.size())


func _on_child_exiting(_node: Node):
	# The child is _about to_ leave the node
	_set_count(stack.size() - 1)
