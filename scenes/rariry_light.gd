@tool
extends Node3D

enum Rarities {COMMON, UNCOMMON, RARE, LEGENDARY,SECRET}
var RED := Color.RED
var GRAY := Color.GRAY
var ORANGE := Color.ORANGE
var BLUE := Color.BLUE
var BLACK := Color.BLACK
@export var rarity: Rarities = Rarities.COMMON:
	set(value):
		rarity = value
		update_rarity_visual()

@onready var rarity_light: SpotLight3D = $SpotLight3D
@onready var light_mesh: MeshInstance3D = $MeshInstance3D

func _ready():
	update_rarity_visual()

func update_rarity_visual():
	if rarity_light == null or light_mesh == null:
		return

	# Make sure the material is unique per instance
	var mat := light_mesh.get_active_material(0)
	if mat == null:
		return
	mat = mat.duplicate()
	light_mesh.set_surface_override_material(0, mat)
	match rarity:
		Rarities.COMMON:
			rarity_light.light_color = GRAY
			light_mesh.get_active_material(0).albedo_color= GRAY
			light_mesh.get_active_material(0).emission= GRAY
		Rarities.UNCOMMON:
			rarity_light.light_color = RED
			light_mesh.get_active_material(0).albedo_color= RED
			light_mesh.get_active_material(0).emission= RED
		Rarities.RARE:
			rarity_light.light_color = BLUE
			light_mesh.get_active_material(0).albedo_color= BLUE
			light_mesh.get_active_material(0).emission= BLUE
		Rarities.LEGENDARY:
			rarity_light.light_color = ORANGE
			light_mesh.get_active_material(0).albedo_color= ORANGE
			light_mesh.get_active_material(0).emission= ORANGE
		Rarities.SECRET:
			rarity_light.light_color = BLACK
			light_mesh.get_active_material(0).albedo_color= BLACK
			light_mesh.get_active_material(0).emission= BLACK
		
