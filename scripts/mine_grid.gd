extends TileMapLayer

@export var columns = 9
@export var rows = 9
@export var mine_count = 10
@export var mine_locations = []

@onready var mine_grid: TileMapLayer = $"."

const CELLS = {
	'SQUARE': Vector2i(0, 0),
	'PRESSED': Vector2i(1, 0),
	'FLAG': Vector2i(2, 0),
	'QUESTION': Vector2i(3, 0),
	'QUESTION_PRESSED': Vector2i(4, 0),
	'MINE': Vector2i(5, 0),
	'MINE_PRESSED': Vector2i(6, 0),
	'MINE_CROSSED': Vector2i(7, 0),
	'1': Vector2i(0, 1),
	'2': Vector2i(1, 1),
	'3': Vector2i(2, 1),
	'4': Vector2i(3, 1),
	'5': Vector2i(4, 1),
	'6': Vector2i(5, 1),
	'7': Vector2i(6, 1),
	'8': Vector2i(7, 1),
}
const TILE_SET_ID = 1

func _ready():
	# set the initial mines in the grid
	set_initial_mines()
	# set all cells in grid to the non-pressed square tile
	for i in rows:
		for j in columns:
			var cell_coord = Vector2i(i, j)
			set_tile_cell(cell_coord, 'SQUARE')
			
func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Left button was clicked at ", event.position)
			print("Cell position click is ", mine_grid.local_to_map(event.position))

			
func set_tile_cell(cell_coord: Vector2i, cell_type: String):
	set_cell(cell_coord, TILE_SET_ID, CELLS[cell_type])
	
func set_initial_mines():
	while mine_locations.size() < mine_count:
		var new_mine_location = Vector2i(randi() % rows, randi() % columns)
		if mine_locations.find(new_mine_location) == -1:
			mine_locations.push_back(new_mine_location)
			
func check_neighboring_mines(loc: Vector2i) -> int:
	var neighbors = 0
	for i in range(loc[0] - 1, loc[0] + 2):
		if i < 0 || i >= rows:
			continue
		for j in range(loc[1] - 1, loc[1] + 2):
			if j < 0 || j >= columns || (i == loc[0] && j == loc[1]):
				continue
			if mine_locations.find(Vector2i(i, j)) != -1:
				neighbors = neighbors + 1
			
	return neighbors
	
