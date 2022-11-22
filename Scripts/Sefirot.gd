extends Node2D

signal card_Update

onready var player = $"../Player"
onready var playerPos = $Malkhut
onready var Cards = $"../HUD/Cards"

var sefirahCurrent = "Malkhut"
var sefirahLast

var mouseTarget
var targetName

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

const CARD_POS = {
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

const CARD_DESCRIPTION = {
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

const CARD_TRANSLATION = {
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
	get_Sefirah_Position() #получает координаты сефир

func _process(_delta):
	update() #обновляет рисунок. Предполагаемая причина асинхронного ввода с мыши

func _draw(): #функция для работы с рисунками
	_draw_Channels()

func _draw_Channels(): #рисует и обновляет линии
	for channel in CARD_POS:
		if Cards.child_Dict[channel].is_Collected:
			draw_line(Sefirah_Position[CARD_POS.get(channel)[0]], 
			Sefirah_Position[CARD_POS.get(channel)[1]], Color.green, 3) 
		else:
			draw_line(Sefirah_Position[CARD_POS.get(channel)[0]], 
			Sefirah_Position[CARD_POS.get(channel)[1]], Color.red, 2)

func on_Mouse_Target(target): #вызывается из сефир. Назначает целевую сефиру
	targetName = target.get_name()
	if CHANNELS.get(sefirahCurrent).has(targetName):
		mouseTarget = targetName
		highlight(target)

func on_Mouse_Target_out(target): #вызывается из сефир. Удаляет значение целевой сефиры
	mouseTarget = null
	highlight(target, false)

func highlight(target, on = true): #подсвечивает целевую сефиру
	if on:
		target.scale = Vector2( 1.3, 1.3 )
	else:
		target.scale = Vector2.ONE

func _input(event): #перемещение на целевую сефиру по нажатию мыши
	if event is InputEventMouseButton && event.is_pressed():
		if mouseTarget:
			_changePos(mouseTarget)

func _changePos(pos): #перемещение на целевую сефиру, вызывает подбор карты 
	sefirahLast = sefirahCurrent
	sefirahCurrent = mouseTarget
	_playerMove(pos)
	_card_Get(sefirahLast, sefirahCurrent)

func _playerMove(pos):  #перемещает игрока на целевую сефиру, отнимает усердие 
	player.position = Sefirah_Position.get(pos)
	playerPos = pos
	player.health -= 1

func get_Sefirah_Position(): #получает координаты сефир
	for sefirah in get_children():
		var sefirah_Name = sefirah.get_name()
		Sefirah_Reference[sefirah_Name] = sefirah
		Sefirah_Position[sefirah_Name] = sefirah.global_position

func _card_Get(_sefirahLast, _sefirahCurrent): #добавляет полученную после перемещения карту в инвентарь
	for card in CARD_POS:
		if CARD_POS[card].has(sefirahLast) && CARD_POS[card].has(sefirahCurrent):
			emit_signal("card_Update", card)
			print(card + " collected")

func card_Effect(card_name): #разыгрывает эффект переданной карты
	Cards.last_Card_Used = card_name
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
			_effect_Card_Discard(card_name, 1, false)
			yield(Cards, "cards_Effect_Finished")
			_effect_Card_Aquire(card_name, 1, false)
		"The World":
			_effect_Sefirah_Learn()
			player.health += 1

func _effect_Card_Discard(caller, amount = 0,random = true):
	if !amount:
		for card in Cards.cards_In():
			Cards.child_Dict[card].set_status("white")
	else:
		if random:
			for card_count in amount:
				Cards.cards_In()[Cards.card_Random(Cards.cards_In())].set_status("white")
		else:
			Cards.cards_To_Discard = amount
			for card in Cards.cards_In():
				Cards.child_Dict[card].set_status("red")
			for card in Cards.cards_In(false):
				Cards.child_Dict[card].set_status("gray")
			Cards.child_Dict[caller].set_status("yellow")

func _effect_Card_Aquire(caller, amount = 0,random = true):
	if !amount:
		for card in Cards.cards_In(false):
			Cards.child_Dict[card].set_status("green")
	else:
		if random:
			for card_count in amount:
				Cards.cards_In(false)[Cards.card_Random(Cards.cards_In(false))].set_status("green")
		else:
			Cards.cards_To_Aquire = amount
			for card in Cards.cards_In(false):
				Cards.child_Dict[card].set_status("palegreen")
			for card in Cards.cards_In():
				Cards.child_Dict[card].set_status("gray")
			Cards.child_Dict[caller].set_status("yellow")

func _effect_Sefirah_Learn(): #изучает сефиру
	sefirah_Learned[sefirahCurrent] += 1
	Sefirah_Reference[sefirahCurrent].modulate = Color.white
	print(sefirahCurrent + " learned")

#component functions

