extends Marker3D
class_name Player

#const WAGON := preload("uid://dxv5ih7o4q22f")
#const COUNT := 1

@onready var pitch: Marker3D = %Pitch
@onready var yaw: Marker3D = %Yaw

const LOCOMOTIVE := preload("res://assets/scenes/locomotive.tscn")
const STORAGE := preload("res://assets/scenes/storage_wagon.tscn")
signal spawn_ended()

var wagons: Array[Wagon]

var _old_track := 0
var _track := 0

var _roll := 0.0
var _pitch := 0.0
var _mouse_rotation: Vector3

var _stop := false

var _gear := 0
var _speed := 0.0
var _target := 0.0

var _started := false
var _stationed := false

signal train_stopped(station: String)

func _ready() -> void:
	wagons.resize(4)
	wagons[0] = LOCOMOTIVE.instantiate()
	wagons[1] = STORAGE.instantiate()
	wagons[2] = STORAGE.instantiate()
	wagons[3] = STORAGE.instantiate()
	
	for w in wagons:
		get_parent().add_child.call_deferred(w)
	
	#wagons[0].bogeys[0].section_changed.connect(
		#func():
			#_old_track = _track
	#)


func _input(event: InputEvent) -> void:
	if Global.window_is_open == false:
		var _mouse_input := (
				event is InputEventMouseMotion
				and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		)
		
		if _mouse_input:
			_roll = event.relative.x * 0.5
			_pitch = event.relative.y * 0.5


func _process(delta: float) -> void:
	if Global.pause == true:
		return
	var f := true
	
	if Global.window_is_open == false:
		if Input.is_action_just_pressed("gear_up"):
			_gear = minf(_gear + 1, 2)
			_target = _gear
			_target = -1.0 if _gear == -1 else _gear * 0.75
			_stop = false
			_started = true
		if Input.is_action_just_pressed("gear_down"):
			_gear = maxf(_gear - 1, -1)
			_target = -1.0 if _gear == -1 else _gear * 0.5
			_stop = false
		
		if Input.is_action_just_pressed("left"):
			_track = 0
		if Input.is_action_just_pressed("right"):
			_track = 1
		
	_speed = move_toward(_speed, _target, delta * 0.2)
	
	var t := _track
	
	if _speed >= 0.0:
		t = clampi(t, 0, maxf(0, wagons[0].bogeys[0]._next_section.size() - 1))
	else:
		t = clampi(t, 0, maxf(0, wagons[-1].bogeys[-1]._previous_section.size() - 1))
	
	var _reversing := _speed < 0.0
	
	if not _stop:
		var advance: TrainBogey.AdvanceResult
		
		global_position = wagons[0].bogeys[0].global_position
		
		if _reversing:
			advance = wagons[-1].advance(delta * _speed, t)
		else:
			advance = wagons[0].advance(delta * _speed, t)
		
		_stop = not advance.success
		var _ad := advance.travel if not advance.success else delta * _speed
		
		if advance.section_changed:
			_old_track = _track
		
		if _reversing:
			for i in range(0, wagons.size() - 1):
				var et = clampi(_old_track, 0, maxf(0, wagons[i].bogeys[-1]._previous_section.size() - 1))
				wagons[i].advance(_ad, et)
		else:
			for i in range(1, wagons.size()):
				var et = clampi(_old_track, 0, maxf(0, wagons[i].bogeys[0]._next_section.size() - 1))
				wagons[i].advance(_ad, et)
	
	if _speed == 0.0 and _started and not _stationed:
		get_tree().create_timer(0.05).timeout.connect(
			func():
				if wagons[0].bogeys[-1]._section.stop:
					_stationed = true
					train_stopped.emit(wagons[0].bogeys[-1]._section.stop.name)
		)
	
	_update_rotation()
	_update_cam()
	_roll = 0.0
	_pitch = 0.0
	
	if _speed >= 0.0:
		match wagons[0].bogeys[0]._next_section.size():
			2:
				_render_section(wagons[0].bogeys[0]._next_section[t])
			#1:
				#_render_section(wagons[0].bogeys[0]._next_section[0])
	else:
		match wagons[-1].bogeys[-1]._previous_section.size():
			2:
				_render_section(wagons[-1].bogeys[-1]._previous_section[t])
			#1:
				#_render_section(wagons[-1].bogeys[-1]._previous_section[0])


func _render_section(s: TrackSection):
	var p := s.curve.get_baked_points()
	
	#for i in range(p.size() - 1):
		#DebugDraw3D.draw_line(p[i], p[i + 1], Color.ORANGE)


func spawn(station: TrackStop, reverse := false):
	var accum := 0.0
	
	for i in range(wagons.size()):
		wagons[i].spawn(station, reverse, 0.2 + accum)
		accum += wagons[i].length + 0.05 # clearance
	spawn_ended.emit()


func _update_rotation():
	_mouse_rotation.x += _pitch * 0.01
	_mouse_rotation.x = clampf(_mouse_rotation.x, deg_to_rad(10.0), deg_to_rad(60.0))
	_mouse_rotation.y += _roll * 0.01


func _update_cam():
	var parent_rotation := Vector3(0.0, -_mouse_rotation.y, 0.0)
	var camera_rotation := Vector3(-_mouse_rotation.x, 0.0, 0.0)
	
	pitch.basis = Basis.from_euler(parent_rotation)
	yaw.basis = Basis.from_euler(camera_rotation)
