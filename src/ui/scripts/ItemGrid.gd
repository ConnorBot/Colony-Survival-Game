extends GridContainer

@export var ItemSlot : PackedScene

# ItemGrid properties
var cols: int
var rows: int
var slots: Array

# Creates empty grid for a given size.
func create_ItemGrid(row_length: int, col_length: int) -> void:
	self.cols = col_length
	self.rows = row_length
	
	columns = cols # Sets number of GridContainer columns.
	
	# Loop to create all ItemSlots and assign them to an array. 
	for i in range(rows * cols):
		var itemSlot = ItemSlot.instantiate()
		slots.append(itemSlot)
		itemSlot.name = str(i)
		add_child(itemSlot)
	
	size = size + Vector2(50,50)


# Set item icon and quantity for specific slot.  
func set_Item_At_Slot(item: Resource, quantity: int, row: int, col: int) -> void:
		# Calculate slot from row and column, then set slot to given item.
		slots[calc_index(row, col)].set_item_slot(item, quantity)


# Change the change the colour of a slot for a given row and coloumn position to
# a specific hex value.
func change_item_slot_colour(row: int, col: int, colour_hex: String):
	slots[calc_index(row, col)].set_slot_colour(colour_hex)


# Calculates index of slots array from row and column position.
func calc_index(row: int, col: int) -> int:
	var slot = row * cols + col
	return slot

