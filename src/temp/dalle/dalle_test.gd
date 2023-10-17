extends Node2D

const CONFIG_FILE := "res://config/config.cfg"
const GeneratedImage = preload("res://temp/dalle/generated_image.tscn")

@export_category("OpenAI API Configuration")
@export var url := "https://api.openai.com/v1/images/generations"
@export var headers := ["Content-type: application/json"] as Array[String]

var request_url: HTTPRequest
var request_image: HTTPRequest


func _ready():
	var config: ConfigFile = ConfigFile.new()
	config.load(CONFIG_FILE)
	var bearer_token := str("Authorization: Bearer " + config.get_value("Secrets", "OpenAIAPIKey"))
	if bearer_token not in headers:
		headers.push_back(bearer_token)
	
	request_url = HTTPRequest.new()
	add_child(request_url)
	request_url.connect("request_completed", _on_request_url_completed)

	request_image = HTTPRequest.new()
	add_child(request_image)
	request_image.connect("request_completed", _on_request_image_completed)
	
	generate_image("cheese", "256x256")


func generate_image(prompt: String, size: String):
	var body := JSON.stringify({"prompt": prompt, "n": 1, "size": size})

	var err := request_url.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		print("There was an error generating the image!")


func _on_request_url_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var json := JSON.new()
	json.parse(body.get_string_from_utf8())
	var response: Variant = json.get_data()
	var image_url := response["data"][0]["url"] as String
	var err = request_image.request(image_url)
	if err != OK:
		print("There was an error downloading the image!")


func _on_request_image_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	var image := Image.new()
	var err := image.load_png_from_buffer(body)
	if err != OK:
		print("Couldn't load image.")
	var texture := ImageTexture.create_from_image(image)
	var generated_image := GeneratedImage.instantiate()
	add_child(generated_image)
	generated_image.set_image(texture)
