extends Node2D

var is_deck := false

var size := Vector2i(100, 140)
var outline := Rect2i(Vector2i.ZERO, size)
var centre := size/2

var color = Color.RED - Color.TRANSPARENT/2
	
func _draw():
	draw_rect(outline, color, false, 2)
	if is_deck:
		draw_arc(centre, 30, 0, 360, 36, color, 15)
	else:
		var offset = Vector2i.ONE * 30
		draw_line(centre - offset, centre + offset, color, 15)
		offset.x *= -1
		draw_line(centre - offset, centre + offset, color, 15)

