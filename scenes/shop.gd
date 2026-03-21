extends Node3D

@export var charm_pool: Array[PackedScene]

@onready var slots: Array[Marker3D] = [
	$Level2/Slot1,
	$Level2/Slot2,
	$Level2/Slot3,
	$Level2/Slot4
]
var shop_charms: Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roll_shop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func roll_shop():
	clear_shop()
	var amount = min(3, charm_pool.size())
	var available := charm_pool.duplicate()
	available.shuffle()

	for i in range(amount):
		var scene = available.pop_front()
		var charm = scene.instantiate() as Node3D
		var slot = slots[i]

		# Place charm in the slot
		charm.position = slot.position + Vector3(0,0.2,0)
		add_child(charm)
		shop_charms.append(charm)

		# Check its rarity
		var charm_rarity = charm.rarity  # each charm instance has its own rarity
		print(charm.rarity)
		# Spawn the coin underlight below it
		var coin_light_scene: PackedScene = preload("res://scenes/rariry_light.tscn")
		var coin_light = coin_light_scene.instantiate() as Node3D
		coin_light.position = Vector3(0, -0.1, 0)  # local to charm
		charm.add_child(coin_light)

# Set the coin light’s color to match the charm rarity
		coin_light.rarity = charm_rarity
		coin_light.update_rarity_visual()
func clear_shop():
	for charm in shop_charms:
		charm.queue_free()

	shop_charms.clear()




func _on_reroll_pressed() -> void:
	roll_shop()
