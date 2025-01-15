extends Control

@onready var status_label = $NeedLevelLabel  # Reference to your Label node

func update_need_level(needs_list):
	var display_text = ""  # Initialize the display text

	# Iterate over each node (key) in the dictionary
	for node in needs_list.keys():
		if node is Node:
			var res_type = node.res_type  # Access res_type property from node
			var res_status = needs_list[node]  # Get the need status value
			display_text += "%s: %s\n" % [res_type, str(res_status)]
		else:
			print(node)
			print("Unexpected key type, expected Node: ", node)

	# Update the label's text
	status_label.text = display_text
