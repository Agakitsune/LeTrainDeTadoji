extends Control
const CONTRACT_CONTAINER = preload("res://assets/scenes/contract_container.tscn")
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var train_ressources: Control = $"../TrainRessources"
@onready var button_contract: Button = $ButtonContract
@onready var parent: Control = $".."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.pause == false:
		if Input.is_action_just_pressed("ressource") and Global.player.wagons[0].bogeys[-1]._section.stop:
			if Global.player.wagons[0].bogeys[-1]._section.stop.name == Global.depart_station:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				visible = false
				train_ressources.visible = true
				Global.window_is_open = true
		if Input.is_action_just_pressed("contract") and len(v_box_container.get_children()) == 0 and Global.window_is_open == false:
			if Global.player.wagons[0].bogeys[-1]._section.stop:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				parent.choose_contract()
				Global.window_is_open = true
		

func del_container():
	for child in v_box_container.get_children():
		child.queue_free()

func add_container(contract):
	var new_contract = CONTRACT_CONTAINER.instantiate()
	v_box_container.add_child(new_contract)
	new_contract.scale = Vector2(0.2,0.2)
	new_contract.setup(contract)
	new_contract.add_child(contract)

func disable_contract():
	button_contract.disabled = true

func _on_button_ressource_pressed() -> void:
	visible = false
	train_ressources.visible = true

func _on_button_contract_pressed() -> void:
	parent.choose_contract()
