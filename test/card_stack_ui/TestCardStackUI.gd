extends Node2D

@onready var source: CardStackUI = $Dealer/DeckPile/FullCardStackUI


func _ready():
	print("_ready for %s" % name)
	setup()
	
	
# Separate function so I can call it from the DebugUI
func setup():
	# FIXME There is a weird race condition somewhere that 
	# means adding _multiple_ cards to a hierarchical stack from here
	# means they end up in the wrong position. 
	# Either a very slow or very fast move animation speed
	# fixes it.
	# Well, at least if we pick a short duration in the UI
	# So, we temporarily set that to (close to) 0
	var old_move_animation_duration = UIConfig.move_animation_duration
	UIConfig.move_animation_duration = 1.0
	#setup_scenario_swap_red_four()
	UIConfig.move_animation_duration = old_move_animation_duration


# Reported:
# - Dropped a red four from a black five from the build pile onto the ace pile
#   and ended up not being able to drop the opther red four onto the
#   now exposed five.
# - Fixed
func setup_scenario_swap_red_four():
	var card: Card
	
	# Set up an acepile with the first three hearts
	for val in [Card.VALUES.ace, Card.VALUES.two, Card.VALUES.three]:
		card = Card.new(Card.SUITS.hearts, val)
		deal_card_to(card, $AcePile1/CardStackUI)
	
	# Set up a build pile with a 4 we can drop
	card = Card.new(Card.SUITS.spades, Card.VALUES.five)
	deal_card_to(card, $BuildPile1/OpenCards)
	card = Card.new(Card.SUITS.hearts, Card.VALUES.four)
	deal_card_to(card, $BuildPile1/OpenCards)
	card = Card.new(Card.SUITS.spades, Card.VALUES.three)
	deal_card_to(card, $BuildPile1/OpenCards)
	
	card = Card.new(Card.SUITS.clubs, Card.VALUES.five)
	deal_card_to(card, $BuildPile2/OpenCards)
	
	# Make sure we have the other red four available
	card = Card.new(Card.SUITS.diamonds, Card.VALUES.four)
	deal_card_to(card, $SinkPile/CardStackUI)


# This is a naughty test function that fiddles with the internals
# of the stacks to move cards around. 
func deal_card_to(card: Card, to_stack: CardStackUI, draggable := true):
	var c := find_card(card)
	if not c:
		print("Cannot find %s in source Deck" % card)
		return
	c.draggable.active = draggable
	to_stack.add_card(c)


# Takes a card from the source deck
#
# NOTE: This depends on implementation, and is fragile
func find_card(card: Card) -> CardUI:
	for c in source.cards():
		if c.card.is_same_as(card):
			return c
	return null
	
