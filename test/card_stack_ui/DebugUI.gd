extends CanvasLayer

# Debug UI for the TestCardUI test

@onready var deck := %DeckPile/FullCardStackUI


func _ready():
	# We're a debug node, so we don't need to exist elsewhere
	if not OS.is_debug_build():
		queue_free()
		return

	add_to_group(UIConfig.DEBUG_GROUP)
	visible = UIConfig.debug


func _on_new_deck_button_pressed():
	print("Asked for a new deck")
	for stack: CardStackUI in get_tree().get_nodes_in_group(CardStackUI.GROUP):
		stack._DEBUG_KILL()
	deck.add_full_deck()
	for build_pile: BuildPile in get_tree().get_nodes_in_group(BuildPile.GROUP):
		build_pile._take_initial_cards()
