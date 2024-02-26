extends AnimatedSprite2D

# Map the card types to an index in the animations
var value_map := {
	Card.VALUES.ace: 0,
	Card.VALUES.two: 1,
	Card.VALUES.three: 2,
	Card.VALUES.four: 3,
	Card.VALUES.five: 4,
	Card.VALUES.six: 5,
	Card.VALUES.seven: 6,	
	Card.VALUES.eight: 7,
	Card.VALUES.nine: 8,
	Card.VALUES.ten: 9,
	Card.VALUES.jack: 10,
	Card.VALUES.queen: 11,
	Card.VALUES.king: 12,
}

var suit_map := {
	Card.SUITS.hearts: "hearts",
	Card.SUITS.clubs: "clubs",
	Card.SUITS.spades: "spades",
	Card.SUITS.diamonds: "diamonds",
}

func set_card(card: Card):
	set_animation(suit_map[card.suit])
	set_frame(value_map[card.value])
