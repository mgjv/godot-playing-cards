extends Node2D

@onready var stack: CardStackUI = $CardStackUI
# TODO This is messy.
@onready var end_pile: CardStackUI = $"../EndPile/CardStackUI"

func _ready():
	var deck := Deck.new()
	for card in deck.cards:
		if card.suit == Card.SUITS.hearts:
			var new_card := CardUI.new_from_card(card)
			stack.add_card(new_card)

	print("Created deck with %d cards" % [stack.size()])
	print("Top card is %s and bottom %s" % [stack.top_card(), stack.bottom_card()])


func _on_clickable_click():
	if stack.size() > 0:
		var card := stack.top_card()
		card.open()
		end_pile.add_card(card)
	else:
		end_pile.move_cards_to(stack, true)

