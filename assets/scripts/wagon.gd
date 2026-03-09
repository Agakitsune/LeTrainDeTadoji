extends Node3D
class_name Wagon

@export var bogeys: Array[TrainBogey]
@export var mesh: Node3D

@export var length := 0.0

var _track := 0
var _old_track := 0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	mesh.global_position = lerp(
		bogeys[0].global_position,
		bogeys[1].global_position,
		0.5
	)
	mesh.global_basis = bogeys[0].global_basis.slerp(
		bogeys[1].global_basis,
		0.5
	)


func spawn(station: TrackStop, reverse := false, off := 0.0):
	var start := bogeys[0]
	var dist: PackedFloat32Array
	
	for b in bogeys:
		dist.append(
			b.global_position.distance_to(start.global_position)
		)
	
	for i in range(bogeys.size()):
		bogeys[i].spawn(station.section, reverse, off + dist[i])


func advance(x: float, t: int) -> TrainBogey.AdvanceResult:
	var travel: TrainBogey.AdvanceResult
	
	var _reversing := x < 0.0
	var _ad := 0.0
	
	if _reversing:
		travel = bogeys[-1].advance(x, t)
		_ad = travel.travel if travel else x
	else:
		travel = bogeys[0].advance(x, t)
		_ad = travel.travel if travel else x
	
	if travel.section_changed:
		_track = t
	
	if _reversing:
		for i in range(0, bogeys.size() - 1):
			bogeys[i].advance(_ad, _track)
	else:
		for i in range(1, bogeys.size()):
			bogeys[i].advance(_ad, _track)
	
	return travel
