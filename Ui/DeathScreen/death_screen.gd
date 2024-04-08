extends Control



func _ready():
	GameManager.player_died.connect(display_screen)


func _on_reset_button_pressed():
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed():
	print("powrot do menu")

func display_screen():
	visible = true
