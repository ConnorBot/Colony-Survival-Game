extends ColorRect

# Child Nodes
@onready var itemIcon = $ItemIcon
@onready var itemQuantity = $ItemQuantity

# Sets icon texture and quantity label on itemSlot.
func set_item_slot(item: ItemResource, quantity: int) -> void:
	# If item and quantity inputs exist set icon and quantity, else clear both.
	if item and quantity:
		if item.stackable:
			itemIcon.texture = item.texture
			itemQuantity.text = str(quantity)
		else:
			itemIcon.texture = item.texture
			itemQuantity.text = ""
	else:
		itemIcon.texture = null
		itemQuantity.text = ""


# Sets colour of slot to spefific hex value. 
func set_slot_colour(colour_hex: String):
	color = colour_hex
