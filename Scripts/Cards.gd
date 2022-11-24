extends VBoxContainer

signal completed

onready var card_Instance = load("res://Scenes/Card.tscn")

onready var Sefirot = $"../../Sefirot"
onready var Player = $"../../Player"

var cards = {}

var card_List_Collected = []
var card_List_Not_Collected = []

var counter: int = 0

var last_Card_Played: String

func _ready(): #инстанцирует карты внутри себя
	for card in (Sefirot.CARD_POS.keys()):
		var c = card_Instance.instance()
		c.name = card
		c.text = Sefirot.CARD_TRANSLATION[card]
		c.hint_tooltip = Sefirot.CARD_DESCRIPTION[card]
		cards[card] = c
		add_child(c)

func play_Card_Effect(card_name): #разыгрывает эффект переданной карты
	last_Card_Played = card_name
	cards[card_name].discard()
	match card_name:
		"The Fool":
			pass
		"The Magician":
			pass
		"The High Priestess":
			pass
		"The Empress":
			pass
		"The Emperor":
			pass
		"The Hierophant":
			pass
		"The Lovers":
			pass
		"The Chariot":
			pass
		"Strength":
			pass
		"The Hermit":
			pass
		"Wheel of Fortune":
			pass
		"Justice":
			pass
		"The Hanged Man":
			pass
		"Death":
			pass
		"Temperance":
			pass
		"The Devil":
			pass
		"The Tower":
			pass
		"The Star":
			pass
		"The Moon":
			pass
		"The Sun":
			pass
		"Judgement":
			_effect_Card_Discard_Selection(card_name, _list_Cards_Collected(), 1)
			#_effect_Card_Collect_Selection(_list_Cards_Not_Collected(), 1)
		"The World":
			_effect_Sefirah_Learn()
			_effect_HP_Restore()

#эффекты карт

func effect_Continue():
	counter -= 1
	for card_Index in _list_Cards_Collected():
		cards[card_Index].deselect()
	emit_signal("completed")



func _list_Cards_Collected(): #возвращает список собранных карт
	card_List_Collected = []
	for card in cards:
		if cards[card].is_Collected:
			card_List_Collected.append(card)
	return card_List_Collected

func _list_Cards_Not_Collected(): #возвращает список не собранных карт
	card_List_Not_Collected = []
	for card in cards:
		if !cards[card].is_Collected:
			card_List_Not_Collected.append(card)
	return card_List_Not_Collected



func _effect_Card_Collect(card_Name: Array): #получает карты из переданного списка
	for card in cards[card_Name]:
		card.collect()

func _effect_Card_Collect_Selection(array: Array, amount: int): #подсвечивает карты для получения из переданного списка
	for x in range(amount):
		for card_Index in array:
			cards[card_Index].collect_Selection()
		yield(effect_Continue(), "completed")



func _effect_Card_Discard(card_Name: Array): #сбрасывает карты из переданного списка
	for card in cards[card_Name]:
		card.discard()

func _effect_Card_Discard_Selection(card_Name: String, array: Array, amount: int): #подсвечивает карты для сброса из переданного списка
	counter = amount+1
	for x in range(amount):
		cards[card_Name].set_Status("yellow")
		for card_Index in _list_Cards_Collected():
			cards[card_Index].discard_Selection()
		yield(self, "completed")


func _get_Random(dictionary: Dictionary): #возвращает случайную карту из переданного словаря
	randomize()
	return dictionary.keys()[randi() % dictionary.size()]



func _effect_HP_Restore(HP_Restored = 1): #изменяет здоровье на переданное значение
		Player.health += HP_Restored


func _effect_Sefirah_Learn(_sefirah = Sefirot.sefirahCurrent): #изучает переданную сефиру
		Sefirot.sefirah_Learn(_sefirah)
