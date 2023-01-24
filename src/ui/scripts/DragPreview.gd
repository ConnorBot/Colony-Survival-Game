extends Control

var dragged_item = {} : 
	set(item):
		dragged_item = item
		_set_dragged_item(item)

@onready var item_icon = $ItemIcon
@onready var item_quantity = $ItemIcon/ItemQuantity

var offset: Vector2 = Vector2(30,30)

func _process(_delta):
	if dragged_item:
		position = get_global_mouse_position() - offset


# Set item icon text and quantity of drag preview for given item.
func _set_dragged_item(item):
	if dragged_item:
		var item_data = ItemDatabase.get_item_by_name(item.name)
		item_icon.texture = item_data.texture
		item_quantity.text = str(item.quantity) if item_data.stackable else ""
		visible = true
	else:
		item_icon.texture = null
		item_quantity.text = ""
		visible = false
