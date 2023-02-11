extends CharacterBody3D

@export var move_speed := 5.0
@export var move_acceleration := 10.0
@export var move_friction := 10.0
@export var jump_velocity := 4.5
@export var aim_sensitivity := 0.2
@export var aim_max_angle := 90
@export var aim_min_angle := -90

var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
var look_rot := Vector3.UP

@onready var head := $Head as Node3D


func _physics_process(delta: float):
	_handle_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	_handle_camera()


func _handle_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta


func _handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity


func _handle_movement(delta: float):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * move_speed, move_acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * move_speed, move_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, delta * move_friction)
			velocity.z = move_toward(velocity.z, 0, delta * move_friction)

	move_and_slide()


func _handle_camera():
#	Rotate the head to look up and down
	head.rotation_degrees.x = look_rot.x
#	Rotate hte body for looking left and right
	rotation_degrees.y = look_rot.y


func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		look_rot.y -= event.relative.x * aim_sensitivity
		look_rot.x -= event.relative.y * aim_sensitivity
		look_rot.x = clamp(look_rot.x, aim_min_angle, aim_max_angle)
