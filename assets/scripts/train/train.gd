extends Marker3D
class_name TrainBogey

var _offset := 0.0
var _front := false # From start to end

var _section: TrackSection
var _next_section: Array[TrackSection]
var _previous_section: Array[TrackSection]

signal section_changed

class AdvanceResult:
	var success := true
	var section_changed := false
	var travel: float
	var remainder: float

func _ready() -> void:
	pass
	#add_child(scene.instantiate())


func spawn(s: TrackSection, front: bool, off: float = 0.0):
	_section = s
	
	if front:
		_offset = off
	else:
		_offset = s.curve.get_baked_length() - off
	_front = front
	
	if _front:
		if _offset < 0.0:
			_offset = s.end.connections[0].curve.get_baked_length() + _offset
			spawn(s.end.connections[0], _offset)
			return
	else:
		if _offset > s.curve.get_baked_length():
			_offset -= s.curve.get_baked_length()
			spawn(s.end.connections[0], _offset)
			return
	
	_section_changed()
	
	global_transform.origin = _section.curve.sample_baked_with_rotation(_offset).origin
	global_transform.basis = (
		_section.curve.sample_baked_with_rotation(_offset).basis * Basis.looking_at(Vector3.MODEL_FRONT)
		if _front
		else
		_section.curve.sample_baked_with_rotation(_offset).basis
	)


func advance(x: float, track: int) -> AdvanceResult:
	var _reversing := x < 0.0
	var res := AdvanceResult.new()
	
	if _front:
		_offset -= x
		if 0.0 > _offset:
			if _next_section.is_empty():
				res.remainder = absf(_offset)
				res.travel = absf(x) - res.remainder
				res.success = false
				_offset = 0.0
				return res # Stop the train
			else:
				var next := _next_section[track]
				_front = next.end == _section.start
				if _front:
					_offset += next.curve.get_baked_length() # Go to the 'end' of the curve
				else:
					_offset *= -1.0 # Just flip the offset
				_section = next # Go next wooooo
				_section_changed()
				section_changed.emit()
				res.section_changed = true
		elif _section.curve.get_baked_length() < _offset:
			if _previous_section.is_empty():
				res.remainder = _offset - _section.curve.get_baked_length()
				res.travel = x - res.remainder
				res.success = false
				_offset = _section.curve.get_baked_length()
				return res # Stop the train
			else:
				var next := _previous_section[track]
				_front = next.start != _section.end
				if _front:
					_offset -= _section.curve.get_baked_length()
					_offset = next.curve.get_baked_length() - _offset # Go to the 'end' of the curve
				else:
					_offset -= _section.curve.get_baked_length() # Go to the 'begin' of the curve
				_front = (not _front) if _reversing else _front
				_section = next # Go next wooooo
				_section_changed()
				section_changed.emit()
				res.section_changed = true
	else:
		_offset += x
		if _section.curve.get_baked_length() < _offset:
			if _next_section.is_empty():
				res.remainder = _offset - _section.curve.get_baked_length()
				res.travel = x - res.remainder
				res.success = false
				_offset = _section.curve.get_baked_length()
				return res # Stop the train
			else:
				var next := _next_section[track]
				_front = next.start != _section.end
				if _front:
					_offset -= _section.curve.get_baked_length()
					_offset = next.curve.get_baked_length() - _offset # Go to the 'end' of the curve
				else:
					_offset -= _section.curve.get_baked_length() # Go to the 'begin' of the curve
				_section = next # Go next wooooo
				_section_changed()
				section_changed.emit()
				res.section_changed = true
		elif 0.0 > _offset:
			if _previous_section.is_empty():
				res.remainder = absf(_offset)
				res.travel = absf(x) - res.remainder
				res.success = false
				_offset = 0.0
				return res # Stop the train
			else:
				var next := _previous_section[track]
				_front = next.end == _section.start
				if _front:
					_offset += next.curve.get_baked_length() # Go to the 'end' of the curve
				else:
					_offset *= -1.0 # Just flip the offset
				_front = (not _front) if _reversing else _front
				_section = next # Go next wooooo
				_section_changed()
				section_changed.emit()
				res.section_changed = true
	
	global_transform.origin = _section.curve.sample_baked_with_rotation(_offset).origin
	global_transform.basis = (
		_section.curve.sample_baked_with_rotation(_offset).basis * Basis.looking_at(Vector3.MODEL_FRONT)
		if _front
		else
		_section.curve.sample_baked_with_rotation(_offset).basis
	)
	
	res.travel = x
	res.remainder = 0.0
	res.success = true
	return res # Advance success


func _section_changed():
	_pick_next_section()
	_pick_previous_section()
	
	_order_next()
	_order_previous()


