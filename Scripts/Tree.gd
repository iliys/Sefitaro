extends Node2D

signal card_Update

onready var player = $"../Player"
onready var playerPos = $Malkhut
onready var Cards = $"../HUD/CardContainer"

var fighting = false

var sefirahCurrent = "Malkhut"
var sefirahLast

var mouseTarget
var targetName

var lines = []

var Sefirah_Reference = {}

var Sefirah_Position = {}

var sefirah_Learned = {
	"Daath": 0,
	"Kether": 0,
	"Hokmah": 0,
	"Binah": 0,
	"Hesed": 0,
	"Gevurah": 0,
	"Tiferet": 0,
	"Netzah": 0,
	"Hod": 0,
	"Yesod": 0,
	"Malkhut": 0
	}

const CHANNELS = {
	"Daath": [],
	"Kether": ["Hokmah", "Binah", "Tiferet"],
	"Hokmah": ["Kether", "Binah", "Hesed", "Tiferet"],
	"Binah": ["Kether", "Hokmah", "Gevurah", "Tiferet"],
	"Hesed": ["Hokmah", "Gevurah", "Tiferet", "Netzah"],
	"Gevurah": ["Binah", "Hesed", "Tiferet", "Hod"],
	"Tiferet": ["Kether", "Hokmah", "Binah", "Hesed", "Gevurah", "Netzah", "Hod", "Yesod"],
	"Netzah": ["Hesed", "Tiferet", "Hod", "Yesod", "Malkhut"],
	"Hod": ["Gevurah", "Tiferet", "Netzah", "Yesod", "Malkhut"],
	"Yesod": ["Tiferet", "Netzah", "Hod", "Malkhut"],
	"Malkhut": ["Netzah", "Hod", "Yesod"]
	}

const ARCANE_POS = {
	"The Fool": ["Kether", "Hokmah"],
	"The Magician": ["Kether", "Binah"],
	"The High Priestess": ["Kether", "Tiferet"],
	"The Empress": ["Hokmah", "Binah"],
	"The Emperor": ["Hokmah", "Tiferet"],
	"The Hierophant":  ["Hokmah", "Hesed"],
	"The Lovers": ["Binah", "Tiferet"],
	"The Chariot": ["Binah", "Gevurah"],
	"Strength": ["Hesed", "Gevurah"],
	"The Hermit": ["Hesed", "Tiferet"],
	"Wheel of Fortune": ["Hesed", "Netzah"],
	"Justice": ["Gevurah", "Tiferet"],
	"The Hanged Man": ["Gevurah", "Hod"],
	"Death": ["Tiferet", "Netzah"],
	"Temperance": ["Tiferet", "Yesod"],
	"The Devil": ["Tiferet", "Hod"],
	"The Tower": ["Netzah", "Hod"],
	"The Star": ["Netzah", "Yesod"],
	"The Moon": ["Netzah", "Malkhut"],
	"The Sun": ["Hod", "Yesod"],
	"Judgement": ["Hod", "Malkhut"],
	"The World": ["Yesod", "Malkhut"]
	}

var arcaneActive = {
	"The Fool": false,
	"The Magician": false,
	"The High Priestess": false,
	"The Empress": false,
	"The Emperor": false,
	"The Hierophant": false,
	"The Lovers": false,
	"The Chariot": false,
	"Strength": false,
	"The Hermit": false,
	"Wheel of Fortune": false,
	"Justice": false,
	"The Hanged Man": false,
	"Death": false,
	"Temperance": false,
	"The Devil": false,
	"The Tower": false,
	"The Star": false,
	"The Moon": false,
	"The Sun": false,
	"Judgement": false,
	"The World": false
	}

const ARCANEDESCRIPTION = {
	"The Fool": "Перемещает в Малькут и изучает его",
	"The Magician": "Дает любую карту, изучает примыкающие к ней сефирот",
	"The High Priestess": "Восстанавливает 2 силы. Даёт случайную карту из трех",
	"The Empress": "Восстанавливает 4 силы, даёт случайную карту за восстановленную сверх предела силу",
	"The Emperor": "Перемещает в выбранную сефиру и изучает её",
	"The Hierophant": "Восстанавливает силу, изучает сефиру",
	"The Lovers": "Изучает последнюю сефиру. забывает текущую",
	"The Chariot": "Перемещает в следующую сефиру, изучает её",
	"Strength": "Восстанавливает силу, изучает сефиру",
	"The Hermit": "Изучает сефиру, активирует ближайшую аркану",
	"Wheel of Fortune": "Даёт случайную карту",
	"Justice": "Уравнивает уровни прошлой и текущей сефир",
	"The Hanged Man": "Перемещает на предыдущую сефиру",
	"Death": "Сбрасывает все карты, перемещает в Малькут, восстанавливает силы",
	"Temperance": "Уравнивает уровни между текущей и последней сефирой",
	"The Devil": "Перемещает в случайную сефиру, изучает её",
	"The Tower": "Сбрасывает все карты",
	"The Star": "Перемещает игрока в выбранную сефиру",
	"The Moon": "Перемещает игрока в случайную сефиру",
	"The Sun": "Восстанавливает все силы",
	"Judgement": "Сбрасывает выбранную карту, даёт случайную карту из трех",
	"The World": "Изучает сефиру N раз, где N - число карт на руке, которые пропадают. Восстанавливает все силы"
	}

