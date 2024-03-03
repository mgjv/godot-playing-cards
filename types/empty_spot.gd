@tool
class_name EmptySpot
extends Node2D

enum TYPE {
	none,
	circle,
	cross,
	plus,
	square,
}

@export var type: TYPE = TYPE.none:
	set(v):
		type = v
		queue_redraw()
@export_range(0, 80, 1) var size := 50:
	set(v):
		size = v
		queue_redraw()
@export_range(0, 20, 1) var line_width := 10:
	set(v):
		line_width = v
		queue_redraw()
@export_range(0, 5, 1) var outline_width := 1:
	set(v):
		outline_width = v
		queue_redraw()
@export var color = Color.DARK_BLUE:
	set(v):
		color = v
		queue_redraw()
 
var overall_size := Vector2i(100, 140)
var outline := Rect2i(Vector2i.ZERO, overall_size)
var centre := overall_size/2

func _draw():
	#print("Drawing")
	draw_rect(outline, color, false, outline_width)
	match type:
		TYPE.circle:
			draw_arc(centre, size/2.0, 0, 360, 36, color, line_width)
		TYPE.cross:
			var offset := Vector2i.ONE * size/2
			draw_line(centre - offset, centre + offset, color, line_width)
			offset.x *= -1
			draw_line(centre - offset, centre + offset, color, line_width)
		TYPE.plus:
			var offset := Vector2i.UP * size/2
			draw_line(centre - offset, centre + offset, color, line_width)
			offset = Vector2i.RIGHT * size/2
			draw_line(centre - offset, centre + offset, color, line_width)			
		TYPE.square:
			var square_size := Vector2i.ONE * size
			var square := Rect2i(centre - square_size/2, square_size)
			draw_rect(square, color, false, line_width)

# Uncomment this if you want to see the thing update in realtime
# in the editor
#func _process(_delta):
	#if Engine.is_editor_hint():
		#queue_redraw()
