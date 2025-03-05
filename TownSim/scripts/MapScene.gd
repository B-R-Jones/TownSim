extends Node2D

@export var map_width: int = 100
@export var map_height: int = 100
@export var tile_size: Vector2 = Vector2(32, 32)

# Example tile IDs in your TileSet
const TILE_GRASS  = 0
const TILE_DIRT   = 1
const TILE_STONE  = 2
const TILE_WATER   = 3
const TILE_SAND  = 4

func _ready():
		# 1) Load your existing TileSet resource
	var tile_set = $MapContainer/MapLayers/TileMapLayer
	var nav_region = $MapContainer/NavigationRegion2D
	var new_nav_mesh = NavigationPolygon.new()
	var bounding_outline = PackedVector2Array([Vector2(0,0), Vector2(0,map_height*tile_size.y), Vector2(map_width*tile_size.x, map_height*tile_size.y), Vector2(map_width*tile_size.x, 0)])
	new_nav_mesh.add_outline(bounding_outline)
	NavigationServer2D.bake_from_source_geometry_data(new_nav_mesh, NavigationMeshSourceGeometryData2D.new())
	nav_region.navigation_polygon = new_nav_mesh

	# 2) Create your noise object (or any method of deciding which tile goes where)
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 4
	noise.frequency = 0.05

	# 3) Loop and place one Sprite for each tile
	for x in range(map_width):
		for y in range(map_height):
			var value = noise.get_noise_2d(float(x), float(y))
			value = (value + 1.0) * 0.5	# Convert [-1..1] to [0..1]
			var tile_id := pick_tile_id(value)
			tile_set.set_cell(Vector2i(x, y), 0, Vector2i(tile_id, 0), 0)

func pick_tile_id(value: float) -> int:
	if value < 0.2:
		return TILE_WATER
	elif value < 0.35:
		return TILE_SAND
	elif value < 0.5:
		return TILE_DIRT
	elif value < 0.9:
		return TILE_GRASS
	else:
		return TILE_STONE
