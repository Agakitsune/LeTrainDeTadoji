extends Node

var max_ressource = 75
var current_ressources = [0,0,0,0]

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
