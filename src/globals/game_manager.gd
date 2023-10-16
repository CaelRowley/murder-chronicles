extends Node

signal on_enter_dialogue(npc: NPC)
signal on_exit_dialogue
signal on_player_talk
signal on_npc_talk(message: String)

const CONFIG_FILE := "res://config/config.cfg"

@export_category("OpenAI API Configuration")
@export var url := "https://api.openai.com/v1/chat/completions"
@export var model := "gpt-3.5-turbo"
@export var headers: Array[String] = ["Content-type: application/json"]

@export_category("Generation Parameters")
@export_range(0.2, 1.5, 0.05) var temperature := 0.5
@export_range(256, 4096, 1) var max_tokens := 1024
@export_multiline var dialogue_rules: String

var messages := []
var current_npc: NPC
var is_dialogue_active := false

@onready var request := $HTTPRequest as HTTPRequest


func _ready():
	var config: ConfigFile = ConfigFile.new()
	config.load(CONFIG_FILE)
	headers.push_back("Authorization: Bearer " + config.get_value("Secrets", "OpenAIAPIKey"))
	request.connect("request_completed", _on_request_completed)


func dialogue_request(player_dialogue: String):
	var prompt := player_dialogue

	if messages.is_empty():
		var header_prompt := "Act as a " + current_npc.physical_description + " in a fantasy RPG. "
		header_prompt += "As a character, you are " + current_npc.personality + ". "
		header_prompt += "Your location is  " + current_npc.location_description + ". "
		header_prompt += "You have secret knowledge that you won't speak about unless asked by me: " + current_npc.secret_knowledge + ". "
		prompt = dialogue_rules + "\n" + header_prompt

	messages.append({"role": "user", "content": prompt})
	on_player_talk.emit()

	var body := JSON.stringify({"messages": messages, "temperature": temperature, "max_tokens": max_tokens, "model": model})

	var send_request := request.request(url, headers, HTTPClient.METHOD_POST, body)

	if send_request != OK:
		print("There was an error!")


func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json := JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var message = response["choices"][0]["message"]["content"]
	messages.append({"role": "system", "content": message})
	on_npc_talk.emit(message)


func enter_dialogue(npc: NPC):
	is_dialogue_active = true
	on_enter_dialogue.emit(npc)
	current_npc = npc
	messages = []
	dialogue_request("")


func exit_dialogue():
	is_dialogue_active = false
	on_exit_dialogue.emit()
	current_npc = null
	messages = []
