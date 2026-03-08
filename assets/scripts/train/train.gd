extends Marker3D
class_name TrainWagon

var _section: TrackSection
var _offset := 0.0
var _reverse := false # From end to start

var _next_track: Array[TrackSection]

func spawn(s: TrackSection, on_end: bool, reversed: bool):
	_section = s
	if on_end:
		_offset = s.curve.get_baked_length()
	else:
		_offset = 0.0
	_reverse = reversed
	
	global_transform.origin = _section.curve.sample_baked_with_rotation(_offset).origin
	global_transform.basis = (
		_section.curve.sample_baked_with_rotation(_offset).basis * Basis.looking_at(Vector3.MODEL_FRONT)
		if _reverse
		else
		_section.curve.sample_baked_with_rotation(_offset).basis
	)
	
	if _reverse:
		_next_track = _section.start.connections.filter(
			func (a): return a != _section
		).filter(
			func (a):
				var forward := _section.curve.sample_baked_with_rotation(0.0).basis.z
				var next_forward: Vector3
				print(forward)
				print(a.start, _section.start)
				if a.start == _section.start:
					next_forward = a.start.pos.direction_to(a.end.pos)
				else:
					print("a")
					next_forward = a.end.pos.direction_to(a.start.pos)
				print(next_forward)
				return forward.dot(next_forward) > 0.0
		) as Array[TrackSection]
	else:
		_next_track = _section.end.connections.filter(
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
	
	_order()


func advance(x: float, track: int) -> bool:
	if _reverse:
		_offset -= x
		if 0.0 > _offset:
			if _next_track.is_empty():
				return false # Stop the train
			else:
				var next := _next_track[track]
				_reverse = next.end == _section.start
				if _reverse:
					_offset += next.curve.get_baked_length() # Go to the 'end' of the curve
				else:
					_offset *= -1.0 # Just flip the offset
				_section = next # Go next wooooo
		
		_next_track = _section.start.connections.filter(
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
		
		_order()
	else:
		_offset += x
		if _section.curve.get_baked_length() < _offset:
			if _next_track.is_empty():
				return false # Stop the train
			else:
				var next := _next_track[track]
				_reverse = next.start != _section.end
				if _reverse:
					_offset -= _section.curve.get_baked_length()
					_offset = next.curve.get_baked_length() - _offset # Go to the 'end' of the curve
				else:
					_offset -= _section.curve.get_baked_length() # Go to the 'begin' of the curve
				_section = next # Go next wooooo
		
		_next_track = _section.end.connections.filter(
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
		
		_order()
	
	global_transform.origin = _section.curve.sample_baked_with_rotation(_offset).origin
	global_transform.basis = (
		_section.curve.sample_baked_with_rotation(_offset).basis * Basis.looking_at(Vector3.MODEL_FRONT)
		if _reverse
		else
		_section.curve.sample_baked_with_rotation(_offset).basis
	)
	
	return true # Advance success


func _order():
	var forward: Vector3
	var a: Vector3
	var b: Vector3
	
	if _next_track.size() != 2:
		return
	
	if _reverse:
		forward = _section.curve.sample_baked_with_rotation(0.0).basis.z
		
		if _section.start == _next_track[0].start:
			a = _next_track[0].start.pos.direction_to(_next_track[0].end.pos)
		else:
			a = _next_track[0].end.pos.direction_to(_next_track[0].start.pos)
		
		if _section.start == _next_track[1].start:
			b = _next_track[1].start.pos.direction_to(_next_track[1].end.pos)
		else:
			b = _next_track[1].end.pos.direction_to(_next_track[1].start.pos)
	else:
		forward = -_section.curve.sample_baked_with_rotation(_section.curve.get_baked_length()).basis.z
		
		if _section.end == _next_track[0].start:
			a = _next_track[0].start.pos.direction_to(_next_track[0].end.pos)
		else:
			a = _next_track[0].end.pos.direction_to(_next_track[0].start.pos)
		
		if _section.end == _next_track[1].start:
			b = _next_track[1].start.pos.direction_to(_next_track[1].end.pos)
		else:
			b = _next_track[1].end.pos.direction_to(_next_track[1].start.pos)
		
	var tmp = _next_track.duplicate()
	if forward.cross(a).y < forward.cross(b).y:
		_next_track[1] = tmp[0]
		_next_track[0] = tmp[1]
