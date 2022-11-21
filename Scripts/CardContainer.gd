extends VBoxContainer

onready var Sefirot = $"../../Sefirot"

onready var card_instance = preload("res://Card_Instance.tscn")

# не используется
var child_Ref = []

var child_Dict = {}

# не используется
var number = 0

func _ready():
	#Sefirot.connect("card_Update", self, "card_update")
	for card in (Sefirot.arcaneActive.keys()):
		var s = card_instance.instance()
		s.name = card
		s.text = Sefirot.ARCANETRANSLATION[card]
		s.hint_tooltip = Sefirot.ARCANEDESCRIPTION[card]
		#print(s.hint_tooltip)
		#print(s.name)
		child_Dict[card] = s
		add_child(s)
		number +=1
		child_Ref.append(s)
	#print(child_Dict)
	#print(child_Ref[0])
	#print(get_child_count())
	#print(card_Random())
func cards_On_Hand():
	var hand = {}
	for card in child_Dict.keys():
		if child_Dict[card].is_Collected:
			hand[card] = child_Dict[card]
	return hand

func card_Discard(card_Name):
	var card = child_Dict[card_Name]
	card.is_Collected = false

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
