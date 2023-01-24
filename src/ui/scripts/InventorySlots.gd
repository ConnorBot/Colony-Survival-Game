extends Control
class_name InventorySlots

signal slot_left_clicked(pos: Vector2, ui_component: String)
signal slot_right_clicked(pos: Vector2, ui_component: String)
signal show_tooltip(name: String, visible: bool)
signal slot_changed(pos: Vector2)

@export var ItemGrid : PackedScene

var itemGrid
@export var cols : int
@export var rows : int

var slots: Array

# Initiates item grid and data array for slots of set row and column size. Links 
# each slots singals to corresponding function. 
func init_inventorySlots() -> void:
	
	# Creates item grid.
	itemGrid = ItemGrid.instantiate()
	itemGrid.create_ItemGrid(rows, cols)
	add_child(itemGrid)
	
	# Creates slots data array.
	for i in range(rows):
		slots.append([])
		for j in range(cols):
			slots[i].append({"name": "Empty", "quantity": 0})
	
	# Connect item grid slots signals to functions.
	var index : int = 0 
	for itemSlot in itemGrid.get_children():
		itemSlot.gui_input.connect(_slot_entered.bind(index))
		itemSlot.mouse_entered.connect(_show_tooptip.bind(index))
		itemSlot.mouse_exited.connect(_hide_tooptip.bind(index))
		index += 1


# Function to handle inputs when mouse enters a slot.
func _slot_entered(event, index: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			slot_left_clicked.emit(calc_slot_pos(index), self.name)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			slot_right_clicked.emit(calc_slot_pos(index), self.name)


# Sets item in both item grid and data array for a slot at given row and column position.
func set_item(itemName: String, quantity: int, row: int, col: int) -> void:
	var item = ItemDatabase.get_item_by_name(itemName)
	
	if item:
		slots[row][col] = {"name": itemName, "quantity": quantity}
		itemGrid.set_Item_At_Slot(item, quantity, row, col)
		slot_changed.emit(Vector2(row, col))
	else:
		print("ERROR: InventorySlots.gb - Item '%s' doesn't exist in ItemDatabase" % itemName)


# Adds item to to existing item stack, else adds to first empty slot. Returns quantity 
# of item that wasn't able to be added to the slots (returning 0 means all items added).
func add_item(item: ItemResource, quantity: int) -> int:
	var current_quantity: int = quantity
	var slot_pos: Vector2
	
	# Loops until quantity is at zero or there is no slots left to add item.
	while current_quantity > 0:
		
		# Checks if item stack already exists, else checks if empty slot is avalible, 
		# else returns quantity that couldn't be added.
		slot_pos = find_item_in_slots(item.name)
		if slot_pos != Vector2(-1,-1):
			var slot_quantity = slots[slot_pos.x][slot_pos.y].quantity
			# Adds all items to stack if there's room, else adds until stack is 
			# full and updates quantity.
			if item.max_stack_size - slot_quantity >= current_quantity:
				update_item_quantity(current_quantity, slot_pos.x, slot_pos.y)
				current_quantity = 0
			else:
				update_item_quantity((item.max_stack_size - slot_quantity), slot_pos.x, slot_pos.y)
				current_quantity -= item.max_stack_size - slot_quantity
		else:
			var empty_slot_pos: Vector2 = find_item_in_slots("Empty")
			if empty_slot_pos != Vector2(-1,-1):
				# Adds all items to stack if there's room, else adds until stack is 
				# full and updates quantity.
				if item.max_stack_size >= current_quantity:
					set_item(item.name, current_quantity, int(empty_slot_pos.x), int(empty_slot_pos.y))
					current_quantity = 0
				else:
					set_item(item.name, item.max_stack_size, int(empty_slot_pos.x), int(empty_slot_pos.y))
					current_quantity -= item.max_stack_size
			else:
				return current_quantity
		
	return current_quantity


# Finds the first slot in the inventory that contains inputed item under the stack amount.
# If input with "Empty" returns first empty slot.
func find_item_in_slots(itemName: String) -> Vector2:
	for i in range(rows):
		for j in range(cols):
			if (itemName == "Empty" and slots[i][j].name == itemName):
				return Vector2(i, j)
			elif (slots[i][j].name == itemName and 
					slots[i][j].quantity < ItemDatabase.get_item_by_name(itemName).max_stack_size):
				return Vector2(i, j)
	
	return Vector2(-1,-1)


# Updates quantity of item in slot at given row and column position.
func update_item_quantity(amount: int, row: int, col: int) -> void:
	var item = slots[row][col]
	if item.quantity + amount <= 0:
		set_item("Empty", 0, row, col)
		show_tooltip.emit("", false)
	else:
		set_item(item.name, item.quantity + amount, row, col)


# Returns item in slot at a given row and column position.
func pickup_item(row: int, col: int) -> Dictionary:
	var item = slots[row][col]
	
	var index : int = itemGrid.calc_index(row, col)
	_hide_tooptip(index)
	
	set_item("Empty", 0, row, col)
	
	return item


# Places an item in a slot at a given row and column position, returning any item
# that was currently in that slot.
func place_item(item: Dictionary, row: int, col: int) -> Dictionary:
	var place_Slot_Item = slots[row][col]
	if place_Slot_Item.name == "Empty":
		set_item(item.name, item.quantity, row, col)
		return {}
	elif place_Slot_Item.name == item.name and ItemDatabase.get_item_by_name(item.name).stackable:
		update_item_quantity(item.quantity, row, col)
		return {}
	else:
		set_item(item.name, item.quantity, row, col)
		return place_Slot_Item


# Splits item in slot at a given row and column position depending on the item the 
# player currently has selected and updates slot quantities. Returns item with updated
# quantity with amount taken from slot item, or same quantity if split was invalid.
func split_item_stack(item_picked_up: Dictionary, row: int, col: int) -> Dictionary:
	var slot_Item = slots[row][col]
	if item_picked_up.is_empty():
		var take_quantity = slot_Item.quantity - slot_Item.quantity / 2
		update_item_quantity(-take_quantity, row, col)
		var return_item = slot_Item
		return_item.quantity = take_quantity
		return return_item
	elif item_picked_up.name == slot_Item.name:
		var take_quantity = slot_Item.quantity - slot_Item.quantity / 2
		update_item_quantity(-take_quantity, row, col)
		item_picked_up.quantity += take_quantity
		
	return item_picked_up


# Function to show tooltip.
func _show_tooptip(index: int) -> void:
	var pos : Vector2 = calc_slot_pos(index)
	var item : Dictionary = slots[pos.x][pos.y]
	if item.name != "Empty":
		show_tooltip.emit(item.name, true)


# Function to hide tooltip
func _hide_tooptip(index: int) -> void:
	var pos : Vector2 = calc_slot_pos(index)
	var item : Dictionary = slots[pos.x][pos.y]
	if item.name != "Empty":
		show_tooltip.emit("", false)


# Function to calculate row and column for a given slot index position.
func calc_slot_pos(index: int) -> Vector2:
	var row : int = index / cols
	var col : int = index % cols
	return Vector2(row,col)


