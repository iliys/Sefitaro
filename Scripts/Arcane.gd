extends Label

#signal use_Card

onready var Sefirot = $"../../../Sefirot"

var is_Collected: bool = false

var card_Status: String = "white"

var is_Discarding: bool = false
signal is_Discarded

var is_Aqquiring: bool = false
signal is_Aqquired

var pos = []

var description: String

func _ready():
	Sefirot.connect("card_Update", self, "card_update")

func _on_Arcane_mouse_entered():
	if Sefirot.arcaneActive[name]:
		highlight()

func _on_Arcane_mouse_exited():
	highlight(false)
	
func highlight(on = true):
	if on:
		rect_scale = Vector2(1.5, 1.5)
	else:
		rect_scale = Vector2(1, 1)

#эмиттер - Sephirot (Tree)
func card_update(card):
	if name == card:
			set_status("green")

func set_status(status):
	match status:
		"white": #карта не собрана
			is_Collected = false
			_set_color(Color.white)
		"green": #карта собрана
			#if card_Status == "yellow":
				#is_Collected = false
			#else:
				is_Collected = true
				_set_color(Color.green)
		"palegreen":
			_set_color(Color.greenyellow)
			is_Aqquiring = true
		"yellow": #источник эффекта
			is_Collected = true #мейби false сделать?
			_set_color(Color.yellow)
		"red": #цель для сброса
			is_Discarding = true
			_set_color(Color.red)
		"gray": #скрыта
			_set_color(Color.dimgray)
	card_Status = status

func _set_color(color: Color):
	self.add_color_override("font_color", color)

func _on_Card_Instance_gui_input(event):
	if event is InputEventMouseButton && event.is_pressed():
		match card_Status:
			"white":
				print(name + " not Aqquired")
			"green":
				print(name + " used")
				set_status("white")
				effect(name)
			"palegreen":
				print(name + " aqquired")
				set_status("green")
				emit_signal("is_Aqquired", self)
			"yellow":
				print(name + "unable to use right now")
			"red":
				print(name + " discarded")
				set_status("white")
				#принимает - Sefirot.effect_Card_Discard()
				emit_signal("is_Discarded", self)
			"gray":
				print(name + " unable to use right now")

func effect(card_Name):
	#emit_signal("use_Card", arcane_Name)
	Sefirot.card_Effect(card_Name)
