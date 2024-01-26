extends RefCounted
class_name Hit

var hitter : Node3D = null
var pos : Vector3 = Vector3.ZERO
var normal : Vector3 = Vector3.ZERO
var depth : float = 0.0

func _init(hitter_ : Node3D, pos_ : Vector3, normal_ : Vector3, depth_ : float):
	hitter = hitter_
	pos = pos_
	normal = normal_
	depth = depth_
