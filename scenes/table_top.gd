@tool
extends Node2D

@export var color := Color.WEB_GREEN:
	set(c):
		color = c
		queue_redraw()

func _draw():
	var rect := get_viewport_rect()
	draw_rect(rect, color, true)
