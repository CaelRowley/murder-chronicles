class_name NPC
extends CharacterBody2D

@export_category("Chat icon")
@export var icon: Texture

@export_category("OpenAI Description")
@export_multiline var physical_description: String
@export_multiline var location_description: String
@export_multiline var personality: String
@export_multiline var secret_knowledge: String
