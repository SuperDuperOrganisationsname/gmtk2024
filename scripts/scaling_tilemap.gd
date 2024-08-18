extends Node2D

# ---------- Export-Variables ---------- #

# The TileMap: will be copied and disabled
@export var main_tilemap: TileMapLayer

# The player character
@export var player: CharacterBody2D


# ------------ Child-Nodes ------------- #

# Tilemap left of the stretching
@onready var left_tilemap: TileMapLayer = $LeftTileMap

# Tilemap right of the stretching
@onready var right_tilemap: TileMapLayer = $RightTileMap

# The stretched tilemap: if no stretch is applied, this is the main one
@onready var middle_tilemap: TileMapLayer = $MiddleTileMap

# ------------- Constants -------------- #

# Tilesize of a single tile
const TILE_SIZE: int = 16

# Speed for scaling (times delta_time)
const SCALE_SPEED: float = 3.0

# Upper bound for stretching
const MAX_SCALE: float = 5

# If stretch is near 1, round it to 1
const ROUND_THRESHOLD: float = 0.04

# Speed of undoing a stretch
const UNDO_SPEED: float = 3.0

# Force Multiplier for throwing the Talisman
const THROW_SPEED: float = 500.0

# ----------- Helper-Structs ---------- #

# A scaling is defined as an interval at pos with radius size and a scale
class Scaling:
	var size: int
	var pos: int
	var scale: float

# A scaling can be anchored left, right, or in the middle
enum ScaleType {
	LEFT,
	MIDDLE,
	RIGHT,
}

# Important position states of the last frame:
# - in which tilemap was the player
# - waht are the offsets of all three tilemaps
# - scaled distance from talisman to player
# - scaling of last frame
class LastPosState:
	var tilemap: int
	var offsets: Vector3
	var cent_dist: float
	var scale: float


# -------- TileSet-Information -------- # 

# The main TileSet
var tileset: TileSet

# Source-ID of the TileSet
var source: int

# Coordinates of all tiles to be rendered
var tile_coords: Array[Vector2i]

# Coordinates in Atlas of all tiles to be rendered (same order as in tile_coords)
var tiles_atlas: Array[Vector2i]


# -------- Scaling-Variables --------- #

# Is the interval centered at the player at the moment
var scale_item_at_player: bool = true

# Current scale
var scaling: Scaling

# Current scale-type
var scale_type: ScaleType = ScaleType.MIDDLE

# Is the scaling currently increasing/decreasing?
var increase_scale: bool = false
var decrease_scale: bool = false

# Is the scaling curently undoing?
var is_undoing: bool = false

# State of last frame
var last_state: LastPosState

# Called when the node enters the scene tree for the first time.
func _ready():
	# Copy TileSet-Data and disable original TileMap
	tileset = main_tilemap.get_tile_set()
	source = tileset.get_source_id(0)
	tile_coords = main_tilemap.get_used_cells()
	tiles_atlas.assign(tile_coords.map(func(coord): return main_tilemap.get_cell_atlas_coords(coord)))
	
	left_tilemap.set_tile_set(tileset)
	right_tilemap.set_tile_set(tileset)
	middle_tilemap.set_tile_set(tileset)
	
	main_tilemap.enabled = false

	# Instantiate Scaling
	scaling  = Scaling.new()
	scaling.size = 3
	scaling.pos = 0
	scaling.scale = 1
	
	# Instantiate LastFrame-Data
	last_state = LastPosState.new()
	last_state.cent_dist = player.position.x - $Talisman.position.x
	last_state.tilemap = 1
	last_state.offsets = Vector3(0, 0, 0)
	last_state.scale = scaling.scale
	
	# Instantiate Interval-Indicators
	$LeftLine.add_point(Vector2(100, -10000))
	$LeftLine.add_point(Vector2(100, 10000))
	$RightLine.add_point(Vector2(100, -10000))
	$RightLine.add_point(Vector2(100, 10000))

# Input-Handling
func _input(_event):
	# Increase/Decrease scaling
	increase_scale = Input.is_action_pressed("strech") 
	decrease_scale = Input.is_action_pressed("shrink")
	
	# Swap ScaleType
	if Input.is_action_just_pressed("swap_scale_mode") and scaling.scale == 1:
		match scale_type:
			ScaleType.LEFT:
				scale_type = ScaleType.RIGHT
			ScaleType.RIGHT:
				scale_type = ScaleType.MIDDLE
			ScaleType.MIDDLE:
				scale_type = ScaleType.LEFT
	
	# Undo scaling
	if Input.is_action_just_pressed("undo_scale"):
		is_undoing = true
	
	# Get/Drop interval-marker
	if Input.is_action_just_pressed("toggle_scale_item"):
		scale_item_at_player = !scale_item_at_player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Compute new scales and positions
	update_item_position()
	scale(delta)
	set_offsets_and_scale()
	
	# Redraw map
	reset_tilemaps()
	draw_tilemaps()
	update_indicators()
	
	# Update player position
	force_player_pos_update()
	
	# Store data
	store_last_state()


# ------ Update Scaling/Positions -------- #

# Update position of interval-marker
func update_item_position():
	if scaling.scale != 1:
		scale_item_at_player = false
	
	if scale_item_at_player:
		$Talisman.freeze = false
		$Talisman.visible = false
		var player_pos_int = player.position as Vector2i
		var new_pos = Vector2((player_pos_int.x / TILE_SIZE) as int * TILE_SIZE + TILE_SIZE * 0.5, player_pos_int.y)
		if player.position.x < 0:
			new_pos.x -= 2 * TILE_SIZE
		$Talisman.new_position = new_pos
		$Talisman.update_position = true
		$Talisman.set_axis_velocity(Vector2(0, 0))
	else:
		$Talisman.visible = true
	var pos = $Talisman.position.x / 16 as int
	
	match scale_type:
		ScaleType.LEFT:
			scaling.pos = pos + scaling.size
		ScaleType.RIGHT:
			scaling.pos = pos - scaling.size
		ScaleType.MIDDLE:
			scaling.pos = pos
	
	

