extends Label

signal effect_Continue

onready var Cards = get_parent()

var _status: String
var _previous_Status: String

var description: String

var is_Collected: bool


func _ready(): #подключает сигнал для обновления состояния карт
	connect("effect_Continue", Cards, "effect_Continue")
	set_Status("white")

func _on_Card_mouse_entered(): #подсвечивает карту
	highlight()

func _on_Card_mouse_exited(): #отключает подсветку карты
	highlight(false)
	
func highlight(on = true): #подсвечивка карты
	if on:
		rect_scale = Vector2(1.3, 1.3)
	else:
		rect_scale = Vector2.ONE

func set_Status(status): #устанавливает переданный статус
	match status:
		"white": #карта на столе
			is_Collected = false
			_set_Color(Color.white)
		"green": #карта в руке
			is_Collected = true
			_set_Color(Color.green)
		"palegreen": #цель для подбора карты
			is_Collected = false
			_set_Color(Color.aquamarine)
		"yellow": #источник эффекта
			is_Collected = true
			_set_Color(Color.yellow)
		"red": #цель для сброса карты
			is_Collected = true
			_set_Color(Color.orangered)
		"gray": #не активна
			_set_Color(Color.dimgray)
	_previous_Status = _status
	_status = status

func _on_Card_Instance_gui_input(event): #активирует карты по нажатию мыши с учетом их статуса
	if event is InputEventMouseButton && event.is_pressed():
		match _status:
			"white": #не активна
				none()
			"green": #сбрасывает карту, активирует её эффект
				_Play_Card_Effect()
			"palegreen": #получает карту
				collect()
			"yellow": #не активна
				none()
			"red": #сбрасывает карту
				discard()
			"gray": #не активна
				none()

func _set_Color(color: Color): #устанавливает цвет карты
	self.add_color_override("font_color", color)

func _Play_Card_Effect(): #разыгрывает эффект переданной карты
	#discard() # ВРЕМЕННО
	Cards.play_Card_Effect(name)
	print(name + " played")

func collect(): #собирает карту
	set_Status("green")
	print(name + " collected")
	if Cards.counter != 0:
		emit_signal("effect_Continue")

func collect_Selection(): #подсвечивает карту для получения
	if _status == "white":
		set_Status("palegreen")
	if _status == "green":
		set_Status("gray")
	#print(name + " able to aquire")

func discard(): #сбрасывает карту
	set_Status("white")
	Cards.card_Temp = name
	print(name + " discarded")
	if Cards.counter != 0:
		emit_signal("effect_Continue")

func discard_Selection(): #подсвечивает карту для сброса
	if _status == "green":
		set_Status("red")
	if _status == "white":
		set_Status("gray")
	#print(name + " is getting discarded")

func deselect():
	if _status == "yellow" or _status == "palegreen" or _status == "gray":
		set_Status(_previous_Status)
	if _status == "red":
		set_Status("green")

func inactive(): #подсвечивает карту как неактивную
	set_Status("gray")

func none(): #нет эффекта
	print(name + " can't be used right now")
