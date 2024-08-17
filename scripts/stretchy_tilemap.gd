extends Node2D

const TILE_SIZE: int = 16
const STRETCH_SPEED: float = 3.0

@export var main_tilemap: TileMapLayer
@export var stretch_center: AnimatedSprite2D
@export var player_pos: Node2D

var tileset: TileSet

# Tilemap left of the stretching
@onready var left_tilemap: TileMapLayer = $LeftTileMap
# Tilemap right of the stretching
@onready var right_tilemap: TileMapLayer = $RightTileMap
# The stretched tilemap: if no stretch is applied, this is the main one
@onready var middle_tilemap: TileMapLayer = $MiddleTileMap

var tile_coords: Array[Vector2i]
var tiles_atlas: Array[Vector2i]

var stretch_item_at_player: bool = true

class Stretch:
	var size: int
	var pos: int
	var scale: float

enum StretchType {
	LEFT,
	MIDDLE,
	RIGHT,
}

var x_stretch: Stretch
var stretch_type: StretchType = StretchType.MIDDLE

const MAX_SCALE: float = 2.5
var x_scale: float = 1
var increase_scale: bool = false
var decrease_scale: bool = false

const UNDO_SPEED: float = 1.0
const MAX_UNDO_STEP: float = 1.0
var is_undoing: bool = false
var undo_timer: float = 0

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
	
	if Input.is_action_just_pressed("swap_stretch_mode") and x_scale == 1:
		match stretch_type:
			StretchType.LEFT:
				stretch_type = StretchType.RIGHT
			StretchType.RIGHT:
				stretch_type = StretchType.MIDDLE
			StretchType.MIDDLE:
				stretch_type = StretchType.LEFT
	
	if Input.is_action_just_pressed("undo_stretch"):
		is_undoing = true
		undo_timer = 0
	
	if Input.is_action_just_pressed("toggle_stretch_item"):
		stretch_item_at_player = !stretch_item_at_player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_item_position()
	if is_undoing:
		do_undo_step(delta)
	else:
		process_stretch_input(delta)
	x_stretch.scale = x_scale
	
	reset_tilemaps()
	draw_tilemaps()
	set_offsets_and_scale()

func update_item_position():
	if x_scale != 1:
		stretch_item_at_player = false
	
	if stretch_item_at_player:
		stretch_center.visible = false
		var player_pos_int = player_pos.position as Vector2i
		stretch_center.position.x = (player_pos_int.x / TILE_SIZE) as int * TILE_SIZE + TILE_SIZE * 0.5
		stretch_center.position.y = player_pos_int.y
	else:
		stretch_center.visible = true
	x_stretch.pos = stretch_center.position.x / 16 as int

func do_undo_step(delta):
	if x_scale == 1:
		is_undoing = false
	else:
		undo_timer += delta * UNDO_SPEED
		x_scale = linear_interpolate(x_scale, 1, undo_timer)

func process_stretch_input(delta):
	x_scale += (increase_scale as int - (decrease_scale as int)) * delta * STRETCH_SPEED
	x_scale = clamp(x_scale, 0, MAX_SCALE)

func linear_interpolate(x, y, t) -> float:
	if t < 0:
		return x
	if t > 1:
		return y
	return x * (1 - t) + y * t	

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
	match stretch_type:
		StretchType.LEFT:
			left_tilemap.position.x = 0
			middle_tilemap.position.x = TILE_SIZE * (1 - x_stretch.scale) * (x_stretch.pos - x_stretch.size)
			right_tilemap.position.x = TILE_SIZE * (2 * x_stretch.size + 1) * (x_stretch.scale - 1)
		StretchType.RIGHT:
			left_tilemap.position.x = TILE_SIZE * (2 * x_stretch.size + 1) * (1 - x_stretch.scale)
			middle_tilemap.position.x = TILE_SIZE * (1 - x_stretch.scale) * (x_stretch.pos + x_stretch.size + 1)
			right_tilemap.position.x = 0
		StretchType.MIDDLE:
			left_tilemap.position.x = TILE_SIZE * (x_stretch.size + 0.5) * (1 - x_stretch.scale)
			middle_tilemap.position.x = TILE_SIZE * (1 - x_stretch.scale) * (x_stretch.pos + 0.5)
			right_tilemap.position.x = TILE_SIZE * (x_stretch.size + 0.5) * (x_stretch.scale - 1)
