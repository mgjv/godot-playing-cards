extends Node2D

func _ready():
	# Because we're loaded after UIConfig, we have to invoke its debug method
	UIConfig.setup_debug_nodes()
