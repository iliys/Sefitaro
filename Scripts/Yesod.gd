extends Area2D

func _ready():
	pass

func _on_Yesod_mouse_entered():
	$"..".on_Mouse_Target($".")

func _on_Yesod_mouse_exited():
	$"..".on_Mouse_Target_out($".")
