extends CharacterBody3D

signal player_position_changed(player_position: Vector3)
signal add_item_to_inventory(item: Node3D, target: Node3D)

@export var forward_walk_speed = 2.0
@export var backward_walk_speed = 1.5

@onready var player_body = $PlayerBody
@onready var animation_player = $PlayerBody/AnimationPlayer
@onready var right_hand_hold = $PlayerBody/Armature/Skeleton3D/RightHandBone/Hold
@onready var damage_area = $DamageArea
@onready var collection_area = $CollectionArea

var players_current_position: Vector3 = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var using_tool : bool = false
var equiped_tool : Tool = null
var allow_player_input: bool = true

func _ready():
	players_current_position = position
	animation_player.animation_finished.connect(_player_animation_finished)
	damage_area.body_entered.connect(_body_entered_damage_area)
	collection_area.body_entered.connect(_body_entered_collection_area)


func _physics_process(delta):
	player_movement(delta)


func _input(event):
	if event is InputEventMouseButton and allow_player_input:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			using_tool = true
			animation_player.play("UseTool", -1, 2)
			
			# Delays activation of monitoring damager area so that it's activated 
			# on the swing down of the tool.
			await get_tree().create_timer(0.2).timeout 
			
			damage_area.monitoring = true
			get


# Function to set player current equiped tool.
func _set_player_tool(tool_name: String):
	# Remove existing tool if one is already in hand.
	if right_hand_hold.get_child_count() > 0:
		right_hand_hold.get_child(0).queue_free()
		
	# Instance desired tool and add to hand.
	if tool_name != "None":
		equiped_tool = ItemDatabase.get_item_by_name(tool_name).object.instantiate()
		right_hand_hold.add_child(equiped_tool)
	else:
		equiped_tool = null


# Function to be run when player animation has finished.
func _player_animation_finished(animation_name):
	if animation_name == "UseTool":
		using_tool = false
		damage_area.monitoring = false


# Function to set allow player input flag.
func _inventory_status_changed(open: bool):
	allow_player_input = !open


# Applies damage to object in area if it can be damaged by current tool.
func _body_entered_damage_area(body: Node3D) -> void:
	if body is Enemy and equiped_tool.type == Tool.ToolType.SWORD:
		var enemy: Enemy = body as Enemy
		enemy.apply_damage(equiped_tool.damage, )
		enemy.apply_knockback(Vector3(-sin(rotation.y), 0, -cos(rotation.y)))
	if body is WorldObject and equiped_tool.type == body.toolType:
		var object: WorldObject = body as WorldObject
		object.apply_damage(equiped_tool.damage)


func _body_entered_collection_area(body: Node3D) -> void:
	if body is DropItem:
		print("collect")
		add_item_to_inventory.emit(body, self)


# Function that gets the player directional input, moves player in corresponding
# direction, updates player character's animation, and emits signal of players 
# new position in the world.
func player_movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if allow_player_input:
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction_y = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
		
		if !using_tool:
			if input_dir.y < 0:
				velocity.x = direction_y.x * forward_walk_speed
				velocity.z = direction_y.z * forward_walk_speed
				animation_player.play("Walk")
			elif input_dir.y > 0:
				velocity.x = direction_y.x * backward_walk_speed
				velocity.z = direction_y.z * backward_walk_speed
				animation_player.play("Walk",-1,-1)
			else:
				velocity.x = move_toward(velocity.x, 0, forward_walk_speed)
				velocity.z = move_toward(velocity.z, 0, forward_walk_speed)
				animation_player.play("Idle")
			
			move_and_slide()
		
		if position != players_current_position:
			players_current_position = position
			player_position_changed.emit(players_current_position)


# Function to make player roatate towards mouse position.
func _player_look_towards(look_position: Vector3):
	if allow_player_input:
		look_at(Vector3(look_position.x, position.y, look_position.z))
