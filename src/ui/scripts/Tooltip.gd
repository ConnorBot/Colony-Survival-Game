extends ColorRect

@onready var margin_container = $MarginContainer
@onready var item_name = $MarginContainer/ItemName

func _process(_delta):
	position = get_global_mouse_position() + Vector2(15, 25)


# Updates tooltip text for a slot item.
func display_info(name_text: String) -> void:
	item_name.text = name_text
	margin_container.size = Vector2()
	size = margin_container.size
