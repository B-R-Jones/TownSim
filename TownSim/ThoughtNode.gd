extends Node2D

var movement_node: Node2D
var detection_node: Area2D

var status_dict = {}
var movement_status = {}
var detection_status = {}

var res_needs = {}
var seek_res_tiles = {}
var seek_res_tile = null

func _ready():
	# generate_random_coordinates()
	if detection_node:
		detection_node.connect("detection_status_updated", Callable(self, "_on_detection_status_updated"))

func set_movement_node(node: Node2D):
	movement_node = node

func set_detection_node(node: Area2D):
	detection_node = node

func set_need_node(node: Node, status):
	status_dict[node] = status

func generate_random_coordinates():
	detection_status = detection_node.ping()
	print(detection_status["map_size"])
	var nav_map_bounds = Rect2(Vector2.ZERO, Vector2(detection_status["map_size"]))
	var destination = Vector2(
		randf_range(nav_map_bounds.position.x, nav_map_bounds.end.x),
		randf_range(nav_map_bounds.position.y, nav_map_bounds.end.y)
	)
	if movement_node:
		movement_node.set_destination(destination)
	else:
		print("MovementNode not found")

func _on_detection_status_updated(detect_status):
	detection_status = detect_status
	# read resource_counts or do other logic
	var new_speed = detection_status.get("tile_speed", 100.0)

	# If movement_node exists, update speed
	if movement_node and movement_node.has_method("set_current_speed"):
		movement_node.set_current_speed(new_speed)

	# (existing resource logic, etc.)
	var resource_counts = detection_status.get("resource_counts", {})
	for resource in resource_counts:
		if resource in res_needs:
			print("Resource detected: ", resource)
			if move_to_resource(resource):
				break


func move_to_resource(res_type: String) -> bool:
	seek_res_tile = detection_node.find_nearest_res_tile(res_type)
	if seek_res_tile != null:
		print("Setting movement towards: ", res_type)
		var res_node_info = res_needs.get(res_type, null)
		if res_node_info and res_node_info.has("node"):
			seek_res_tiles[seek_res_tile] = res_node_info["node"]
			movement_node.set_destination(seek_res_tile)
			return true
	print("No valid tile found for " + String(res_type))
	return false

func _on_movement_status_updated(move_status):
	movement_status = move_status
	if move_status.get("is_stuck", false):
		generate_random_coordinates()
		return

	if move_status.get("at_destination", false) and seek_res_tile == null:
		generate_random_coordinates()

	if movement_status.get("at_destination", false):
		var current_node = seek_res_tiles.get(seek_res_tile)
		if current_node:
			print("At " + str(current_node) + " tile...")
			print("Consuming resource...")
			current_node.satisfy = true
			seek_res_tiles.erase(seek_res_tile)

func _on_res_status_updated(res_node: Node2D, res_status):
	status_dict[res_node] = res_status

func _on_res_level_critical(res_type, priority, res_node: Node2D):
	var res_node_dict = {}
	res_node_dict["node"] = res_node
	res_node_dict["priority"] = priority
	res_needs[res_type] = res_node_dict
	
	if !seek_res_tile:
		move_to_resource(res_type)

func _on_res_level_full(res_type):
	res_needs.erase(res_type)
	seek_res_tile = null
