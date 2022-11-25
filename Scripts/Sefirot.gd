extends Node2D

signal effect_Continue

onready var Player = $"../Player"
onready var playerPos = $Malkhut
onready var Cards = $"../HUD/Cards"

var sefirah_Current = "Malkhut"
var sefirah_Last
var sefirah_Temp

var mouseTarget
var targetName

var channel_Highlight
var channel_Highlight_1
var channel_Highlight_2

var free_Moves = 0

var Sefirah_Reference = {}

var Sefirah_Position = {}


func _ready():
	connect("effect_Continue", Cards, "_effect_Continue")
	_get_Sefirah_Position() #получает координаты сефир

func _process(_delta):
	update() #обновляет рисунок. Предполагаемая причина багов при быстром нажатии клавиш

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
		if channel_Highlight:
			draw_line(Sefirah_Position[channel_Highlight_1], 
			Sefirah_Position[channel_Highlight_2], Color.violet, 3)

func on_Mouse_Target(target): #вызывается из сефир. Назначает целевую сефиру
	if Cards.counter == 0:
		targetName = target.get_name()
		if CHANNELS.get(sefirah_Current).has(targetName):
			channel_Highlight = true
			channel_Highlight_1 = sefirah_Current
			channel_Highlight_2 = targetName
			mouseTarget = targetName
			highlight(target)
	if free_Moves > 0:
		mouseTarget = target.get_name()
	for card in CARD_POS:
		if CARD_POS[card].has(mouseTarget) && CARD_POS[card].has(sefirah_Current):
			Cards.cards[card].highlight() 

func on_Mouse_Target_out(target): #вызывается из сефир. Удаляет значение целевой сефиры
	channel_Highlight = false
	for card in CARD_POS:
		if CARD_POS[card].has(mouseTarget) && CARD_POS[card].has(sefirah_Current):
			Cards.cards[card].highlight(false)
	if free_Moves > 0:
		return
	mouseTarget = null
	highlight(target, false)
func highlight(target, on = true): #подсвечивает целевую сефиру
	if on:
		target.get_child(2).modulate = Color.violet
		target.scale = Vector2( 1.3, 1.3 )
	else:
		target.scale = Vector2.ONE
		if sefirah_Learned[target.name]:
			target.get_child(2).modulate = Color.green
		else: target.get_child(2).modulate = Color.darkgray

func _input(event): #перемещение на целевую сефиру по нажатию мыши
	if event is InputEventMouseButton && event.is_pressed():
		if mouseTarget:
			changePos(mouseTarget)
			if free_Moves > 0:
				free_Moves -= 1
				emit_signal("effect_Continue")

func changePos(pos, pick_Up_Cards = true, decrease_Health = true): #перемещение на целевую сефиру, вызывает подбор карты 
	sefirah_Last = sefirah_Current
	sefirah_Current = pos
	_playerMove(pos, decrease_Health)
	if pick_Up_Cards:
		_card_Get(sefirah_Last, sefirah_Current)

func _card_Get(sefirah_Last, sefirah_Current): #добавляет полученную после перемещения карту в инвентарь
	for card in CARD_POS:
		if CARD_POS[card].has(sefirah_Last) && CARD_POS[card].has(sefirah_Current):
			Cards.cards[card].collect()

func _playerMove(pos, decrease_Health = true):  #перемещает игрока на целевую сефиру, отнимает усердие 
	Player.position = Sefirah_Position.get(pos)
	playerPos = pos
	if decrease_Health:
		Player.health -= 1

func _get_Sefirah_Position(): #получает координаты сефир
	for sefirah in get_children():
		var sefirah_Name = sefirah.get_name()
		Sefirah_Reference[sefirah_Name] = sefirah
		Sefirah_Position[sefirah_Name] = sefirah.global_position

func sefirah_Learn(_sefirah, amount): #изучает переданную сефиру. Вызывается из Cards
	sefirah_Learned[_sefirah] = amount
	if amount:
		Sefirah_Reference[_sefirah].get_child(2).modulate = Color.green
		print(_sefirah + " learned")
	elif !amount:
		Sefirah_Reference[_sefirah].get_child(2).modulate = Color.darkgray
		print(_sefirah + " forgotten")

var sefirah_Learned = {
	#"Daath": 0,
	"Kether": false,
	"Hokmah": false,
	"Binah": false,
	"Hesed": false,
	"Gevurah": false,
	"Tiferet": false,
	"Netzah": false,
	"Hod": false,
	"Yesod": false,
	"Malkhut": false
	}

const CHANNELS = {
	#"Daath": [],
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
	"The Fool": "Изучает сефиру. Перемещает в Малькут и забывает его",
	"The Magician": "Даёт любую карту на выбор",
	"The High Priestess": "Восстанавливает всё усердие",
	"The Empress": "Даёт любую карту на выбор",
	"The Emperor": "Перемещает в выбранную сефиру, восстанавливает 1 усердие",
	"The Hierophant": "Изучает сефиру",
	"The Lovers": "Сбрасывает выбранную карту. Даёт любую карту на выбор",
	"The Chariot": "Перемещает в соседнюю сефиру и изучает её",
	"Strength": "Восстанавливает одно усердие, изучает сефиру",
	"The Hermit": "Забывает сефиру, даёт любую карту на выбор",
	"Wheel of Fortune": "Даёт случайную карту",
	"Justice": "Копирует статус предыдущей сефиры",
	"The Hanged Man": "Перемещает на предыдущую сефиру",
	"Death": "Сбрасывает все карты и перемещает в Малькут, восстанавливает одно усердие",
	"Temperance": "Сбрасывает выбранную карту. Изучает сефиру",
	"The Devil": "Перемещает в случайную сефиру",
	"The Tower": "Сбрасывает все карты, даёт любую карту на выбор",
	"The Star": "Перемещает игрока в выбранную сефиру",
	"The Moon": "Перемещает игрока в случайную сефиру",
	"The Sun": "Восстанавливает одно усердие",
	"Judgement": "Сбрасывает выбранную карту, даёт любую карту на выбор",
	"The World": "Возвращает в Малькут и изучает его"
	}

const CARD_TRANSLATION = {
	"The Fool": "Шут",
	"The Magician": "Маг",
	"The High Priestess": "Верховная жрица",
	"The Empress": "Императрица",
	"The Emperor": "Император",
	"The Hierophant": "Иерофант",
	"The Lovers": "Влюбленные",
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
