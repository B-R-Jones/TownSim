extends Control

@onready var destination_label = $MovementStatus/DestinationLabel
@onready var at_destination_label = $MovementStatus/AtDestinationLabel
@onready var is_stuck_label = $MovementStatus/IsStuckLabel
@onready var is_moving_label = $MovementStatus/IsMovingLabel
@onready var tile_beneath_label = $DetectionStatus/TileBeneathLabel
@onready var tile_collision_label = $DetectionStatus/TileCollisionLabel
@onready var list_needs_ui = $NeedUI

var thought_node = null

func update_thought_form(thought_node):
	# Update movement status
	var movement_status = thought_node.movement_status
	destination_label.text = "Destination: (%d, %d)" % [movement_status.get("destination_coord", Vector2.ZERO).x, movement_status.get("destination_coord", Vector2.ZERO).y]
	at_destination_label.text = "At Destination: %s" % ("Yes" if movement_status.get("at_destination", false) else "No")
	is_stuck_label.text = "Is Stuck: %s" % ("Yes" if movement_status.get("is_stuck", false) else "No")
	is_moving_label.text = "Is Moving: %s" % ("Yes" if movement_status.get("is_moving", false) else "No")

	# Update detection status
	var detection_status = thought_node.detection_status
	tile_beneath_label.text = "Tile Beneath: %s" % detection_status.get("tile_beneath", "Unknown Tile")
	tile_collision_label.text = "Tile Collision: %s" % detection_status.get("tile_collision", "")
	
	# Update needs list
	var needs_list = thought_node.status_dict
	if needs_list != null: list_needs_ui.update_need_level(needs_list)
	
	# Update water need status
	# var water_status = thought_node.water_status
	# water_need_ui.update_water_level(water_status.get("water_level", 0.0))
	# water_need_ui.update_water_level(water_status)

func set_thought_node(node):
	thought_node = node

func clear_thought_form():
	thought_node = null
	# Clear labels or set to defaults
	destination_label.text = "Destination: "
	at_destination_label.text = "At Destination: "
	is_stuck_label.text = "Is Stuck: "
	is_moving_label.text = "Is Moving: "
	tile_beneath_label.text = "Tile Beneath: "
	tile_collision_label.text = "Tile Collision: "

func _process(delta):
	if thought_node:
		update_thought_form(thought_node)
