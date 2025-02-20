extends TileMapLayer

class_name MineGrid

@onready var mine_grid: TileMapLayer = $"."
@export var rows: int = 9
@export var columns: int = 9

var mine_count: int = 10
var mine_locations: Array[Vector2i] = []
var safe_cell_count: int = (rows * columns) - mine_count
var visited_cells: Array[Vector2i] = []
var flag_count: int = 0
var game_finished: bool = false
var first_click: bool = true

signal init_mine_count(mine_count)
signal game_start
signal game_lost
signal game_won
signal flag_count_change(flag_count)
signal lmouse_pressed
signal lmouse_released

# dictionary mapping cell tile types to their atlas coords in the tilemap
const CELLS = {
	"SQUARE": Vector2i(0, 0),
	"PRESSED": Vector2i(1, 0),
	"FLAG": Vector2i(2, 0),
	"QUESTION": Vector2i(3, 0),
	"QUESTION_PRESSED": Vector2i(4, 0),
	"MINE": Vector2i(5, 0),
	"MINE_PRESSED": Vector2i(6, 0),
	"MINE_CROSSED": Vector2i(7, 0),
	"1": Vector2i(0, 1),
	"2": Vector2i(1, 1),
	"3": Vector2i(2, 1),
	"4": Vector2i(3, 1),
	"5": Vector2i(4, 1),
	"6": Vector2i(5, 1),
	"7": Vector2i(6, 1),
	"8": Vector2i(7, 1),
}
const TILE_SET_ID: int = 1

# helper function to set a cell to a particular cell type
func set_tile_cell(cell_coord: Vector2i, cell_type: String) -> void:
	set_cell(cell_coord, TILE_SET_ID, CELLS[cell_type])

# helper function to get the 3x3 area around a cell, excluding any that are
# outside of the bounds of the grid and excluding the center
func get_neighbors(loc: Vector2i) -> Array[Vector2i]:
	var neighboring_cells: Array[Vector2i] = []
	for i in range(loc[0] - 1, loc[0] + 2):
		for j in range(loc[1] - 1, loc[1] + 2):
			if Vector2i(i, j) == loc:
				continue
			if i >= 0 && j >= 0 && i < rows && j < columns:
				neighboring_cells.push_back(Vector2i(i, j))

	return neighboring_cells

func _ready() -> void:
	# set all cells in grid to the non-pressed square tile
	for i in rows:
		for j in columns:
			var cell_coord = Vector2i(i, j)
			set_tile_cell(cell_coord, "SQUARE")
	init_mine_count.emit(mine_count)

func _input(event: InputEvent) -> void:
	
	if !game_finished && event is InputEventMouseButton:
		var loc = event.position
		# subtract 65 pixels to compensate for height of timer UI
		var transformed_position = Vector2i(loc[0], loc[1] - 65)
		var click_location = mine_grid.local_to_map(transformed_position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				lmouse_pressed.emit()
			else:
				lmouse_released.emit()
				handle_left_click(click_location)
				
		if event.button_index == MOUSE_BUTTON_RIGHT && \
			event.pressed && \
			!first_click:
			handle_right_click(click_location)
				
func handle_left_click(loc: Vector2i) -> void:
	# set the initial mines in the grid on the first click
	if first_click:
		game_start.emit()
		first_click = false
		set_initial_mines(loc)
	
	# if we clicked on an uncleared tile, run through our logic for clearing
	# cells, or clicking on a mine
	if mine_grid.get_cell_atlas_coords(loc) == Vector2i(0, 0):
		if mine_locations.find(loc) != -1:
			click_mine(loc)
		else:
			clear_cells(loc)
					
func handle_right_click(loc: Vector2i) -> void:
	# if right click on uncleared square, set cell to flag
	# if right click on flag, set back to uncleared square
	# otherwise do nothing
	if mine_grid.get_cell_atlas_coords(loc) == Vector2i(0, 0):
		set_tile_cell(loc, "FLAG")
		flag_count += 1
	elif mine_grid.get_cell_atlas_coords(loc) == Vector2i(2, 0):
		set_tile_cell(loc, "SQUARE")
		flag_count -= 1
	flag_count_change.emit(flag_count)

# sets the initial locations of the mines in the grid
func set_initial_mines(first_click_loc: Vector2i) -> void:
	# we don"t want to place any mines in the 3x3 area around the first click
	var neighboring_cells = get_neighbors(first_click_loc)
	while mine_locations.size() < mine_count:
		var new_mine_location = Vector2i(randi() % rows, randi() % columns)
		if neighboring_cells.find(new_mine_location) == -1 && \
			new_mine_location != first_click_loc && \
			mine_locations.find(new_mine_location) == -1:
			mine_locations.push_back(new_mine_location)
			
# clear cells, if a cell has no neighboring mines we can clear all of its
# adjacent cells as well, and continue clearing cells that way recursively
func clear_cells(loc: Vector2i) -> void:
	visited_cells.push_back(loc)
	var neighboring_mines = check_neighboring_mines(loc)
	if neighboring_mines == 0:
		set_tile_cell(loc, "PRESSED")
		var neighboring_cells = get_neighbors(loc)
		for cell in neighboring_cells:
			if visited_cells.find(cell) == -1:
				clear_cells(cell)
	else:
		set_tile_cell(loc, "%s" % neighboring_mines)

	# victory condition is when we've cleared every safe cell in the grid
	if visited_cells.size() == safe_cell_count:
		for cell in mine_locations:
			set_tile_cell(cell, "FLAG")
		game_finished = true
		game_won.emit()
		
# end the current game if a user clicks on a mine		
func click_mine(loc: Vector2i) -> void:
	set_tile_cell(loc, "MINE_PRESSED")
	for mine in mine_locations:
		if mine != loc:
			set_tile_cell(mine, "MINE")
	game_finished = true
	game_lost.emit()

# returns the amound of neighboring mines to the location clicked		
func check_neighboring_mines(loc: Vector2i) -> int:
	
	var neighboring_cells = get_neighbors(loc)
	var neighboring_mines = 0
	
	for cell in neighboring_cells:
		if mine_locations.find(cell) != -1:
			neighboring_mines += 1
			
	return neighboring_mines
