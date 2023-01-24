extends CharacterBody3D
class_name DropItem

@onready var sprite = $Sprite

var item: ItemResource
var move_to_target: Node3D = null
var move_to_speed: float = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Adds gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity = Vector3(0,0,0)
	
	move_towards_target()
	
	move_and_slide()


# Moves item drop towards player and delete intance when it gets near.
func move_towards_target():
	if move_to_target:
		print(abs(move_to_target.global_position - global_position))
		var position_diff = abs(move_to_target.global_position - global_position)
		if position_diff.x <= 0.05 and position_diff.z <= 0.05:
			queue_free()
		else:
			var target_dir = global_position.direction_to(move_to_target.global_position)
			velocity = target_dir * move_to_speed


func spawn_item(spawn_position: Vector3) -> void:
	position = spawn_position
	
	velocity += Vector3(randf_range(-1,1),randf_range(0.5, 1),randf_range(-1,1))
	
	#await get_tree().create_timer(5).timeout 
	
	#queue_free()

# Sets item drop target to move towards.
func set_target(target: Node3D):
	move_to_target = target

func set_item_drop(item_type: ItemResource) -> void:
	item = item_type
	sprite.texture = item.texture

