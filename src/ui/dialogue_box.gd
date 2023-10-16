extends Panel

@onready var dialogue_text := $DialogueText as RichTextLabel
@onready var npc_icon := $NPCIcon as TextureRect
@onready var talk_input := $PlayerTalkInput as TextEdit
@onready var talk_button := $TalkButton as Button
@onready var leave_button := $LeaveButton as Button


func _ready():
	GameManager.on_enter_dialogue.connect(_on_enter_dialogue)
	GameManager.on_exit_dialogue.connect(_on_exit_dialogue)
	GameManager.on_player_talk.connect(_on_player_talk)
	GameManager.on_npc_talk.connect(_on_npc_talk)


func init_with_npc(npc: NPC):
	npc_icon.texture = npc.icon
	dialogue_text.text = ""
	talk_button.disabled = true


func _on_enter_dialogue(npc: NPC):
	visible = true
	init_with_npc(npc)


func _on_exit_dialogue():
	visible = false


func _on_player_talk():
	talk_input.text = ""
	dialogue_text.text = "Hmm..."
	talk_button.disabled = true


func _on_npc_talk(message: String):
	dialogue_text.text = message
	talk_button.disabled = false


func _on_talk_button_pressed():
	GameManager.dialogue_request(talk_input.text)


func _on_leave_button_pressed():
	GameManager.exit_dialogue()
