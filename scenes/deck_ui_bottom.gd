extends Node2D

var size := Vector2i(100, 140)
var outline := Rect2i(Vector2i.ZERO, size)
var centre := size/2

var color = Color.RED - Color.TRANSPARENT/2

func _draw():
	draw_rect(outline, color, false, 2)
	draw_arc(centre, 30, 0, 360, 36, color, 15)
	
