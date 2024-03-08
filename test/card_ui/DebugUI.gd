extends CanvasLayer

@onready var deck := %DeckPile/CardStackUI

func _ready():
	add_to_group(UIConfig.DEBUG_GROUP)

func _on_new_deck_button_pressed():
	print("Asked for a new deck")
	for stack: CardStackUI in get_tree().get_nodes_in_group(CardStackUI.GROUP):
		stack._DEBUG_KILL()
	deck.add_full_deck()
	for build_pile: BuildPile in get_tree().get_nodes_in_group(BuildPile.GROUP):
		build_pile._take_initial_cards()