func _order_next():
	var forward: Vector3
	var a: Vector3
	var b: Vector3
	
	if _next_section.size() != 2:
		return
	
	if _front:
		forward = _section.curve.sample_baked_with_rotation(0.0).basis.z
		
		if _section.start == _next_section[0].start:
			a = _next_section[0].start.pos.direction_to(_next_section[0].end.pos)
		else:
			a = _next_section[0].end.pos.direction_to(_next_section[0].start.pos)
		
		if _section.start == _next_section[1].start:
			b = _next_section[1].start.pos.direction_to(_next_section[1].end.pos)
		else:
			b = _next_section[1].end.pos.direction_to(_next_section[1].start.pos)
	else:
		forward = -_section.curve.sample_baked_with_rotation(_section.curve.get_baked_length()).basis.z
		
		if _section.end == _next_section[0].start:
			a = _next_section[0].start.pos.direction_to(_next_section[0].end.pos)
		else:
			a = _next_section[0].end.pos.direction_to(_next_section[0].start.pos)
		
		if _section.end == _next_section[1].start:
			b = _next_section[1].start.pos.direction_to(_next_section[1].end.pos)
		else:
			b = _next_section[1].end.pos.direction_to(_next_section[1].start.pos)
		
	var tmp = _next_section.duplicate()
	if forward.cross(a).y < forward.cross(b).y:
		_next_section[1] = tmp[0]
		_next_section[0] = tmp[1]


func _order_previous():
	var forward: Vector3
	var a: Vector3
	var b: Vector3
	
	if _previous_section.size() != 2:
		return
	
	if _front:
		forward = -_section.curve.sample_baked_with_rotation(0.0).basis.z
		
		if _section.end == _previous_section[0].start:
			a = _previous_section[0].start.pos.direction_to(_previous_section[0].end.pos)
		else:
			a = _previous_section[0].end.pos.direction_to(_previous_section[0].start.pos)
		
		if _section.end == _previous_section[1].start:
			b = _previous_section[1].start.pos.direction_to(_previous_section[1].end.pos)
		else:
			b = _previous_section[1].end.pos.direction_to(_previous_section[1].start.pos)
	else:
		forward = _section.curve.sample_baked_with_rotation(_section.curve.get_baked_length()).basis.z
		
		if _section.start == _previous_section[0].start:
			a = _previous_section[0].start.pos.direction_to(_previous_section[0].end.pos)
		else:
			a = _previous_section[0].end.pos.direction_to(_previous_section[0].start.pos)
		
		if _section.start == _previous_section[1].start:
			b = _previous_section[1].start.pos.direction_to(_previous_section[1].end.pos)
		else:
			b = _previous_section[1].end.pos.direction_to(_previous_section[1].start.pos)
	
	var tmp = _previous_section.duplicate()
	if forward.cross(a).y < forward.cross(b).y:
		_previous_section[1] = tmp[0]
		_previous_section[0] = tmp[1]


func _pick_next_section():
	if _front:
		_next_section = _section.start.connections.filter(
			func (a): return a != _section
		).filter(
			func (a):
				var forward := _section.curve.sample_baked_with_rotation(0.0).basis.z
				var next_forward: Vector3
				if a.start == _section.start:
					next_forward = a.start.pos.direction_to(a.end.pos)
				else:
					next_forward = a.end.pos.direction_to(a.start.pos)
				return forward.dot(next_forward) > 0.0
		) as Array[TrackSection]
	else:
		_next_section = _section.end.connections.filter(
			func (a): return a != _section
		).filter(
			func (a):
				var forward := -_section.curve.sample_baked_with_rotation(_section.curve.get_baked_length()).basis.z
				var next_forward: Vector3
				if a.start == _section.end:
					next_forward = a.start.pos.direction_to(a.end.pos)
				else:
					next_forward = a.end.pos.direction_to(a.start.pos)
				return forward.dot(next_forward) > 0.0
		) as Array[TrackSection]


func _pick_previous_section():
	if _front:
		_previous_section = _section.end.connections.filter(
			func (a): return a != _section
		).filter(
			func (a):
				var forward := -_section.curve.sample_baked_with_rotation(_section.curve.get_baked_length()).basis.z
				var next_forward: Vector3
				if a.start == _section.end:
					next_forward = a.start.pos.direction_to(a.end.pos)
				else:
					next_forward = a.end.pos.direction_to(a.start.pos)
				return forward.dot(next_forward) > 0.0
		) as Array[TrackSection]
	else:
		_previous_section = _section.start.connections.filter(
			func (a): return a != _section
		).filter(
			func (a):
				var forward := _section.curve.sample_baked_with_rotation(0.0).basis.z
				var next_forward: Vector3
				if a.start == _section.start:
					next_forward = a.start.pos.direction_to(a.end.pos)
				else:
					next_forward = a.end.pos.direction_to(a.start.pos)
				return forward.dot(next_forward) > 0.0
		) as Array[TrackSection]
