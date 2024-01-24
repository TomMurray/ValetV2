extends Object
class_name Utils

static func dir(class_instance):
	var properties = {}
	if class_instance:
		for prop in class_instance.get_property_list():
			if prop.type != TYPE_NIL and prop.name != "script":
				properties[prop.name] = class_instance.get(prop.name)
	return properties

static func get_child_of_type(n : Node, type) -> Node:
	for child in n.get_children():
		if is_instance_of(child, type):
			return child
	return null

static func quad_ease(t : float) -> float:
	var sqr := t * t
	return sqr / (2.0 * (sqr - t) + 1.0)
