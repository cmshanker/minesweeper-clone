extends Node

class_name GameStateManager

@export var mine_grid: MineGrid
@export var ui: UI

@onready var timer: Timer = $Timer
var time_elapsed: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mine_grid.game_start.connect(on_game_start)
	mine_grid.game_won.connect(on_game_won)
	mine_grid.game_lost.connect(on_game_lost)
	mine_grid.flag_count_change.connect(on_flag_count_change)
	
	ui.handle_mine_count_change(mine_grid.mine_count)
	
func on_game_start() -> void:
	timer.start()
	time_elapsed = 1
	ui.handle_timer_change(time_elapsed)
	
func on_game_won() -> void:
	timer.stop()
	ui.game_won()
	
func on_game_lost() -> void:
	timer.stop()
	ui.game_lost()

func on_flag_count_change(flag_count: int) -> void:
	ui.handle_mine_count_change(mine_grid.mine_count - flag_count)

func _on_timer_timeout() -> void:
	time_elapsed += 1
	ui.handle_timer_change(time_elapsed)
