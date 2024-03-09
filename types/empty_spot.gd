@tool
class_name EmptySpot
extends Node2D

enum TYPE {
	none,
	circle,
	cross,
	minus,
	plus,
	square,
	v_up,
	v_down,
}

# TODO One we figure out how to do the UIConfig default
# Stuff (Also see draggable_ui and droppable_ui, we should 
# also do that here.
@export var type: TYPE = TYPE.none:
	set(v):
		type = v
		queue_redraw()
@export_range(0, 80, 1) var size := 50.0:
	set(v):
		size = v
		queue_redraw()
@export_range(0, 20, 1) var line_width := 10.0:
	set(v):
		line_width = v
		queue_redraw()
@export_range(0, 5, 1) var outline_width := 1.0:
	set(v):
		outline_width = v
		queue_redraw()
@export var color = Color.DARK_BLUE:
	set(v):
		color = v
		queue_redraw()

var centre := Vector2.ZERO
var overall_size := UIConfig.CARD_SIZE
var top_left := centre - overall_size/2
var outline := Rect2(top_left, overall_size)

func _draw():
	#print("Drawing")
	draw_rect(outline, color, false, outline_width)
	match type:
		TYPE.circle:
			draw_arc(centre, size/2, 0, 360, 36, color, line_width)
		TYPE.cross:
			var offset := Vector2.ONE * size/2
			draw_line(centre - offset, centre + offset, color, line_width)
			offset.x *= -1
			draw_line(centre - offset, centre + offset, color, line_width)
		TYPE.minus:
			var offset := Vector2.RIGHT * size/2
			draw_line(centre - offset, centre + offset, color, line_width)			
		TYPE.plus:
			var offset := Vector2.RIGHT * size/2
			draw_line(centre - offset, centre + offset, color, line_width)			
			offset = Vector2.UP * size/2
			draw_line(centre - offset, centre + offset, color, line_width)
		TYPE.square:
			var square_size := Vector2.ONE * size
			var square := Rect2(centre - square_size/2, square_size)
			draw_rect(square, color, false, line_width)
		TYPE.v_up:
			var tip := centre + Vector2.UP * size/2
			var tail := centre + Vector2(-1, 1) * size/2
			draw_line(tip, tail, color, line_width)
			tail = centre + Vector2(1, 1) * size/2
			draw_line(tip, tail, color, line_width)
		TYPE.v_down:
			var tip := centre - Vector2.UP * size/2
			var tail := centre - Vector2(-1, 1) * size/2
			draw_line(tip, tail, color, line_width)
			tail = centre - Vector2(1, 1) * size/2
			draw_line(tip, tail, color, line_width)


