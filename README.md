Godot Playing Cards
===================

This is a [Godot](https://godotengine.org/download/preview/) project I started to implement some basic card-playing functionality,
including dragging and dropping, animations going with that, handling of decks and cards, 
comparing cards within different rules.

While doing that I needed to develop some "missing" functionality in Godot, like easily being
able to determine which is the top node in a given list of nodes. 

At the moment, this is tested with playing cards, but it should be possinle to replace the art
and adjust the Card class and the CardUI/Front classes to reflect other types of cards.

Feel free to use some of the code. However, don't take the artwork from here. I've used artwork
from a [playing cards category](https://commons.wikimedia.org/wiki/Category:SVG_complete_decks_of_playing_cards_laid_out) 
on [WikliMedia Commons](https://commons.wikimedia.org/wiki/Main_Page), so get your artwork there.
Another possible source is this [card customiser](https://www.me.uk/cards/), which produces really 
nice results.


## To Do

- Various TODO items all over the code
- Move control over whether card is open or closed to CardStackUI
  as stacks should either be fully open or fully closed
