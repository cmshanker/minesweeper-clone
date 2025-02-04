extends Node

class_name GameStateManager

@onready var timer: Timer = $Timer
var time_elapsed: int = 0
var mine_grid: MineGrid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mine_grid.flag_count_change.connect(on_flag_count_change)
	mine_grid.game_won.connect(on_game_won)
	mine_grid.game_lost.connect(on_game_lost)

func on_flag_count_change(flag_count: int) -> void:
	print(flag_count)
	
func on_game_won() -> void:
	timer.stop()
	print("win")
	
func on_game_lost() -> void:
	timer.stop()
	print("lost")
