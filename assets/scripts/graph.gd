extends Node

var stops: Dictionary[String, TrackStop]


func connect_paths(paths: Array[TrackPath]):
	var sections := paths.map(
		func(x): return _generate_section(x)
	)
	
	var anchors: Array[TrackAnchor]
	
	for s: TrackSection in sections:
		anchors.append_array(_collect_anchors(s))
	
	for a in anchors:
		for b in anchors:
			_merge_anchors(a, b)


func _generate_section(p: TrackPath) -> TrackSection:
	var s := TrackAnchor.new()
	var head := s
	
	for i in range(p.curve.point_count - 1):
		var sec := TrackSection.new()
		sec.curve = Curve3D.new()
		sec.curve.add_point(
			p.curve.get_point_position(i),
			p.curve.get_point_in(i),
			p.curve.get_point_out(i)
		)
		sec.curve.add_point(
			p.curve.get_point_position(i + 1),
			p.curve.get_point_in(i + 1),
			p.curve.get_point_out(i + 1)
		)
		sec.curve.up_vector_enabled = false
		sec.curve.bake_interval = 1.0
		sec.start = s
		sec.end = TrackAnchor.new()
		
		sec.start.pos = p.curve.get_point_position(i)
		sec.end.pos = p.curve.get_point_position(i + 1)
		
		sec.start.connections.append(sec)
		sec.end.connections.append(sec)
		
		s = sec.end
	
	if p.stop:
		if p.stop.name not in stops:
			var stop := TrackStop.new()
			stop.name = p.stop.name
			
			stop.section = head.connections[0]
			head.connections[0].stop = stop
			
			stops[stop.name] = stop
	
	return head.connections[0]


func _collect_anchors(s: TrackSection) -> Array[TrackAnchor]:
	var arr: Array[TrackAnchor] = [
		s.start
	]
	
	for c in s.end.connections:
		if c != s:
			arr.append_array(_collect_anchors(c))
	
	if arr.size() == 1:
		arr.append(s.end)
	
	return arr


func _merge_anchors(dst: TrackAnchor, src: TrackAnchor):
	if dst == src:
		return
	if src.connections.is_empty():
		return
	if dst.connections.is_empty():
		return
	
	if dst.pos.distance_squared_to(src.pos) <= 0.0001:
		dst.connections.append_array(src.connections)
		for s in src.connections:
			if s.start == src:
				s.start = dst
			else:
				s.end = dst
		src.connections = []
