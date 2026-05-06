extends Node3D

@export var charm_pool: Array[PackedScene]

@onready var slots: Array[Marker3D] = [
	$Level2/Slot1,
	$Level2/Slot2,
	$Level2/Slot3,
	$Level2/Slot4
]

var shop_charms: Array[Node3D] = []

func _ready() -> void:
	roll_shop()

func roll_shop():
	clear_shop()

	var amount = min(slots.size(), charm_pool.size())
	var available := charm_pool.duplicate()
	available.shuffle()

	for i in range(amount):
		var scene = available.pop_front()
		var charm = scene.instantiate() as Node3D
		var slot = slots[i]

		charm.position = slot.position + Vector3(0, 0.2, 0)
		add_child(charm)

		charm.set_meta("scene", scene)
		charm.set_meta("slot_index", i)

		shop_charms.append(charm)

		_spawn_rarity_light(charm)

func buy_charm(charm: Node3D):
	if charm == null:
		return

	if not charm.has_meta("slot_index"):
		return

	var slot_index: int = charm.get_meta("slot_index")

	shop_charms.erase(charm)
	charm.queue_free()

	refill_slot(slot_index)

func refill_slot(index: int):
	if charm_pool.is_empty():
		return

	var available := charm_pool.duplicate()
	available.shuffle()

	var scene = available.pop_front()
	var charm = scene.instantiate() as Node3D
	var slot = slots[index]

	charm.position = slot.position + Vector3(0, 0.2, 0)
	add_child(charm)

	charm.set_meta("scene", scene)
	charm.set_meta("slot_index", index)

	shop_charms.append(charm)

	_spawn_rarity_light(charm)

func clear_shop():
	for charm in shop_charms:
		if is_instance_valid(charm):
			charm.queue_free()

	shop_charms.clear()

func _spawn_rarity_light(charm: Node3D):
	var charm_rarity = charm.rarity

	var coin_light_scene: PackedScene = preload("res://scenes/rariry_light.tscn")
	var coin_light = coin_light_scene.instantiate() as Node3D

	coin_light.position = Vector3(0, -0.1, 0)
	charm.add_child(coin_light)

	coin_light.rarity = charm_rarity
	coin_light.update_rarity_visual()

func _on_reroll_pressed() -> void:
	roll_shop()
