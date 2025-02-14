extends CanvasLayer

class_name UI

@onready var mine_count_label: Label = %MineCountLabel
@onready var timer_label: Label = %TimerLabel
@onready var status_button: TextureButton = %StatusButton
var won_button = preload("res://assets/sprites/smile_won.png")
var lost_button = preload("res://assets/sprites/smile_lost.png")
var normal_button = preload("res://assets/sprites/smile.png")
var surprised_button = preload("res://assets/sprites/smile_surprised.png")

func handle_mine_count_change(mines: int) -> void:
	var mines_str = str(mines)
	if mines_str.length() < 3:
		mines_str = mines_str.lpad(3, "0")
	elif mines_str.length() > 3:
		if mines < 0:
			mines_str = "-99"
		else:
			mines_str = "999"
	mine_count_label.text = mines_str
	
func handle_timer_change(time_elapsed: int) -> void:
	var time_str = str(time_elapsed)
	if time_str.length() < 3:
		time_str = time_str.lpad(3, "0")
	elif time_str.length > 3:
		time_str = "999"
	timer_label.text = time_str

func game_won() -> void:
	status_button.texture_normal = won_button
	
func game_lost() -> void:
	status_button.texture_normal = lost_button
	
func on_lmouse_pressed() -> void:
	status_button.texture_normal = surprised_button
	
func on_lmouse_released() -> void:
	status_button.texture_normal = normal_button

func _on_status_button_pressed() -> void:
	get_tree().reload_current_scene()
