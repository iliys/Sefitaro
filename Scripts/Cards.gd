extends VBoxContainer

onready var Sefirot = $"../../Sefirot"

onready var card_Instance = load("res://Scenes/Card.tscn")

var cards = {}

var last_Card_Used: String

var cards_To_Discard: int = 0

var cards_To_Aquire: int = 0

signal cards_Effect_Finished

func _ready(): #инстанцирует карты внутри себя
	for card in (Sefirot.CARD_POS.keys()):
		var c = card_Instance.instance()
		c.name = card
		c.text = Sefirot.CARD_TRANSLATION[card]
		c.hint_tooltip = Sefirot.CARD_DESCRIPTION[card]
		cards[card] = c
		add_child(c)
		c.connect("is_Discarded", self, "card_Discarded")
		c.connect("is_Aquired", self, "card_Aquired")

func cards_In(in_Hand = true): #возвращает словарь карт, находящихся в руке, или, на столе
	var cards_In = {}
	for card in cards.keys():
		if in_Hand:
			if cards[card].is_Collected:
				cards_In[card] = cards[card]
		else:
			if !cards[card].is_Collected:
				cards_In[card] = cards[card]
	return cards_In

func card_Discard(card_Name): #срасывает переданную карту
	var card = cards[card_Name]
	card.is_Collected = false

#сделать модульней
func card_Discarded(): #считает количество сброшенных карт, останавливает эффекты карт по достижению целевого числа
	cards_To_Discard -= 1
	if cards_To_Discard == 0:
		for card in cards_In().values():
			card.set_status("green")
		cards[last_Card_Used].set_status("white")
		emit_signal("cards_Effect_Finished")

#сделать модульней
func card_Aquired(): #считает количество полученных карт, останавливает эффекты карт по достижению целевого числа
	cards_To_Aquire -= 1
	if cards_To_Aquire == 0:
		for card in cards_In().values():
			card.set_status("green")
		for card in cards_In(false).values():
			card.set_status("white")
		cards[last_Card_Used].set_status("white")
		emit_signal("cards_Effect_Finished")

func card_Random(dictionary: Dictionary): #возвращает случайную карту из переданного словаря
	randomize()
	return dictionary.keys()[randi() % dictionary.size()]
