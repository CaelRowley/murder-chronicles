extends CharacterBody2D

@export var speed := 100.0


func _physics_process(_delta: float):
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * speed
	move_and_slide()
