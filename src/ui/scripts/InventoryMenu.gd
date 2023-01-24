extends InventorySlots

const DEFAULT_COL_SIZE = 7
const DEFAULT_ROW_SIZE = 3

func _ready():
	cols = DEFAULT_COL_SIZE
	rows = DEFAULT_ROW_SIZE
	init_inventorySlots()

