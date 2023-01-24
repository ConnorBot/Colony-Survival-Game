extends Node3D

@onready var status = $Status

@export var display_time: int = 5
@export var max_status_size : float = 0.5

func _ready():
	visible = false


# Function to update status bar to a given percentage (0-1) and display it for 
# a gicen period of time.
func update_status(status_percentage: float) -> void:
	# Delete any existing timer set on status bar.
	for child in get_children():
		if child is Timer:
			child.queue_free()
	
	# Create new timer for status bar.
	var timer: Timer = Timer.new()
	timer.wait_time = display_time
	timer.one_shot = true
	add_child(timer)
	
	# Update status bar percentage being displayed.
	status.scale.x = status_percentage
	status.position.x = -(max_status_size - max_status_size * status_percentage) / 2
	visible = true
	
	timer.start() # Start timer.
	
	await timer.timeout # Wait for timer to end.
	
	# Hide status bar and delete timer from status bar node.
	visible = false
	timer.queue_free()
