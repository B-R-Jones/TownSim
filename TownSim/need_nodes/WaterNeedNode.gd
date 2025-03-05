# DefaultNeedNode.gd
extends Node2D

class_name WaterNeedNode

# SIGNALS
signal res_status_updated(res_type, res_status)
signal res_level_critical(res_type, priority, res_node)
signal res_level_full(res_type)
signal play_anim(anim_type)

# RESOURCE SETTINGS
@onready var res_type = "water"
@onready var res_status = 0.5
@onready var res_max = 1.0
@onready var res_min = 0.0
@onready var res_loss_rate = 0.0125
@onready var res_gain_rate = 0.025
@onready var res_signal = 0.25

# HANDLER HELPERS
@onready var priority = 1
@onready var thought_node
@onready var satisfy = false
@onready var anim_type = "drinking"

func _ready():
	set_connects()

func set_thought_node(thought_node_source: Node2D):
	thought_node = thought_node_source

func set_connects():
	if thought_node:  # Ensure thought_node is valid
		res_status_updated.connect(thought_node._on_res_status_updated)
		res_level_critical.connect(thought_node._on_res_level_critical)
		res_level_full.connect(thought_node._on_res_level_full)

func _process(delta):
	if satisfy == false:
		drain(delta)
	else:
		fill(delta)

	emit_signal("res_status_updated", self, res_status)

	if res_status <= res_signal:
		emit_signal("res_level_critical", res_type, priority, self)

	if res_status == res_max:
		emit_signal("res_level_full", res_type)

func drain(delta):
	res_status -= res_loss_rate * delta
	if res_status < res_min: res_status = res_min

func fill(delta):
	emit_signal("play_anim", anim_type)
	res_status += res_gain_rate * delta
	if res_status >= res_max:
		res_status = res_max
		satisfy = false
