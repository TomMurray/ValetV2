extends RefCounted
class_name Hit

var hitter : Node3D = null
var normal : Vector3 = Vector3.ZERO
var depth : float = 0.0

func _init(_hitter : Node3D, _normal : Vector3, _depth : float):
	hitter = _hitter
	normal = _normal
	depth = _depth
