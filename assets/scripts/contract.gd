extends Node

var ressources = {}
var contract_name = ""
var _reward = 0
var _location = ""
var _time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(reward: int, location: String, contract_time : int):
	_reward = reward
	_location = location
	_time = contract_time

func get_reward():
	return _reward

func set_reward(reward):
	_reward = reward

func get_location():
	return _location

func get_time():
	return _time

func add_ressource(quantity: int, ressource_name: String):
	ressources[ressource_name] = quantity
