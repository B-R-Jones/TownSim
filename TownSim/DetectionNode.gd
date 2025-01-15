extends Area2D

signal detection_status_updated(detect_status)

var tilemap: TileMapLayer
var detection_status = {
	"tile_beneath": "Unknown Tile",
	"tile_collision": "",
	"map_size": ""
}

func set_tilemap(new_tilemap: TileMapLayer):
	tilemap = new_tilemap
	var m_size
	m_size = Vector2i(tilemap.get_used_rect().size)
	detection_status["map_size"] = m_size * 64

func detect_tile():
	if tilemap == null:
		detection_status["tile_beneath"] = "No TileMapLayer set"
		# Speed defaults to 100 if tilemap is null, or some fallback
		detection_status["tile_speed"] = 100.0  
		emit_signal("detection_status_updated", detection_status)
		return

	var npc_position = get_parent().global_position
	var tile_coords = tilemap.local_to_map(tilemap.to_local(npc_position))
	var tile_data = tilemap.get_cell_tile_data(tile_coords)

	if tile_data:
		var type_val = tile_data.get_custom_data("Type")
		var speed_val = tile_data.get_custom_data("Speed")  # <--- NEW
		if type_val != null:
			detection_status["tile_beneath"] = type_val
		else:
			detection_status["tile_beneath"] = "Unknown Tile"

		# If Speed is not defined, default to 100.0 or any fallback you prefer
		if speed_val == null:
			speed_val = 100.0
		detection_status["tile_speed"] = speed_val
	else:
		detection_status["tile_beneath"] = "Unknown Tile"
		detection_status["tile_speed"] = 100.0

	emit_signal("detection_status_updated", detection_status)

func ping():
	return detection_status

func _physics_process(delta):
	detect_tile()

	var collision = get_parent().get_last_slide_collision()
	if collision:
		var tilemap_layer = collision.get_collider() as TileMapLayer
		if tilemap_layer:
			var global_contact = collision.get_position()
			var local_contact = tilemap_layer.to_local(global_contact)
			var tile_coords = tilemap_layer.local_to_map(local_contact)
			var tile_data = tilemap_layer.get_cell_tile_data(tile_coords)

			if tile_data and tile_data.get_custom_data("Type"):
				var temp_data = tile_data.get_custom_data("Type")
				detection_status["tile_collision"] = tile_data.get_custom_data("Type")
			else:
				detection_status["tile_collision"] = "Unknown Tile"

			# Emit again so the ThoughtFormUI sees the new collision info
			emit_signal("detection_status_updated", detection_status)
		else:
			# If you hit something that isn't a TileMapLayer,
			# optionally set tile_collision to something else or do nothing.
			detection_status["tile_collision"] = "Non-tile collision"
			emit_signal("detection_status_updated", detection_status)
	else:
		# No collision. If you want to clear or preserve the old collision data, you can do so here:
		detection_status["tile_collision"] = ""
		emit_signal("detection_status_updated", detection_status)
		pass

func detect_tiles_around():
	if tilemap == null:
		emit_signal("detection_status_updated", {"error": "No TileMapLayer set"})
		return

	var npc_position = get_parent().global_position
	var detected_tiles = []

	var delta_coords = [-1, 0, 1]
	for dx in delta_coords:
		for dy in delta_coords:
			var sample_pos = npc_position + Vector2(dx, dy)
			var tile_coords = tilemap.local_to_map(tilemap.to_local(sample_pos))
			var tile_data = tilemap.get_cell_tile_data(tile_coords)

			var tile_info = {"type": "None", "resource": "None"}
			if tile_data:
				var type_val = tile_data.get_custom_data("Type")
				if type_val != null:
					tile_info["type"] = type_val
				var resource_val = tile_data.get_custom_data("Resource")
				if resource_val != null:
					tile_info["resource"] = resource_val

			detected_tiles.append(tile_info)

	emit_signal("detection_status_updated", summarize_detection(detected_tiles))

func summarize_detection(detected_tiles):
	var detection_summary = {
		"resource_presence": false,
		"richness_count": 0,
		"type_counts": {},
		"resource_counts": {}
	}

	for tile_info in detected_tiles:
		var tile_type = tile_info["type"]
		var resource_type = tile_info["resource"]

		detection_summary["type_counts"][tile_type] = detection_summary["type_counts"].get(tile_type, 0) + 1

		if resource_type != "None":
			detection_summary["resource_counts"][resource_type] = detection_summary["resource_counts"].get(resource_type, 0) + 1
			detection_summary["resource_presence"] = true
			detection_summary["richness_count"] += 1

	return detection_summary

func get_nearby_tiles(position, radius):
	if tilemap == null or tilemap.tile_set == null:
		return []

	var tile_size = tilemap.tile_set.tile_size
	var start_x = int(position.x - radius) / tile_size.x
	var start_y = int(position.y - radius) / tile_size.y
	var end_x = int(position.x + radius) / tile_size.x
	var end_y = int(position.y + radius) / tile_size.y

	var nearby_tiles = []
	for x in range(start_x, end_x + 1):
		for y in range(start_y, end_y + 1):
			nearby_tiles.append(Vector2i(x, y))

	return nearby_tiles

func find_nearest_res_tile(res_type):
	if tilemap == null or tilemap.tile_set == null:
		print("TileMapLayer or TileSet not found")
		return null

	var npc_position = get_parent().global_position
	var tile_size = tilemap.tile_set.tile_size
	var nearby_tiles = get_nearby_tiles(npc_position, 5 * tile_size.x)

	var nearest_res_tile = null
	var min_distance = INF

	for tile_pos in nearby_tiles:
		var tile_data = tilemap.get_cell_tile_data(tile_pos)
		if tile_data and tile_data.get_custom_data("Resource") == res_type:
			var tile_local_pos = tilemap.map_to_local(tile_pos)
			var tile_world_pos = tilemap.to_global(tile_local_pos)
			var distance = npc_position.distance_to(tile_world_pos)
			if distance < min_distance:
				min_distance = distance
				nearest_res_tile = tile_world_pos

	return nearest_res_tile
