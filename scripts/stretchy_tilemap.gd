extends Node2D

@export var main_tilemap: TileMap
@export var stretch_center: Node2D

var tileset: TileSet

# Tilemap left of the stretching
@onready var left_tilemap: TileMap = $LeftTileMap
# Tilemap right of the stretching
@onready var right_tilemap: TileMap = $RightTileMap
# The stretched tilemap: if no stretch is applied, this is the main one
@onready var middle_tilemap: TileMap = $MiddleTileMap

var tile_coords: Array[Vector2i]
var tiles_atlas: Array[Vector2i]

class Stretch:
	var size: int
	var pos: int
	var scale: float

var x_stretch: Stretch

var x_scale: float = 0
var increase_scale: bool = false
var decrease_scale: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	tileset = main_tilemap.get_tileset()
	tile_coords = main_tilemap.get_used_cells(0)
	tiles_atlas.assign(tile_coords.map(get_atlas_coord))
	
	left_tilemap.set_tileset(tileset)
	right_tilemap.set_tileset(tileset)
	middle_tilemap.set_tileset(tileset)
	
	main_tilemap.visible = false

	x_stretch  = Stretch.new()
	x_stretch.size = 3
	x_stretch.pos = 6
	x_stretch.scale = 1

func get_atlas_coord(coord) -> Vector2i:
	return main_tilemap.get_cell_atlas_coords(0, coord)

func _input(event):
	increase_scale = Input.is_key_pressed(KEY_A) 
	decrease_scale = Input.is_key_pressed(KEY_S)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	x_scale += (increase_scale as int - (decrease_scale as int)) * delta
	x_stretch.scale = compute_scale(x_scale)
	
	reset_tilemaps()
	draw_tilemaps()
	set_offsets_and_scale()

func compute_scale(scale) -> float:
	if scale == 0:
		return 1
	
	if scale > 0:
		return scale + 1
	
	return 1 / (1 - scale)

# Clears all tilemaps
func reset_tilemaps():
	for coord in tile_coords:
		left_tilemap.erase_cell(0, coord)
		right_tilemap.erase_cell(0, coord)
		middle_tilemap.erase_cell(0, coord)

func draw_tilemaps():
	var int_beg = x_stretch.pos - x_stretch.size
	var int_end = x_stretch.pos + x_stretch.size
	
	for i in tile_coords.size():
		var coord = tile_coords[i]
		var atlas = tiles_atlas[i]
		
		if coord.x < int_beg:
			left_tilemap.set_cell(0, coord, 1, atlas)
		elif coord.x > int_end:
			right_tilemap.set_cell(0, coord, 1, atlas)
		else:
			middle_tilemap.set_cell(0, coord, 1, atlas)
		

func set_offsets_and_scale():
	middle_tilemap.scale.x = x_stretch.scale
	middle_tilemap.position.x = 16 * (x_stretch.scale - 1) * -x_stretch.size 
	right_tilemap.position.x = 16 * (x_stretch.scale - 1) * (x_stretch.size * 2 + 1)
