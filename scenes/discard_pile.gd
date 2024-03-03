extends Node2D

@onready var stack := $CardStackUI

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _can_receive_drop(node: Node2D):
	if not node is CardUI:
		print("NO nodes like that")
		return false
	print("I will accept '%s'" % node.card)
	return true
