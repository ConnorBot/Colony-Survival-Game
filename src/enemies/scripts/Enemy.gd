extends CharacterBody3D

class_name Enemy

const _angular_speed:float = TAU

@onready var health_bar = $StatusBar
@onready var view_area = $ViewArea
@onready var mesh = $Mesh 

@export var total_health: int = 100
@export var speed: int = 1
var health: float
var target = null
var knockback: bool = false
var knockback_time: float = 0.15
var knockback_dir: Vector3 = Vector3.ZERO


func _ready():
	view_area.body_entered.connect(_on_view_area_entered)
	view_area.body_exited.connect(_on_view_area_exited)
	health = total_health


func _physics_process(delta):
	velocity = Vector3.ZERO
	
	# Move enemy towards target. 
	if target and !knockback:
		var target_dir = global_position.direction_to(target.global_position)
		velocity = target_dir
		
		# Rotate enemy to face target.
		var angle_diff := wrapf((-Vector2(target_dir.x,target_dir.z).angle() + deg_to_rad(90)) - mesh.rotation.y, -PI, PI)
		mesh.rotation.y += clamp(delta * _angular_speed, 0, abs(angle_diff)) * sign(angle_diff)
	
	# Move enemy away with knockback.
	if knockback:
		velocity = knockback_dir * 5
	
	move_and_collide(velocity * speed * delta)

# Applies damage to enemies health and updates its status bar to reflect change.
func apply_damage(damage: float) -> void:
	health -= damage
	health_bar.update_status(float(health)/float(total_health))
	if health <= 0:
		queue_free()


# Applies knockback to emeny at in a given direction.
func apply_knockback(direction: Vector3) -> void:
	# Delete any existing timer set on status bar.
	for child in get_children():
		if child is Timer:
			child.queue_free()
	
	# Create new timer for knockback.
	var timer: Timer = Timer.new()
	timer.wait_time = knockback_time
	timer.one_shot = true
	add_child(timer)
	
	# Set knockback flag and direction
	knockback = true
	knockback_dir = direction
	
	timer.start() # Start timer.
	
	await timer.timeout # Wait for timer to end.
	
	# Clear knockback flag and direction, and delete timer.
	knockback = false
	knockback_dir = Vector3.ZERO
	timer.queue_free()


func _on_view_area_entered(body: Node3D):
	if body.name == "Player":
		target = body


func _on_view_area_exited(body: Node3D):
	if body.name == "Player":
		target = null
