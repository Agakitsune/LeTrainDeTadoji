extends Control
@onready var label: Label = $Label

var value = 0
var increment = 1
var array_index = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(value)
	value = Global.current_ressources[array_index]

func _on_less_pressed() -> void:
	var current_value = Global.get_total_ressources()

	if value >= 0:
		if value > increment:
			value -= increment
			current_value -= increment
		else:
			current_value -= value
			value = 0
		Global.current_ressources[array_index] = value

func _on_more_pressed() -> void:
	var current_value = Global.get_total_ressources()

	if current_value < Global.max_ressource:
		if increment + current_value > Global.max_ressource:
			var reste = Global.max_ressource - current_value
			value += reste
			current_value += reste
		else:
			value += increment
			current_value += increment
		Global.current_ressources[array_index] = value
		
	
