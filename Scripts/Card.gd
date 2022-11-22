extends Label

onready var Sefirot = $"../../../Sefirot"

var is_Collected: bool = false

var card_Status: String = "white"

var is_Discarding: bool = false
signal is_Discarded

var is_Aquiring: bool = false
signal is_Aquired

var pos = []

var description: String

func _ready(): #подключает сигнал для обновления состояния карт
	Sefirot.connect("card_Update", self, "card_Update")

func _on_Card_mouse_entered(): #подсвечивает карту
	highlight()

func _on_Card_mouse_exited(): #отключает подсветку карты
		highlight(false)
	
func highlight(on = true): #подсвечивка карты
	if on:
		rect_scale = Vector2(1.3, 1.3)
	else:
		rect_scale = Vector2.ONE

func card_Update(card): #эмиттер - Sefirot. Обновляет состояние полученной карты
	if name == card:
			set_status("green")

func set_status(status): #устанавливает переданный статус
	match status:
		"white": #карта на столе
			is_Collected = false
			_set_color(Color.white)
		"green": #карта в руке
			is_Collected = true
			_set_color(Color.green)
		"palegreen": #цель для подбора карты
			_set_color(Color.aquamarine)
			is_Aquiring = true
		"yellow": #источник эффекта
			is_Collected = true
			_set_color(Color.yellow)
		"red": #цель для сброса карты
			is_Discarding = true
			_set_color(Color.orangered)
		"gray": #не активна
			_set_color(Color.dimgray)
	card_Status = status

func _set_color(color: Color): #устанавливает цвет карты
	self.add_color_override("font_color", color)

func _on_Card_Instance_gui_input(event): #активирует карты по нажатию мыши с учетом их статуса
	if event is InputEventMouseButton && event.is_pressed():
		match card_Status:
			"white": #не активна
				print(name + " not Aquired")
			"green": #использует карту, запускает её эффект
				print(name + " used")
				set_status("white")
				effect(name)
			"palegreen": #получает карту
				print(name + " aquired")
				set_status("green")
				emit_signal("is_Aquired") #принимает - Sefirot.effect_Card_Aquire()
			"yellow": #не активна
				print(name + "unable to use right now")
			"red": #сбрасывает карту
				print(name + " discarded")
				set_status("white")
				emit_signal("is_Discarded") #принимает - Sefirot.effect_Card_Discard()
			"gray": #не активна
				print(name + " can't use it right now")

func effect(card_Name): #разыгрывает эффект переданной карты
	Sefirot.card_Effect(card_Name)
