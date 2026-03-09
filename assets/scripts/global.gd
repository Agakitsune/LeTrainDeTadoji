extends Node

var money = 0
var max_ressource = 75
var current_ressources = [0,0,0,0]
var resources_texture = {"Charcoal" : "res://assets/textures/Coal.png", "Rocks": "res://assets/textures/rocks.png", "Wheat": "res://assets/textures/wheat.png", "Wood": "res://assets/textures/wood.png" }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_total_ressources():
	var res = 0
	for ressource in current_ressources:
		res += ressource
	return res
