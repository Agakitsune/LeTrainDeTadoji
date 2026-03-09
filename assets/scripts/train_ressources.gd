extends Control
@onready var incrementor: Control = $Incrementor
@onready var incrementor_2: Control = $Incrementor2
@onready var incrementor_4: Control = $Incrementor4
@onready var incrementor_3: Control = $Incrementor3
@onready var hud_contract: Control = $"../HudContract"

@onready var label_2: Label = $Panel/Label2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	incrementor.array_index = "Charcoal"
	incrementor_2.array_index = "Rocks"
	incrementor_3.array_index = "Wheat"
	incrementor_4.array_index = "Wood"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label_2.text = "Remaining Space: " + str(Global.get_total_ressources()) + "/" + str(Global.max_ressource)

func _on_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.window_is_open = false
	visible = false
	hud_contract.visible = true

func _on_close_button_pressed() -> void:
	Global.window_is_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false
	hud_contract.visible = true
