extends Label

#signal use_Card

onready var Sefirot = $"../../../Sefirot"

var  is_Collected: bool = false

var is_Discarding: bool = false
#signal is_Discarded

var pos = []

var description: String

func _ready():
	Sefirot.connect("card_Update", self, "card_update")

func _on_Arcane_mouse_entered():
	if Sefirot.arcaneActive[name]:
		highlight()

func _on_Arcane_mouse_exited():
	highlight(false)
	
func highlight(on = true):
	if on:
		rect_scale = Vector2(1.5, 1.5)
	else:
		rect_scale = Vector2(1, 1)

func card_update(card_Status, card):
	if name == card:
		if card_Status:
			color(Color.green)
		is_Collected = card_Status

func set_status(color):
	match color:
		"green":
			Color.green
			self.add_color_override("font_color", green)
		"yellow":
			Color.yellow
		"red":
			Color.red
	

func _on_Card_Instance_gui_input(event):
	if event is InputEventMouseButton && event.is_pressed():
		if is_Collected:
			if is_Discarding:
				is_Collected = false
			else:
				print(name + " used")
				effect(name)

func effect(arcane_Name):
	#emit_signal("use_Card", arcane_Name)
	Sefirot.card_Effect(arcane_Name)
	is_Collected = false
