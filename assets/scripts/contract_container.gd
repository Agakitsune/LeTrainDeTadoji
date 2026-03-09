extends Control
@onready var time_left_label: Label = $Panel/TimeLeft
@onready var label_name: Label = $Panel/ContractName
@onready var destination_name: Label = $Panel/DestinationName
@onready var reward: Label = $Panel/Reward
@onready var h_box_container: HBoxContainer = $Panel2/ScrollContainer/CenterContainer/HBoxContainer
@onready var penalty_label: Label = $Panel/Penalty

var cur_contract
var cur_reward
const RESSOURCES_ICON = preload("res://assets/scenes/ressources_icon.tscn")

var time_left
var penalty = 0
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	#var negative = false
	time_left -= delta
	if time_left < penalty:
		cur_reward -= 10
		cur_contract.set_reward(cur_reward)
		reward.text = str(cur_contract.get_reward()) + "$"
		fade_label(penalty_label, "-10$")
		penalty -= 5
	if time_left < 0:
		time_left_label.text = "-" + str(int(abs(time_left) / 60)) + ":" + ("%02d" % ( int(abs(time_left)) % 60))
	else:
		time_left_label.text = str(int(time_left / 60)) + ":" + ("%02d" % (int(time_left) % 60))

func fade_label(label: Label, text) -> void:
	var copy: Label = label.duplicate()
	copy.text = text
	copy.visible = true
	copy.global_position = label.global_position
	copy.modulate.a = 1.0
	get_tree().current_scene.add_child(copy)

	var tween := create_tween()

	tween.tween_property(copy, "position:y", copy.position.y - 20, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(copy, "modulate:a", 0.0, 0.6)
	tween.tween_callback(copy.queue_free)

func setup(contract):
	cur_contract = contract
	cur_reward = contract.get_reward()
	time_left = contract.get_time()
	time_left_label.text = str(contract.get_time())
	destination_name.text =  contract.get_location()
	label_name.text = contract.contract_name
	reward.text = str(contract.get_reward()) + "$"
	for ressource in contract.ressources:
		var icon = RESSOURCES_ICON.instantiate()
		var container = Control.new()
		h_box_container.add_child(container)
		h_box_container.add_theme_constant_override("separation", 60)
		container.add_child(icon)
		icon.setup(Global.resources_texture[ressource], contract.ressources[ressource])
		icon.scale = Vector2(0.4, 0.4)
