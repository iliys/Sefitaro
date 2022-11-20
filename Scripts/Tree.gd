extends Node2D

onready var player = $"../Player"
onready var playerPos = $Malkhut

var fighting = false

var sefirahCurrent = "Malkhut"
var sefirahLast

var mouseTarget
var targetName

var lines = []

var Sefirah_Position = {}

signal card_Update

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

#не используется
const CHANNELS_old = {
	"Daath": [],
	"Kether": ["Kether", "Hokmah", "Binah", "Tiferet"],
	"Hokmah": ["Kether", "Hokmah", "Binah", "Hesed", "Tiferet"],
	"Binah": ["Kether", "Hokmah", "Binah", "Gevurah", "Tiferet"],
	"Hesed": ["Hokmah", "Hesed", "Gevurah", "Tiferet", "Netzah"],
	"Gevurah": ["Binah", "Hesed", "Gevurah", "Tiferet", "Hod"],
	"Tiferet": ["Kether", "Hokmah", "Binah", "Hesed", "Gevurah", "Tiferet", "Netzah", "Hod", "Yesod"],
	"Netzah": ["Hesed", "Tiferet", "Netzah", "Hod", "Yesod", "Malkhut"],
	"Hod": ["Gevurah", "Tiferet", "Netzah", "Hod", "Yesod", "Malkhut"],
	"Yesod": ["Tiferet", "Netzah", "Hod", "Yesod", "Malkhut"],
	"Malkhut": ["Netzah", "Hod", "Yesod", "Malkhut"]
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
		target.scale = Vector2( 1.3, 1.3 )

func on_Mouse_Target_out(target):
	mouseTarget = null
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
		Sefirah_Position[sefirah.get_name()] = sefirah.global_position

func arcaneGet(sefirahLast, sefirahCurrent):
	for card in ARCANE_POS:
		if ARCANE_POS[card].has(sefirahLast) && ARCANE_POS[card].has(sefirahCurrent):
			arcaneActive[card] = true
			emit_signal("card_Update", arcaneActive[card], card)
			print(card)

func _draw():
	draw_Channels()

func draw_Channels():
	for channel in ARCANE_POS:
		if arcaneActive.get(channel):
			draw_line(Sefirah_Position[ARCANE_POS.get(channel)[0]], 
			Sefirah_Position[ARCANE_POS.get(channel)[1]], Color.green, 3) 
		else:
			draw_line(Sefirah_Position[ARCANE_POS.get(channel)[0]], 
			Sefirah_Position[ARCANE_POS.get(channel)[1]], Color.red, 2)
