extends VBoxContainer

onready var Sefirot = $"../../Sefirot"

onready var card_instance = preload("res://Card_Instance.tscn")

var child_Ref = []

var child_Dict = {}

# не используется
var number = 0

func _ready():
	#Sefirot.connect("card_Update", self, "card_update")
	for arcane in (Sefirot.arcaneActive.keys()):
		var s = card_instance.instance()
		s.name = arcane
		s.text = Sefirot.ARCANETRANSLATION[arcane]
		s.hint_tooltip = Sefirot.ARCANEDESCRIPTION[arcane]
		#print(s.hint_tooltip)
		#print(s.name)
		child_Dict[arcane] = s
		add_child(s)
		number +=1
		child_Ref.append(s)
	#print(child_Dict)
	#print(get_child_count())

func card_Discard(card_Name):
	var card = child_Dict[card_Name]
	card.is_Collected = false

func card_Highlight(exception = null):
	for card in child_Ref:
				if card.is_Collected:
					card.color(Color.red)
					if card.get_name() == exception:
						card.color(Color.yellow)

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
