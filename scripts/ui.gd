extends CanvasLayer

@onready var mine_count_label: Label = %MineCountLabel
@onready var timer_label: Label = %TimerLabel
var game_state_manager: GameStateManager
var mine_grid: MineGrid
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
