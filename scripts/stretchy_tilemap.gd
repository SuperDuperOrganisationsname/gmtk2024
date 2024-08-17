extends Node2D

const TILE_SIZE: int = 16
const STRETCH_SPEED: float = 3.0

@export var main_tilemap: TileMapLayer
@export var stretch_center: Node2D

var tileset: TileSet

# Tilemap left of the stretching
@onready var left_tilemap: TileMapLayer = $LeftTileMap
# Tilemap right of the stretching
@onready var right_tilemap: TileMapLayer = $RightTileMap
# The stretched tilemap: if no stretch is applied, this is the main one
@onready var middle_tilemap: TileMapLayer = $MiddleTileMap

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
	tileset = main_tilemap.get_tile_set()
	tile_coords = main_tilemap.get_used_cells()
	tiles_atlas.assign(tile_coords.map(get_atlas_coord))
	
	left_tilemap.set_tile_set(tileset)
	right_tilemap.set_tile_set(tileset)
	middle_tilemap.set_tile_set(tileset)
	
	main_tilemap.enabled = false

	x_stretch  = Stretch.new()
	x_stretch.size = 3
	x_stretch.pos = 10
	x_stretch.scale = 1
	

func get_atlas_coord(coord) -> Vector2i:
	return main_tilemap.get_cell_atlas_coords(coord)

func _input(event):
	increase_scale = Input.is_action_pressed("strech") 
	decrease_scale = Input.is_action_pressed("shrink")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	x_scale += (increase_scale as int - (decrease_scale as int)) * delta * STRETCH_SPEED
	if x_scale < 0:
		x_scale = 0
	x_stretch.scale = compute_scale(x_scale)
	
	reset_tilemaps()
	draw_tilemaps()
	set_offsets_and_scale()

func compute_scale(scale) -> float:
	return scale

# Clears all tilemaps
func reset_tilemaps():
	for coord in tile_coords:
		left_tilemap.erase_cell(coord)
		right_tilemap.erase_cell(coord)
		middle_tilemap.erase_cell(coord)

func draw_tilemaps():
	var int_beg = x_stretch.pos - x_stretch.size
	var int_end = x_stretch.pos + x_stretch.size
	
	for i in tile_coords.size():
		var coord = tile_coords[i]
		var atlas = tiles_atlas[i]
		
		if coord.x < int_beg:
			left_tilemap.set_cell(coord, 1, atlas)
		elif coord.x > int_end:
			right_tilemap.set_cell(coord, 1, atlas)
		else:
			middle_tilemap.set_cell(coord, 1, atlas)
		

func set_offsets_and_scale():
	middle_tilemap.scale.x = x_stretch.scale
	middle_tilemap.position.x = TILE_SIZE * (1 - x_stretch.scale) * (x_stretch.pos - x_stretch.size)
	right_tilemap.position.x = TILE_SIZE * (2 * x_stretch.size + 1) * (x_stretch.scale - 1)
