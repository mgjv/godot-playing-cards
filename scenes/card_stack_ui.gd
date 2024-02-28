class_name CardStackUI
extends Node2D

var stack: CardStack = CardStack.new()

@export var is_deck := false

@onready var top := $TopCard
@onready var next := $NextCard
@onready var empty := $Empty

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_deck:
		stack = Deck.new()
		stack.shuffle()
	update_state()
	empty.is_deck = is_deck	

## Based on the contents of the stack, update the 
## child nodes
func update_state():
	if stack.size() > 0:
		top.card = stack.top_card
		top.open()
		top.visible = true 
	else:
		top.visible = false
		
	next.visible = true if stack.size() > 1 else false
