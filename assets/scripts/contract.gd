extends Node

var done = false
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
	if Global.player.wagons[0].bogeys[-1]._section.stop:
		if Global.player.wagons[0].bogeys[-1]._section.stop.name == _location:
			contract_done()

func contract_done():
	var missing_materials = 0
	for ressource in ressources:
		if ressources[ressource] > Global.current_ressources[ressource]:
			missing_materials += ressources[ressource] - Global.current_ressources[ressource]
			Global.current_ressources[ressource] = 0
		else:
			Global.current_ressources[ressource] -= ressources[ressource]
	var total = 0
	for ressource in ressources:
		total += ressources[ressource]
	print(ressources)
	print(missing_materials)
	if missing_materials == total:
		_reward = 0
		Global.interfaces.show_penalty("No ressources 0$ added")
	elif missing_materials > 0 and missing_materials < total / 1.5:
		_reward = int(_reward / 2)
		Global.interfaces.show_penalty("Missing ressources " + str(_reward) + "$ added")
	elif missing_materials > total / 1.5:
		_reward = int(_reward / 5)
		Global.interfaces.show_penalty("Missing ressources " + str(_reward) + "$ added")
	if _reward < 0:
		_reward = 0
	Global.money += _reward
	Global.interfaces.hud_contract.del_container()

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
