extends Label

onready var Sefirot = $"../../../Sefirot"

var active: bool = false

var pos: Array = []

var description: String

func _ready():
	pass
		

func _on_Arcane_mouse_entered():
	if Sefirot.arcaneActive[name]:
		rect_scale = Vector2(1.5, 1.5)


func _on_Arcane_mouse_exited():
	rect_scale = Vector2(1, 1)

func cc():
	self.add_color_override("font_color", Color(0,1,0,1))
