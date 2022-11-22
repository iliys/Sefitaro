extends VBoxContainer

onready var Sefirot = $"../../Sefirot"

onready var card_Instance = preload("res://Card_Instance.tscn")

# не используется
var child_Ref = []

var child_Dict = {}

var last_Card_Used: String

var cards_Discarded = []
var cards_To_Discard: int = 0

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
		c.connect("is_Discarded", self, "card_Discarded")
func cards_On_Hand():
	var hand = {}
	for card in child_Dict.keys():
		if child_Dict[card].is_Collected:
			hand[card] = child_Dict[card]
	return hand

func card_Discard(card_Name):
	var card = child_Dict[card_Name]
	card.is_Collected = false

func card_Discarded(card_Name):
	cards_Discarded.clear()
	cards_Discarded.append(card_Name)
	cards_To_Discard -= 1
	if cards_To_Discard == 0:
		for card in cards_On_Hand().values():
			card.set_status("green")
		child_Dict[last_Card_Used].set_status("white")

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
	
	# не используется
func printRoman(number):
	var res = []
	var num = [1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000]
	var sym = ["I", "IV", "V", "IX", "X", "XL", "L", "XC", "C", "CD", "D", "CM", "M"]
	var i = 12
	while number:
		var div = floor(number / num[i])
		number %= num[i]
		while div:
			res.append(sym[i])
			div -= 1
		i -= 1
