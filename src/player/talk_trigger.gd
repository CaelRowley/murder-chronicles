extends Area2D

var current_npc: NPC


func _input(event: InputEvent):
	if event.is_action_pressed("ui_select") and !GameManager.is_dialogue_active:
		if is_instance_valid(current_npc):
			GameManager.enter_dialogue(current_npc)


func _on_body_entered(body: Node2D):
	if body.is_in_group("NPC"):
		current_npc = body


func _on_body_exited(body: Node2D):
	if body == current_npc:
		current_npc = null
	GameManager.exit_dialogue()
