extends Node3D

@onready var player = $Player
@onready var player_camera = $PlayerCamera
@onready var UI = $UI

@export var item_drop_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	player_camera.mouse_position_changed.connect(player._player_look_towards)
	player.player_position_changed.connect(player_camera._update_camera_position)
	player.add_item_to_inventory.connect(UI._collect_item_drop)
	UI.inventory_open_change.connect(player._inventory_status_changed)
	UI.tool_selected.connect(player._set_player_tool)
	
	for item in get_children():
		if item is WorldObject:
			item.create_item_drop.connect(_spawn_item_drop_in_world)

func _spawn_item_drop_in_world(resource: ItemResource, amount: int, location: Vector3) -> void:
	for i in range(amount):
		var item_drop = item_drop_scene.instantiate()
		add_child(item_drop)
		item_drop.set_item_drop(resource)
		item_drop.spawn_item(location + Vector3(0,0.25,0))
