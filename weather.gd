extends Sprite

var sunny = preload("res://sunny.png")
var rainy = preload("res://rainy.png")

func _ready():
	self_modulate.a = 0.5
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_sunny"):
		self.set_texture(sunny)
	elif Input.is_action_just_pressed("ui_rainy"):
		self.set_texture(rainy)
