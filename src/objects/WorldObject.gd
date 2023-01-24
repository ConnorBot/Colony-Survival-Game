extends StaticBody3D
class_name WorldObject

signal create_item_drop(resource: ItemResource, amount: int, location: Vector3)

enum ToolType { PICKAXE, SWORD, HATCHET }

@onready var durability_bar = $StatusBar

@export var total_durability : int = 100
@export var toolType : ToolType
@export var drop_resource : ItemResource
@export var drop_amout : int = 1

var durability

func _ready():
	durability = total_durability


# Applies damage to objects durability and updates its status bar to reflect change.
func apply_damage(damage: int) -> void:
	durability -= damage
	print(float(durability)/float(total_durability))
	durability_bar.update_status(float(durability)/float(total_durability))
	if durability <= 0:
		queue_free()
		create_item_drop.emit(drop_resource, drop_amout, position)
