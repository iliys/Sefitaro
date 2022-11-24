extends Node2D

onready var HP_Score = $"../HUD/HP/HP_Score"

var health = 3 setget _health_set, _health_get
var health_max = 3

func _health_set(new_value): #установка здоровья
	health = new_value 
	if health > health_max:
		health = health_max
	if health < 0:
		_death()
	HP_Score.text = str(health)
	
func _health_get(): #получение здоровья
	return health

func _death(): #перезапуск игры
	get_tree().reload_current_scene()
