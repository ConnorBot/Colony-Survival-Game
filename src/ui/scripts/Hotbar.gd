extends InventorySlots

const DEFAULT_COL_SIZE = 7
const DEFAULT_ROW_SIZE = 1

var selected_slot : Vector2 = Vector2.ZERO 

# Called when the node enters the scene tree for the first time.
func _ready():
	cols = DEFAULT_COL_SIZE
	rows = DEFAULT_ROW_SIZE
	init_inventorySlots()
	
	await get_tree().root.ready
	
	set_selected_slot(int(selected_slot.x), int(selected_slot.y))

	add_item(ItemDatabase.get_item_by_name("Pickaxe"), 1)
	add_item(ItemDatabase.get_item_by_name("Hatchet"), 1)
	add_item(ItemDatabase.get_item_by_name("Sword"), 1)


# Sets hotbar selected slot and updates colour to reflect selection.
func set_selected_slot(row: int, col: int):
	itemGrid.change_item_slot_colour(selected_slot.x, selected_slot.y, "#333333")
	selected_slot = Vector2(row, col)
	itemGrid.change_item_slot_colour(row, col, "#999999")

