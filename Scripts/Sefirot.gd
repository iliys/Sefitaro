extends Node2D

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
		if Cards.cards[channel].is_Collected:
			draw_line(Sefirah_Position[CARD_POS.get(channel)[0]], 
			Sefirah_Position[CARD_POS.get(channel)[1]], Color.green, 3) 
		else:
			draw_line(Sefirah_Position[CARD_POS.get(channel)[0]], 
			Sefirah_Position[CARD_POS.get(channel)[1]], Color.red, 2)

func on_Mouse_Target(target): #вызывается из сефир. Назначает целевую сефиру
	if Cards.counter == 0:
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

func _card_Get(_sefirahLast, _sefirahCurrent): #добавляет полученную после перемещения карту в инвентарь
	for card in CARD_POS:
		if CARD_POS[card].has(sefirahLast) && CARD_POS[card].has(sefirahCurrent):
			Cards.cards[card].collect()

func _playerMove(pos):  #перемещает игрока на целевую сефиру, отнимает усердие 
	player.position = Sefirah_Position.get(pos)
	playerPos = pos
	player.health -= 1

func get_Sefirah_Position(): #получает координаты сефир
	for sefirah in get_children():
		var sefirah_Name = sefirah.get_name()
		Sefirah_Reference[sefirah_Name] = sefirah
		Sefirah_Position[sefirah_Name] = sefirah.global_position

func sefirah_Learn(_sefirah): #изучает переданную сефиру. Вызывается из Cards
	sefirah_Learned[_sefirah] += 1
	Sefirah_Reference[_sefirah].modulate = Color.white
	print(_sefirah + " learned")
