extends Camera3D

signal mouse_position_changed(position: Vector3)

var rayOrigin : Vector3 = Vector3()
var rayEnd : Vector3 = Vector3()

var camera_offset: Vector3 = Vector3(0, 2, 2)

var mouse_world_position = Vector3.ZERO

func _physics_process(_delta):
	calc_mouse_position_in_world()


# Function that uses ray casts to determine where is the world the mouse is 
# hovering over, and emits signal has position changes.
func calc_mouse_position_in_world():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	
	rayOrigin = project_ray_origin(mouse_position)
	rayEnd = rayOrigin + project_ray_normal(mouse_position) * 2000
	
	var params = PhysicsRayQueryParameters3D.new()
	params.from = rayOrigin
	params.to = rayEnd
	params.exclude = []
	params.collision_mask = 2
	
	var intersection = space_state.intersect_ray(params)
	
	
	if !intersection.is_empty():
		if intersection.position != mouse_world_position:
			mouse_world_position = intersection.position
			mouse_position_changed.emit(mouse_world_position)


# Function to update camera position to follow player position.
func _update_camera_position(camera_position):
	position = camera_position + camera_offset
