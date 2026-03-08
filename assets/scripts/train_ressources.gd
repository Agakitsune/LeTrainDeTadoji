extends Control
@onready var incrementor: Control = $Incrementor
@onready var incrementor_2: Control = $Incrementor2
@onready var incrementor_4: Control = $Incrementor4
@onready var incrementor_3: Control = $Incrementor3

@onready var label_2: Label = $Panel/Label2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	incrementor_2.array_index = 1
	incrementor_3.array_index = 2
	incrementor_4.array_index = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label_2.text = "Remaining Space: " + str(Global.get_total_ressources()) + "/" + str(Global.max_ressource)
