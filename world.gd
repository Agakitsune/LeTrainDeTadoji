extends Node3D

@onready var marker_3d: Marker3D = $Marker3D
@onready var train_wagon: TrainWagon = $TrainWagon

var t := 0

func _ready() -> void:
	var paths: Array[TrackPath]
	
	for i in get_children():
		if i is TrackPath:
			paths.append(i)
	
	Graph.connect_paths(paths)
	train_wagon.spawn(Graph.stops["Mak"].section, true, true)
	
	for i in Graph.stops:
		print("Found stop: ", Graph.stops[i].name)


func _process(delta: float) -> void:
	_render_section(train_wagon._section)
	
	match train_wagon._next_track.size():
		1:
			_render_section(train_wagon._next_track[0])
			t =0
		2:
			_render_section(train_wagon._next_track[t])
	
			if Input.is_action_just_pressed("ui_left"):
				t = 0
			if Input.is_action_just_pressed("ui_right"):
				t = 1
	
	train_wagon.advance(delta, t)


func _render_section(a: TrackSection):
	var p := a.curve.get_baked_points()
	
	for i in range(p.size() - 1):
		DebugDraw3D.draw_line(p[i], p[i + 1], Color.ORANGE)
