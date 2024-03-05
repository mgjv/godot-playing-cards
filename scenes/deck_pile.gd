extends Node2D

@onready var stack: CardStackUI = $CardStackUI

func _ready():
	stack.add_full_deck()
	#print("Created deck with %d cards" % [stack.size()])
	#print("Top card is %s and bottom %s" % [stack.top_card(), stack.bottom_card()])
	

