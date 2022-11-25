extends VBoxContainer

signal iteration_Completed
signal next_Effect
signal next_Effect_Start

onready var card_Instance = load("res://Scenes/Card.tscn")

onready var Sefirot = $"../../Sefirot"
onready var Player = $"../../Player"

var cards = {}
var card_Temp: String

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

func play_Card_Effect(card_Name): #разыгрывает эффект переданной карты
	last_Card_Played = card_Name
	cards[card_Name].discard()
	match card_Name:
		"The Fool":
			_effect_Sefirah_Learn()
			Sefirot.changePos("Malkhut", false, false)
			_effect_Sefirah_Learn(false)
		"The Magician":
			_effect_Card_Collect_Selection(card_Name, 1)
		"The High Priestess":
			_effect_HP_Restore(999)
		"The Empress":
			_effect_Card_Collect_Selection(card_Name, 1)
		"The Emperor":
			_effect_HP_Restore(1)
			_effect_Free_Move(card_Name, 1)
			_effect_HP_Restore(1)
		"The Hierophant":
			_effect_Sefirah_Learn()
		"The Lovers":
			_effect_Card_Discard_Selection(card_Name, 1)
			yield(self, "next_Effect")
			_effect_Card_Collect_Selection(card_Name, 1)
		"The Chariot":
			_effect_Free_Move_Around(card_Name, 1)
			_effect_HP_Restore()
			yield(self, "next_Effect")
			_effect_Sefirah_Learn()
		"Strength":
			_effect_Sefirah_Learn()
			_effect_HP_Restore()
		"The Hermit":
			_effect_Sefirah_Learn(-1)
			_effect_Card_Collect(_get_Random(cards))
		"Wheel of Fortune":
			_effect_Card_Collect(_get_Random(cards))
		"Justice":
			_effect_Sefirah_Learn(Sefirot.sefirah_Learned[Sefirot.sefirah_Last], Sefirot.sefirah_Current)
		"The Hanged Man":
			Sefirot.changePos(Sefirot.sefirah_Last, false, false)
		"Death":
			_effect_HP_Restore(1)
			Sefirot.changePos("Malkhut", false, false)
			_effect_Card_Discard(card_Name)
		"Temperance":
			_effect_Card_Discard_Selection(card_Name, 1)
			yield(self, "next_Effect")
			_effect_Sefirah_Learn()
		"The Devil":
			_effect_HP_Restore(1)
			Sefirot.changePos(_get_Random(Sefirot.CHANNELS), false, true)
		"The Tower":
			_effect_Card_Discard(card_Name)
			_effect_Card_Collect_Selection(card_Name, 1)
		"The Star":
			_effect_HP_Restore(1)
			_effect_Free_Move(card_Name, 1)
			#yield(self, "next_Effect")
		"The Moon":
			Sefirot.changePos(_get_Random(Sefirot.CHANNELS), false, false)
		"The Sun":
			_effect_HP_Restore(1)
		"Judgement":
			_effect_Card_Discard_Selection(card_Name, 1)
			yield(self, "next_Effect")
			_effect_Card_Collect_Selection(card_Name, 1)
		"The World":
			#_effect_HP_Restore()
			Sefirot.changePos("Malkhut", false, false)
			_effect_Sefirah_Learn()

#эффекты карт

func _effect_Continue():
	if counter > 0:
		counter -= 1
	emit_signal("iteration_Completed")
	if counter == 0:
		emit_signal("next_Effect")



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



func _effect_Card_Collect(cards_Name): #получает карты из переданного списка
	if typeof(cards_Name) == TYPE_ARRAY:
		for x in cards_Name:
			cards[x].collect()
	else: cards[cards_Name].collect()

func _effect_Card_Collect_Selection(card_Name: String, amount: int = 1): #подсвечивает карты для получения из переданного списка
	if _list_Cards_Collected().size() > 21:
		return
	counter = amount
	for x in range(amount):
		cards[card_Name].set_Status("yellow")
		for card_Index in cards:
			cards[card_Index].collect_Selection()
		yield(self, "iteration_Completed")
	for card_Index in cards:
		cards[card_Index].deselect()



func _effect_Card_Discard(card_Name: String): #сбрасывает карты из переданного списка
	cards[card_Name].set_Status("yellow")
	for card_Index in cards:
		cards[card_Index].discard()
	cards[card_Name].deselect()

func _effect_Card_Discard_Selection(card_Name: String, amount: int = 1): #подсвечивает карты для сброса из переданного списка
	if _list_Cards_Collected().size() < 1:
		return
	counter = amount 
	for x in range(amount):
		cards[card_Name].set_Status("yellow")
		for card_Index in cards:
			cards[card_Index].discard_Selection()
		yield(self, "iteration_Completed")
	for card_Index in cards:
		cards[card_Index].deselect()

func _effect_Free_Move(card_Name, amount = 1):
	counter = amount
	Sefirot.free_Moves = amount
	for c in cards:
		cards[c].inactive()
	for x in range(amount):
		for z in Sefirot.Sefirah_Reference.values():
			Sefirot.highlight(z)
		yield(self, "iteration_Completed")
	for z in Sefirot.Sefirah_Reference.values():
		Sefirot.highlight(z, false)
	for c in cards:
		cards[c].deselect()

func _effect_Free_Move_Around(card_Name, amount = 1):
	counter = amount
	Sefirot.free_Moves = amount
	cards[card_Name].set_Status("yellow")
	for c in cards:
		cards[c].inactive()
	#cards[card_Name].is_Collected = false
	for x in range(amount):
		for v in Sefirot.CHANNELS[Sefirot.sefirah_Current]:
			Sefirot.highlight(Sefirot.Sefirah_Reference[v])
		yield(self, "iteration_Completed")
	for z in Sefirot.Sefirah_Reference.values():
		Sefirot.highlight(z, false)
	for c in cards:
		cards[c].deselect()

func _get_Random(dictionary: Dictionary): #возвращает случайную карту из переданного словаря
	randomize()
	return dictionary.keys()[randi() % dictionary.size()]


func _effect_HP_Restore(HP_Restored = 1): #изменяет здоровье на переданное значение
		Player.health += HP_Restored


func _effect_Sefirah_Learn(amount = true, _sefirah = Sefirot.sefirah_Current): #изучает переданную сефиру
		Sefirot.sefirah_Learn(_sefirah, amount)
