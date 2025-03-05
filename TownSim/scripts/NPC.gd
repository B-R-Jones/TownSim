extends CharacterBody2D

signal npc_selected(npc)

# PRELOADS
const MovementNode = preload("res://scripts/MovementNode.gd")
const DetectionNode = preload("res://scripts/DetectionNode.gd")
const ThoughtNode = preload("res://scripts/ThoughtNode.gd")

@export var tilemap: TileMapLayer
@export var click_distance: float = 50.0

var detection_node: DetectionNode
var thought_node: ThoughtNode
var movement_node: MovementNode
var animation_node: AnimationPlayer

var is_drinking = false

func _ready():
	add_to_group("npcs")
	randomize()
	thought_node = ThoughtNode.new()
	add_child(thought_node)
	
	movement_node = MovementNode.new()
	add_child(movement_node)

	detection_node = DetectionNode.new()
	detection_node.set_tilemap(tilemap)
	add_child(detection_node)
	
	set_needs()

	thought_node.set_movement_node(movement_node)
	thought_node.set_detection_node(detection_node)
	
	animation_node = $AnimationPlayer
	thought_node.set_animation_node(animation_node)
	
	detection_node.detection_status_updated.connect(thought_node._on_detection_status_updated)
	movement_node.movement_status_updated.connect(thought_node._on_movement_status_updated)

	if not tilemap:
		print("TileMap not set for NPC")

func set_needs():
	var need_nodes_dir := "res://need_nodes"
	var dir := DirAccess.open(need_nodes_dir)
	if dir == null:
		push_error("Could not open: " + need_nodes_dir)
		return

	var err = dir.list_dir_begin()
	if err != OK:
		push_error("Directory listing failed. Error code: " + str(err))
		return

	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".gd"):
			var script_path = need_nodes_dir + "/" + file_name
			var script_res: Script = load(script_path)

			if script_res:
				var base_scene: PackedScene = load("res://addons/need_node_manager/scenes/NeedNode.tscn")
				if base_scene:
					var node = base_scene.instantiate()
					node.set_script(script_res)  # Attach the newly generated script

					add_child(node)

					# Directly read the property
					if node.has_method("set_thought_node"):
						node.set_thought_node(thought_node)

						thought_node.set_need_node(node, node.res_status)
						node.res_status_updated.connect(thought_node._on_res_status_updated)
						node.res_level_critical.connect(thought_node._on_res_level_critical)
						node.res_level_full.connect(thought_node._on_res_level_full)
						node.play_anim.connect(thought_node._on_set_current_anim)
		file_name = dir.get_next()

	dir.list_dir_end()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_global_mouse_position().distance_to(global_position) < click_distance:
			emit_signal("npc_selected", self)
