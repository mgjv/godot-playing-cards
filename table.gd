extends Node2D

var deck: Deck

@onready var top = $DeckLocation/TopCard


# Called when the node enters the scene tree for the first time.
func _ready():
	deck = Deck.new()
	deck.shuffle()
	show_top_card()


func show_top_card():
	top.card = deck.top_card
	top.flip()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