const ARCANETRANSLATION = {
	"The Fool": "Дур",
	"The Magician": "Маг",
	"The High Priestess": "Жрица",
	"The Empress": "Императрица",
	"The Emperor": "Император",
	"The Hierophant": "Папа",
	"The Lovers": "Любовники",
	"The Chariot": "Колесница",
	"Strength": "Сила",
	"The Hermit": "Отшельник",
	"Wheel of Fortune": "Kолeco Фopтуны",
	"Justice": "Cпpaвeдливocть",
	"The Hanged Man": "Повешенный",
	"Death": "Смерть",
	"Temperance": "Умepeннocть",
	"The Devil": "Дьявoл",
	"The Tower": "Бaшня",
	"The Star": "Звeздa",
	"The Moon": "Лунa",
	"The Sun": "Coлнцe",
	"Judgement": "Cуд",
	"The World": "Мир"
	}

func _ready():
	get_Sefirah_Position()
	#print(Sefirah_Position)

func _process(delta):
	update()

#вызывается из сефир
func on_Mouse_Target(target):
	targetName = target.get_name()
	if CHANNELS.get(sefirahCurrent).has(targetName):
		mouseTarget = targetName
		highlight(target)

func on_Mouse_Target_out(target):
	mouseTarget = null
	highlight(target, false)

func highlight(target, on = true):
	if on:
		target.scale = Vector2( 1.3, 1.3 )
	else:
		target.scale = Vector2( 1, 1 )

func _input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if !fighting && mouseTarget:
			changePos(mouseTarget)

func changePos(pos):
	sefirahLast = sefirahCurrent
	sefirahCurrent = mouseTarget
	playerMove(pos)
	arcaneGet(sefirahLast, sefirahCurrent)
	#print(sefirahLast)
	#print(sefirahCurrent)

func playerMove(pos):
	player.position = Sefirah_Position.get(pos)
	playerPos = pos
	player.health -= 1

func get_Sefirah_Position():
	for sefirah in get_children():
		var sefirah_Name = sefirah.get_name()
		Sefirah_Reference[sefirah_Name] = sefirah
		Sefirah_Position[sefirah_Name] = sefirah.global_position

func arcaneGet(sefirahLast, sefirahCurrent): #получаем карту в инвентарь
	for card in ARCANE_POS:
		if ARCANE_POS[card].has(sefirahLast) && ARCANE_POS[card].has(sefirahCurrent):
			#arcaneActive[card] = true
			#принимает - Arcane (карты)
			emit_signal("card_Update", card)
			print(card + " collected")

func _draw():
	draw_Channels()

func draw_Channels():
	for channel in ARCANE_POS:
		if Cards.child_Dict[channel].is_Collected:
			draw_line(Sefirah_Position[ARCANE_POS.get(channel)[0]], 
			Sefirah_Position[ARCANE_POS.get(channel)[1]], Color.green, 3) 
		else:
			draw_line(Sefirah_Position[ARCANE_POS.get(channel)[0]], 
			Sefirah_Position[ARCANE_POS.get(channel)[1]], Color.red, 2)

# действия карт
func card_Effect(card_name):
	match card_name:
		"The Fool":
			Cards.child_Dict[card_name].set_status("white")
		"The Magician":
			Cards.child_Dict[card_name].set_status("white")
		"The High Priestess":
			Cards.child_Dict[card_name].set_status("white")
		"The Empress":
			Cards.child_Dict[card_name].set_status("white")
		"The Emperor":
			Cards.child_Dict[card_name].set_status("white")
		"The Hierophant":
			Cards.child_Dict[card_name].set_status("white")
		"The Lovers":
			Cards.child_Dict[card_name].set_status("white")
		"The Chariot":
			Cards.child_Dict[card_name].set_status("white")
		"Strength":
			Cards.child_Dict[card_name].set_status("white")
		"The Hermit":
			Cards.child_Dict[card_name].set_status("white")
		"Wheel of Fortune":
			Cards.child_Dict[card_name].set_status("white")
		"Justice":
			Cards.child_Dict[card_name].set_status("white")
		"The Hanged Man":
			Cards.child_Dict[card_name].set_status("white")
		"Death":
			Cards.child_Dict[card_name].set_status("white")
		"Temperance":
			Cards.child_Dict[card_name].set_status("white")
		"The Devil":
			Cards.child_Dict[card_name].set_status("white")
		"The Tower":
			Cards.child_Dict[card_name].set_status("white")
		"The Star":
			Cards.child_Dict[card_name].set_status("white")
		"The Moon":
			Cards.child_Dict[card_name].set_status("white")
		"The Sun":
			pass
		"Judgement":
			effect_Card_Discard(card_name, 2)
			#Cards.card_Highlight(card_name)
		"The World":
			effect_Sefirah_Learn(sefirahCurrent)
			player.health += 1
			#Cards.child_Dict[card_name].set_status("white")
			
			
			

func effect_Card_Discard(caller, amount = 0,random = true):
	if !amount:
		for card in Cards.cards_On_Hand():
			Cards.child_Dict[card].set_status("white")
	else:
		if random:
			for card_count in amount:
				#for card in Cards.cards_On_Hand():
				Cards.cards_On_Hand()[Cards.card_Random(Cards.cards_On_Hand())].set_status("white")
					#print(Cards.card_Random(Cards.child_Dict))

func effect_Sefirah_Learn(sefirah):
	sefirah_Learned[sefirahCurrent] += 1
	Sefirah_Reference[sefirahCurrent].modulate = Color.white
	print(sefirahCurrent + " learned")
