extends VBoxContainer

onready var Sefirot = $"../../Sefirot"

onready var card_Instance = preload("res://Card_Instance.tscn")

# не используется
var child_Ref = []

var child_Dict = {}

var last_Card_Used: String

#var cards_Discarded = []
var cards_To_Discard: int = 0

#var cards_Aqquired = []
var cards_To_Aqquire: int = 0

signal cards_Effect_Finished

# не используется
var number = 0

func _ready():
	for card in (Sefirot.ARCANE_POS.keys()):
		var c = card_Instance.instance()
		c.name = card
		c.text = Sefirot.ARCANE_TRANSLATION[card]
		c.hint_tooltip = Sefirot.ARCANE_DESCRIPTION[card]
		child_Dict[card] = c
		add_child(c)
		number +=1
		child_Ref.append(c)
		#подключает каждую карту
		c.connect("is_Discarded", self, "card_Discarded")
		c.connect("is_Aqquired", self, "card_Aqquired")

#словарь карт в руке, или на столе
func cards_In(in_Hand = true):
	var cards_In = {}
	for card in child_Dict.keys():
		if in_Hand:
			if child_Dict[card].is_Collected:
				cards_In[card] = child_Dict[card]
		else:
			if !child_Dict[card].is_Collected:
				cards_In[card] = child_Dict[card]
	return cards_In

func card_Discard(card_Name):
	var card = child_Dict[card_Name]
	card.is_Collected = false

#сделать модульней
func card_Discarded(card_Name):
	#cards_Discarded.clear()
	#cards_Discarded.append(card_Name)
	cards_To_Discard -= 1
	if cards_To_Discard == 0:
		for card in cards_In().values():
			card.set_status("green")
		child_Dict[last_Card_Used].set_status("white")
		emit_signal("cards_Effect_Finished")

func card_Aqquired(card_Name):
	#cards_Aqquired.clear()
	#cards_Aqquired.append(card_Name)
	cards_To_Aqquire -= 1
	if cards_To_Aqquire == 0:
		for card in cards_In().values():
			card.set_status("green")
		for card in cards_In(false).values():
			card.set_status("white")
		child_Dict[last_Card_Used].set_status("white")
		emit_signal("cards_Effect_Finished")

# на удаление
func card_Highlight(except = null):
	for card in child_Dict.values():
			if card.is_Collected:
				card.set_status("red")
				if card.name == except:
					card.set_status("yellow")

func card_Random(dictionary: Dictionary):
	randomize()
	return dictionary.keys()[randi() % dictionary.size()]
