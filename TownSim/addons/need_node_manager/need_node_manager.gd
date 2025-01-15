@tool
extends EditorPlugin

#
# Configuration: Adjust as needed
#
var TEMPLATE_SCRIPT_PATH := "res://addons/need_node_manager/DefaultNeedNode.gd"
var OUTPUT_FOLDER_PATH   := "res://addons/need_node_manager/generated"

#
# Dock UI containers
#
var main_vbox: VBoxContainer
var class_name_edit: LineEdit
var res_type_edit: LineEdit
var res_status_edit: LineEdit
var res_max_edit: LineEdit
var res_min_edit: LineEdit
var loss_rate_edit: LineEdit
var gain_rate_edit: LineEdit
var res_signal_edit: LineEdit
var priority_edit: LineEdit

func _enter_tree():
	main_vbox = VBoxContainer.new()
	main_vbox.name = "Need Node Manager"

	# -- CLASS NAME --
	main_vbox.add_child(_create_label("New Class Name (e.g. WaterNeedNode)"))
	class_name_edit = _create_line_edit("WaterNeedNode")
	main_vbox.add_child(class_name_edit)

	# -- RES_TYPE --
	main_vbox.add_child(_create_label('res_type (e.g. "water")'))
	res_type_edit = _create_line_edit("water")
	main_vbox.add_child(res_type_edit)

	# -- RES_STATUS --
	main_vbox.add_child(_create_label("res_status (float, e.g. 0.0)"))
	res_status_edit = _create_line_edit("0.0")
	main_vbox.add_child(res_status_edit)

	# -- RES_MAX --
	main_vbox.add_child(_create_label("res_max (float, e.g. 1.0)"))
	res_max_edit = _create_line_edit("1.0")
	main_vbox.add_child(res_max_edit)

	# -- RES_MIN --
	main_vbox.add_child(_create_label("res_min (float, e.g. 0.0)"))
	res_min_edit = _create_line_edit("0.0")
	main_vbox.add_child(res_min_edit)

	# -- LOSS_RATE --
	main_vbox.add_child(_create_label("res_loss_rate (float, e.g. 0.0125)"))
	loss_rate_edit = _create_line_edit("0.0125")
	main_vbox.add_child(loss_rate_edit)

	# -- GAIN_RATE --
	main_vbox.add_child(_create_label("res_gain_rate (float, e.g. 0.025)"))
	gain_rate_edit = _create_line_edit("0.025")
	main_vbox.add_child(gain_rate_edit)

	# -- RES_SIGNAL --
	main_vbox.add_child(_create_label("res_signal (float, e.g. 0.25)"))
	res_signal_edit = _create_line_edit("0.25")
	main_vbox.add_child(res_signal_edit)

	# -- PRIORITY --
	main_vbox.add_child(_create_label("priority (int, e.g. 1)"))
	priority_edit = _create_line_edit("1")
	main_vbox.add_child(priority_edit)

	# -- BUTTON --
	var create_button = Button.new()
	create_button.text = "Create New Need Node Script"
	create_button.pressed.connect(_on_create_button_pressed)
	main_vbox.add_child(create_button)

	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, main_vbox)

	# Ensure output folder exists, or create it
	create_output_folder_if_missing()


func _exit_tree():
	remove_control_from_docks(main_vbox)


func _on_create_button_pressed():
	var new_class_name = class_name_edit.text.strip_edges()
	if new_class_name == "":
		push_error("Please enter a valid class name.")
		return

	# DefaultNeedNode.gd might have lines like:
	# class_name DefaultNeedNode
	# @onready var res_type = "need"
	# @onready var res_status = 0.0
	# @onready var res_max = 1.0
	# @onready var res_min = 0.0
	# @onready var res_loss_rate = 0.0125
	# @onready var res_gain_rate = 0.025
	# @onready var res_signal = 0.25
	# @onready var priority = 1

	var template_file = FileAccess.open(TEMPLATE_SCRIPT_PATH, FileAccess.READ)
	if not template_file:
		push_error("Could not open template script: " + TEMPLATE_SCRIPT_PATH)
		return

	var script_text = template_file.get_as_text()
	template_file.close()

	# Perform replacements
	script_text = script_text.replace(
		"class_name DefaultNeedNode", 
		"class_name " + new_class_name
	)

	script_text = script_text.replace(
		'@onready var res_type = "need"',
		'@onready var res_type = "' + res_type_edit.text.strip_edges() + '"'
	)

	script_text = script_text.replace(
		"@onready var res_status = 0.0",
		"@onready var res_status = " + res_status_edit.text.strip_edges()
	)

	script_text = script_text.replace(
		"@onready var res_max = 1.0",
		"@onready var res_max = " + res_max_edit.text.strip_edges()
	)

	script_text = script_text.replace(
		"@onready var res_min = 0.0",
		"@onready var res_min = " + res_min_edit.text.strip_edges()
	)

	script_text = script_text.replace(
		"@onready var res_loss_rate = 0.0125",
		"@onready var res_loss_rate = " + loss_rate_edit.text.strip_edges()
	)

	script_text = script_text.replace(
		"@onready var res_gain_rate = 0.025",
		"@onready var res_gain_rate = " + gain_rate_edit.text.strip_edges()
	)

	script_text = script_text.replace(
		"@onready var res_signal = 0.25",
		"@onready var res_signal = " + res_signal_edit.text.strip_edges()
	)

	script_text = script_text.replace(
		"@onready var priority = 1",
		"@onready var priority = " + priority_edit.text.strip_edges()
	)

	# Write the modified script text to a new file
	var out_path = OUTPUT_FOLDER_PATH + "/" + new_class_name + ".gd"
	var out_file = FileAccess.open(out_path, FileAccess.WRITE)
	if not out_file:
		push_error("Unable to open file for writing: " + out_path)
		return
	out_file.store_string(script_text)
	out_file.close()

	# Force the editor to refresh the filesystem so the new file appears
	get_editor_interface().get_resource_filesystem().scan()

	print("Created new script:", out_path)


#
# Utility: Create the output folder if missing
#
func create_output_folder_if_missing():
	var dir = DirAccess.open(OUTPUT_FOLDER_PATH)
	if dir == null:
		var parent_dir = DirAccess.open("res://addons/need_node_manager")
		if parent_dir:
			parent_dir.make_dir("generated")
			print("Created folder: ", OUTPUT_FOLDER_PATH)


#
# Utility: Helper function to create labeled lines easily
#
func _create_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	return label

func _create_line_edit(placeholder: String) -> LineEdit:
	var le = LineEdit.new()
	le.placeholder_text = placeholder
	return le