# Process scaling
func scale(delta):
	if is_undoing:
		undo_scaling(delta)
	else:
		update_scaling(delta)
	if scaling.scale > 1 - ROUND_THRESHOLD and scaling.scale < 1 + ROUND_THRESHOLD:
		scaling.scale = 1

# Undo scaling
func undo_scaling(delta):
	if scaling.scale == 1:
		is_undoing = false
	else:
		if scaling.scale > 1:
			scaling.scale -= delta * UNDO_SPEED
		else:
			scaling.scale += delta * UNDO_SPEED


# Update scaling depending on input
func update_scaling(delta):
	scaling.scale += (increase_scale as int - (decrease_scale as int)) * delta * SCALE_SPEED
	scaling.scale = clamp(scaling.scale, 0, MAX_SCALE)


# Compute and update offsets of all tilemaps
func set_offsets_and_scale():
	middle_tilemap.scale.x = scaling.scale
	match scale_type:
		ScaleType.LEFT:
			left_tilemap.position.x = 0
			middle_tilemap.position.x = TILE_SIZE * (1 - scaling.scale) * (scaling.pos - scaling.size)
			right_tilemap.position.x = TILE_SIZE * (2 * scaling.size + 1) * (scaling.scale - 1)
		ScaleType.RIGHT:
			left_tilemap.position.x = TILE_SIZE * (2 * scaling.size + 1) * (1 - scaling.scale)
			middle_tilemap.position.x = TILE_SIZE * (1 - scaling.scale) * (scaling.pos + scaling.size + 1)
			right_tilemap.position.x = 0
		ScaleType.MIDDLE:
			left_tilemap.position.x = TILE_SIZE * (scaling.size + 0.5) * (1 - scaling.scale)
			middle_tilemap.position.x = TILE_SIZE * (1 - scaling.scale) * (scaling.pos + 0.5)
			right_tilemap.position.x = TILE_SIZE * (scaling.size + 0.5) * (scaling.scale - 1)


# ---------- Redraw Map ---------- #

# Clears all tilemaps
func reset_tilemaps():
	for coord in tile_coords:
		left_tilemap.erase_cell(coord)
		right_tilemap.erase_cell(coord)
		middle_tilemap.erase_cell(coord)

# Redraws all tilemaps (needed because we switch between maps when scaling)
func draw_tilemaps():
	# Interval for middle tilemap
	var int_beg = scaling.pos - scaling.size
	var int_end = scaling.pos + scaling.size
	
	for i in tile_coords.size():
		var coord = tile_coords[i]
		var atlas = tiles_atlas[i]
		
		if coord.x < int_beg:
			left_tilemap.set_cell(coord, source, atlas)
		elif coord.x > int_end:
			right_tilemap.set_cell(coord, source, atlas)
		else:
			middle_tilemap.set_cell(coord, source, atlas)
		

func update_indicators():
	var int_beg = scaling.pos - scaling.size
	var int_end = scaling.pos + scaling.size + 1
	
	var left_pos = left_tilemap.position.x + TILE_SIZE * int_beg
	var right_pos = right_tilemap.position.x + TILE_SIZE * int_end
	
	$LeftLine.set_point_position(0, Vector2(left_pos, -10000))
	$LeftLine.set_point_position(1, Vector2(left_pos, 10000))
	$RightLine.set_point_position(0, Vector2(right_pos, -10000))
	$RightLine.set_point_position(1, Vector2(right_pos, 10000))


# ---------- Update Player ---------- #

# Updates the player position if the map was scaled and the player thus moved
func force_player_pos_update():
	var tilemap = compute_tilemap()
	if last_state.tilemap != tilemap or !player.is_on_floor():
		return
	
	if tilemap == 0:
		player.position.x += left_tilemap.position.x - last_state.offsets.x
	elif tilemap == 2:
		player.position.x += right_tilemap.position.x - last_state.offsets.z
	elif last_state.scale != scaling.scale:
		player.position.x += last_state.cent_dist * scaling.scale + $Talisman.position.x - player.position.x


# ----------- Store Data ---------- #

# Stores the current frame data
func store_last_state():
	last_state.tilemap = compute_tilemap()
	last_state.cent_dist = (player.position.x - $Talisman.position.x) / scaling.scale
	last_state.scale = scaling.scale
	last_state.offsets = Vector3(left_tilemap.position.x, middle_tilemap.position.x, right_tilemap.position.x)	

# Compute in which tilemap the player is
func compute_tilemap() -> int:
	var int_beg = scaling.pos - scaling.size
	var int_end = scaling.pos + scaling.size + 1
	
	var left_pos = left_tilemap.position.x + TILE_SIZE * int_beg
	var right_pos = right_tilemap.position.x + TILE_SIZE * int_end
	
	if player.position.x < left_pos:
		return 0
	elif player.position.x < right_pos:
		return 1
	else:
		return 2

# Throw the Talisman
func _on_player_throw_talisman(vector: Vector2) -> void:
	if !scale_item_at_player:
		return
	
	scale_item_at_player = false
	$Talisman.apply_impulse(vector * THROW_SPEED)
	$Talisman.is_flying = true
