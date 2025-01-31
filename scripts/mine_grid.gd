extends TileMapLayer

@export var rows = 9
@export var columns = 9
@export var mine_count = 10
@export var mine_locations = []

@onready var mine_grid: TileMapLayer = $"."
@onready var first_click: bool = true

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

# helper function to set a cell to a particular cell type
func set_tile_cell(cell_coord: Vector2i, cell_type: String):
	set_cell(cell_coord, TILE_SET_ID, CELLS[cell_type])

# helper function to get the 3x3 area around a cell, excluding any that are
# outside of the bounds of the grid
func get_neighbors(loc: Vector2i) -> Array[Vector2i]:

	var neighboring_cells: Array[Vector2i] = []
	for i in range(loc[0] - 1, loc[0] + 2):
		for j in range(loc[1] - 1, loc[1] + 2):
			if i >= 0 && j >= 0 && i < rows && j < columns:
				neighboring_cells.push_back(Vector2i(i, j))

	return neighboring_cells

func _ready():
	# set all cells in grid to the non-pressed square tile
	for i in rows:
		for j in columns:
			var cell_coord = Vector2i(i, j)
			set_tile_cell(cell_coord, 'SQUARE')

func _input(event: InputEvent):
	
	if event is InputEventMouseButton:
		var click_location = mine_grid.local_to_map(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			handle_left_click(click_location)
				
		if event.button_index == MOUSE_BUTTON_RIGHT && \
			event.pressed && \
			!first_click:
			handle_right_click(click_location)
				
func handle_left_click(loc: Vector2i) -> void:
	# set the initial mines in the grid on the first click
	if first_click:
		first_click = false
		set_initial_mines(loc)
		var neighboring_cells = get_neighbors(loc)
		for cell in neighboring_cells:
			var neighboring_mines = check_neighboring_mines(cell)
			match neighboring_mines:
				0:
					set_tile_cell(cell, 'PRESSED')
				_:
					set_tile_cell(cell, '%s' % neighboring_mines)
					
func handle_right_click(loc: Vector2i) -> void:
	print(loc)

# sets the initial locations of the mines in the grid
func set_initial_mines(first_click_loc: Vector2i):
	# we don't want to place any mines in the 3x3 area around the first click
	var neighboring_cells = get_neighbors(first_click_loc)
	while mine_locations.size() < mine_count:
		var new_mine_location = Vector2i(randi() % rows, randi() % columns)
		if neighboring_cells.find(new_mine_location) == -1 && \
			mine_locations.find(new_mine_location) == -1:
			mine_locations.push_back(new_mine_location)

# returns the amound of neighboring mines to the location clicked		
func check_neighboring_mines(loc: Vector2i) -> int:
	
	var neighboring_cells = get_neighbors(loc)
	var neighboring_mines = 0
	
	for cell in neighboring_cells:
		if mine_locations.find(cell) != -1:
			neighboring_mines = neighboring_mines + 1
			
	return neighboring_mines
