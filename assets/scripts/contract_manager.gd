extends Node

@onready var panel: Panel = $Panel
@onready var contract_list: VBoxContainer = $Panel/ContractList
@onready var select_contract_panel: Panel = $Panel/Panel
@onready var reward_label: Label = $Panel/Panel/RewardLabel
@onready var location_label: Label = $Panel/Panel/Panel/LocationLabel
@onready var time_label: Label = $Panel/Panel/Panel/TimeLabel
@onready var ressources_list: HBoxContainer = $Panel/Panel/Panel2/ScrollContainer/CenterContainer/RessourcesList
@onready var hud_contract: Control = $HudContract
@onready var money_label: Label = $Panel2/MoneyLabel
@onready var train_ressources: Control = $TrainRessources
@onready var penalty: Label = $Panel2/Penalty

const RESSOURCES_ICON = preload("res://assets/scenes/ressources_icon.tscn")
const Contract = preload("res://assets/scripts/contract.gd")

var resources_list = ["Charcoal", "Wood", "Wheat", "Rocks"]
var button_list = []
var selected_contract_id = -1
var contract_id = 1
var new_contract_list = {}
var current_contract

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.interfaces = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	money_label.text = str(Global.money) + "$"
	if Input.is_action_just_pressed("reset"):
		reset_contracts()
	if current_contract and current_contract.done == true:
		hud_contract.del_container

func show_penalty(text) -> void:
	var copy: Label = penalty.duplicate()
	copy.text = text
	copy.visible = true
	copy.global_position = penalty.global_position
	copy.modulate.a = 1.0
	get_tree().current_scene.add_child(copy)

	var tween := create_tween()
	tween.tween_property(copy, "position:y", copy.position.y + 20, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(copy, "modulate:a", 0.0, 0.6)
	tween.tween_callback(copy.queue_free)

func add_easy_contract():
	var rng = RandomNumberGenerator.new()
	var contract_time = rng.randi_range(70, 85)
	var new_contract = Contract.new()

	var possible_id = [0,1,2,3]
	var iteration = rng.randi_range(1, 3)
	var reward = 0
	for i in range(iteration):
		var ressources_id = rng.randi_range(0, len(possible_id) - 1)
		possible_id.erase(ressources_id)
		var ressource_quantity = rng.randi_range(30, 70)
		reward += rng.randi_range(40, 85)
		new_contract.add_ressource(int(ressource_quantity / iteration), resources_list[ressources_id])
	var current_stop = Global.player.wagons[0].bogeys[-1]._section.stop
	var possible_stops = Graph.stops.duplicate()
	if Global.player.wagons[0].bogeys[-1]._section.stop:
		possible_stops.erase(Global.player.wagons[0].bogeys[-1]._section.stop.name)

	var train_stop = possible_stops.keys().pick_random()
	new_contract.setup(reward, train_stop, contract_time)
	new_contract_list[contract_id] = new_contract
	var contract_list_button = Button.new()
	contract_list_button.toggle_mode = true
	contract_list_button.text = "Contract " + str(contract_id)
	new_contract.contract_name = "Contract " + str(contract_id)
	contract_list_button.pressed.connect(on_contract_selected.bind(contract_id))
	button_list.append(contract_list_button)
	contract_id += 1
	contract_list.add_child(contract_list_button)

func deselect_button(id):
	for button in button_list:
		if button.text == "Contract " + str(id):
			pass
		else:
			button.button_pressed = false

func clear_ressource_list():
	for child in ressources_list.get_children():
		child.queue_free()

func clear_button_list():
	for child in button_list:
		child.queue_free()
	button_list.clear()

func on_contract_selected(id):
	Global.depart_station = Global.player.wagons[0].bogeys[-1]._section.stop.name
	#hud_contract.disable_contract()
	deselect_button(id)
	clear_ressource_list()
	selected_contract_id = id
	
	for ressource_key in new_contract_list[id].ressources:
		var container = Control.new()
		#container.custom_minimum_size = Vector2(60, 0)
		ressources_list.add_theme_constant_override("separation", 120)
		ressources_list.add_child(container)
		var new_ressources = RESSOURCES_ICON.instantiate()
		container.add_child(new_ressources)
		new_ressources.scale = Vector2(0.7, 0.7)
		new_ressources.setup(Global.resources_texture[ressource_key], new_contract_list[id].ressources[ressource_key])
	select_contract_panel.visible = true
	reward_label.text = str(new_contract_list[id].get_reward())
	location_label.text = new_contract_list[id].get_location()
	time_label.text = str(new_contract_list[id].get_time())

func choose_contract():
	reset_contracts()
	hud_contract.del_container()
	panel.visible = true
	hud_contract.visible = false

func reset_contracts():
	for contract in contract_list.get_children():
		contract.queue_free()
	clear_button_list()
	for _i in range(5):
		add_easy_contract()

func _on_accept_button_pressed() -> void:
	for button in button_list:
		if button.text == "Contract " + str(selected_contract_id):
			current_contract = new_contract_list[selected_contract_id]
			hud_contract.add_container(current_contract)
			button_list.erase(button)
			button.queue_free()
			select_contract_panel.visible = false
			panel.visible = false
			train_ressources.visible = true

func _on_close_button_pressed() -> void:
	Global.window_is_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	panel.visible = false
