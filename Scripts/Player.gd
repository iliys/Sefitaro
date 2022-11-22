extends Node2D

onready var HP_Score = $"../HUD/HP/HP_Score"

var health = 10 setget health_set, health_get
var health_max = 10

func health_set(new_value): #установка здоровья
	health = new_value
	if health > health_max:
		health = health_max
	if health < 0:
		death()
	HP_Score.text = str(health)
	
func health_get(): #получение здоровья
	return health

func death(): #перезапуск игры
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
