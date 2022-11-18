extends Node2D

onready var player = $"../Player"
onready var playerPos = $Malkhut

var fighting = false

var sefirahCurrent = "Malkhut"
var sefirahLast

var mouseTarget
var targetName

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

var arcanePos = {
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

func _ready():
	pass
	#print(sefirahPosition)
	
func _process(delta):
	pass

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
		if !fighting && CHANNELS.get(sefirahCurrent).has(mouseTarget):
			changePos(mouseTarget)

func changePos(pos):
	sefirahLast = sefirahCurrent
	sefirahCurrent = mouseTarget
	playerMove(pos)
	#print(sefirahLast)
	#print(sefirahCurrent)
	arcaneGet(sefirahLast, sefirahCurrent)

func playerMove(pos):
	match pos:
		"Daath":
			playerPos = $Daath
		"Kether":
			playerPos = $Kether
		"Hokmah":
			playerPos = $Hokmah
		"Binah":
			playerPos = $Binah
		"Hesed":
			playerPos = $Hesed
		"Gevurah":
			playerPos = $Gevurah
		"Tiferet":
			playerPos = $Tiferet
		"Netzah":
			playerPos = $Netzah
		"Hod":
			playerPos = $Hod
		"Yesod":
			playerPos = $Yesod
		"Malkhut":
			playerPos = $Malkhut
	player.position = playerPos.position

func arcaneGet(sefirahLast, sefirahCurrent):
	for card in arcanePos:
		if arcanePos[card].has(sefirahLast) && arcanePos[card].has(sefirahCurrent):
			arcaneActive[card] = true
			#print(card)
