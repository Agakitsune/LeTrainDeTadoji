extends Object
class_name VecHelper

static func intersect(
	p1: Vector3,
	p2: Vector3,
	r: Vector3,
	s: Vector3,
	plane: PlaneMesh.Orientation
) -> PackedFloat32Array:
	if plane == PlaneMesh.Orientation.FACE_X:
		p1 = Vector3(p1.y, 0.0, p1.z)
		p2 = Vector3(p2.y, 0.0, p2.z)
		r = Vector3(r.y, 0.0, r.z)
		s = Vector3(s.y, 0.0, s.z)
	
	if plane == PlaneMesh.Orientation.FACE_Z:
		p1 = Vector3(p1.x, 0.0, p1.y)
		p2 = Vector3(p2.x, 0.0, p2.y)
		r = Vector3(r.x, 0.0, r.y)
		s = Vector3(s.x, 0.0, s.y)
	
	var qmp := p2 - p1
	var rcs := r.x * s.z - r.z * s.x
	
	if rcs == 0.0:
		return []
	
	var rdivrcs := r * (1.0 / rcs)
	var sdivrcs := s * (1.0 / rcs)
	
	return [
		qmp.x * sdivrcs.z - qmp.z * sdivrcs.z,
		qmp.x * rdivrcs.z - qmp.z * rdivrcs.z
	]
