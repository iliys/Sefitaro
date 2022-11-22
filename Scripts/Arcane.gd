extends Label

#signal use_Card

onready var Sefirot = $"../../../Sefirot"

var is_Collected: bool = false

var card_Status: String = "white"

var is_Discarding: bool = false
signal is_Discarded

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
		"yellow": #источник эффекта
			is_Collected = true
			_set_color(Color.yellow)
		"red": #цель для сброса
			is_Discarding = true
			_set_color(Color.red)
	card_Status = status

func _set_color(color: Color):
	self.add_color_override("font_color", color)

func _on_Card_Instance_gui_input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if is_Collected:
			if is_Discarding:
				print(name + " discarded")
				set_status("white")
				emit_signal("is_Discarded", self)
				#принимает - Sefirot.effect_Card_Discard()
				#emit_signal("is_Discarded", self)
				
			else:
				print(name + " used")
				set_status("white")
				effect(name)

func effect(card_Name):
	#emit_signal("use_Card", arcane_Name)
	Sefirot.card_Effect(card_Name)
