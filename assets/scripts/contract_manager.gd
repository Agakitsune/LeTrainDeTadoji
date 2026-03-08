extends Node

@onready var panel: Panel = $Panel
@onready var contract_list: VBoxContainer = $Panel/ContractList
@onready var select_contract_panel: Panel = $Panel/Panel
@onready var reward_label: Label = $Panel/Panel/RewardLabel
@onready var location_label: Label = $Panel/Panel/Panel/LocationLabel
@onready var time_label: Label = $Panel/Panel/Panel/TimeLabel
@onready var ressources_list: HBoxContainer = $Panel/Panel/Panel2/ScrollContainer/CenterContainer/RessourcesList
@onready var hud_contract: Control = $HudContract

const RESSOURCES_ICON = preload("res://assets/scenes/ressources_icon.tscn")
const Contract = preload("res://assets/scripts/contract.gd")

var resources_list = ["Charcoal", "Wood", "Wheat", "Food"]
var button_list = []
var selected_contract_id = -1
var contract_id = 1
var new_contract_list = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for _i in range(5):
		add_easy_contract()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		reset_contracts()

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
		new_contract.add_ressource(ressource_quantity, resources_list[ressources_id])
	new_contract.setup(reward, "Oregon", contract_time)
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
		new_ressources.setup("res://icon.svg", new_contract_list[id].ressources[ressource_key])
	select_contract_panel.visible = true
	reward_label.text = str(new_contract_list[id].get_reward())
	location_label.text = new_contract_list[id].get_location()
	time_label.text = str(new_contract_list[id].get_time())

func reset_contracts():
	for contract in contract_list.get_children():
		contract.queue_free()
	clear_button_list()
	for _i in range(5):
		add_easy_contract()

func _on_accept_button_pressed() -> void:
	for button in button_list:
		if button.text == "Contract " + str(selected_contract_id):
			var added_contract = new_contract_list[selected_contract_id]
			hud_contract.add_container(added_contract)
			button_list.erase(button)
			button.queue_free()
			select_contract_panel.visible = false

func _on_close_button_pressed() -> void:
	panel.visible = false
