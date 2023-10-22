extends MeshInstance3D

var is_pressed := false

@export var dalle: Dalle


func _press():
	translate(Vector3(0.0, -0.5, 0.0))
	is_pressed = true
	dalle.generate_image("cowboy", "256x256")


func _unpress():
	translate(Vector3(0.0, 0.5, 0.0))
	is_pressed = false


func _on_area_3d_body_entered(body):
	if !is_pressed:
		_press()


func _on_area_3d_body_exited(body):
	if is_pressed:
		_unpress()
