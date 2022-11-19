extends Node2D

onready var HP_Score = $"../HUD/HP/HP_Score"

var health = 5 setget health_set, health_get
var health_max = 5

func health_set(new_value):
	health = new_value
	if health > health_max:
		health = health_max
	if health <= 0:
		death()
	HP_Score.text = str(health)
	
func health_get():
	return health

func death():
	pass
