extends Control
const CONTRACT_CONTAINER = preload("res://assets/scenes/contract_container.tscn")
@onready var v_box_container: VBoxContainer = $VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_container(contract):
	var new_contract = CONTRACT_CONTAINER.instantiate()
	v_box_container.add_child(new_contract)
	new_contract.scale = Vector2(0.2,0.2)
	new_contract.setup(contract)
