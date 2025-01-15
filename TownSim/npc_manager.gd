extends Control

var npc_scene := preload("res://NPC.tscn")

@export var target_parent_path: NodePath
@export var thought_form_ui_path: NodePath

var target_parent: Node
var thought_form_ui: Node
var current_npc: Node

func _ready():
	target_parent = get_node(target_parent_path)
	thought_form_ui = get_node(thought_form_ui_path)

func spawn_npc():
	var npc = npc_scene.instantiate()
	var tilemap_node = target_parent.get_node("MapScene/MapContainer/MapLayers/TileMapLayer")
	npc.tilemap = tilemap_node
	npc.position = Vector2(100, 100)
	target_parent.add_child(npc)

	var button = Button.new()
	button.text = "NPC"

	var cb = Callable(self, "_on_npc_list_button_pressed").bind(npc)
	button.pressed.connect(cb)

	$NPCListUI.add_child(button)

func _on_npc_list_button_pressed(npc):
	_select_npc(npc)

func _select_npc(npc):
	print("Selected NPC:", npc)
	thought_form_ui.set_thought_node(npc.thought_node)

func _on_button_spawn_npc_pressed() -> void:
	spawn_npc()
