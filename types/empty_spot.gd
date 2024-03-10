@tool
@icon("res://icons/empty_spot.svg")
class_name EmptySpot
extends Node2D

## Draw an empty spot on the table
##
## This draws an empty spot on the table at the size of a card

## The possible types of empty spot
enum TYPE {
	none,
	circle,
	cross,
	minus,
	plus,
	square,
	v_up,
	v_down,
	v_left,
	v_right,
}

# TODO One we figure out how to do the UIConfig default
# Stuff (Also see draggable_ui and droppable_ui, we should 
# also do that here.

## The type of this empty spot
##
## Changing this will cause a different symbol to be drawn in the 
## centre of the empty spot
@export var type: TYPE = TYPE.none:
	set(v):
		type = v
		queue_redraw()

## The size of the symbol in the centre
@export_range(0, 80, 1) var size := 40.0:
	set(v):
		size = v
		queue_redraw()

## The line width of the symbol in the centre
@export_range(0, 20, 1) var line_width := 10.0:
	set(v):
		line_width = v
		queue_redraw()

## The line width of the outline of the empty spot
@export_range(0, 5, 1) var outline_width := 1.0:
	set(v):
		outline_width = v
		queue_redraw()

## The color of all the lines
@export var color = Color.DARK_BLUE:
	set(v):
		color = v
		queue_redraw()


# TODO: we don't really need centre here anymore, so could
#       clean up the code significantly by removing it
# NOTE: These are not for external use, so probably should have
# a leading underscore
const centre := Vector2.ZERO
const overall_size := UIConfig.CARD_SIZE
const top_left := centre - overall_size/2
const outline := Rect2(top_left, overall_size)


func _draw():
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
			var points : PackedVector2Array = [
				centre + Vector2(-1, 1) * size/2,
				centre + Vector2.UP * size/2,
				centre + Vector2(1, 1) * size/2,
			]
			draw_polyline(points, color, line_width)
		TYPE.v_down:
			var points : PackedVector2Array = [
				centre - Vector2(-1, 1) * size/2,
				centre - Vector2.UP * size/2,
				centre - Vector2(1, 1) * size/2,
			]
			draw_polyline(points, color, line_width)
		TYPE.v_left:
			var points : PackedVector2Array = [
				centre + Vector2(1, 1) * size/2,
				centre + Vector2.LEFT * size/2,
				centre + Vector2(1, -1) * size/2,
			]
			draw_polyline(points, color, line_width)
		TYPE.v_right:
			var points : PackedVector2Array = [
				centre - Vector2(1, 1) * size/2,
				centre - Vector2.LEFT * size/2,
				centre - Vector2(1, -1) * size/2,
			]
			draw_polyline(points, color, line_width)
