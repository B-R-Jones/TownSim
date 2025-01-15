# world_spawner.gd
extends Node2D

@export var map_width := 100
@export var map_height := 60
@export var map_scene: PackedScene

func _ready():
	# 1) Instantiate the map scene
	var map_instance = map_scene.instantiate()

	# 2) If "MapScene" has exported variables for size, set them
	#    (assuming the root node of MapScene.gd has "map_width" and "map_height")
	map_instance.map_width = map_width
	map_instance.map_height = map_height
	
	# 3) Add it to the tree so it becomes visible/active
	add_child(map_instance)

	print("Spawned a new map of size ", map_width, " x ", map_height)
