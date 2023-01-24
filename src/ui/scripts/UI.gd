extends Control

signal inventory_open_change(open: bool)
signal tool_selected(tool_name: String)

@onready var hotbar = $Hotbar
@onready var inventory_menu = $InventoryMenu
@onready var tooltip = $Tooltip
@onready var drag_preview = $DragPreview

# Dictionary to store main components of user interface, so they
# can be easily accessed by name.
@onready var ui_element_table = {
	"Hotbar" : hotbar,
	"InventoryMenu" : inventory_menu,
}

var item_currently_picked_up = {}

var inventory_open : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect UI components posistion change functions to change signal. 
	hotbar.resized.connect(_hotbar_position_change)
	get_tree().root.size_changed.connect(_hotbar_position_change)
	inventory_menu.resized.connect(_inventory_menu_position_change)
	get_tree().root.size_changed.connect(_inventory_menu_position_change)
	
	# Connect hotbar signals to corrisponding functions.
	hotbar.slot_left_clicked.connect(_item_transfer)
	hotbar.slot_right_clicked.connect(_item_split)
	hotbar.show_tooltip.connect(_update_tooltip)
	hotbar.slot_changed.connect(_hotbar_slot_change)
	
	# Connect inventory menu signals to corrisponding functions.
	inventory_menu.slot_left_clicked.connect(_item_transfer)
	inventory_menu.show_tooltip.connect(_update_tooltip)
	inventory_menu.slot_right_clicked.connect(_item_split)
	
	# Set tooltip to hidden by default.
	_update_tooltip("", false)
	
	# Set inventory menu to hidden by default.
	inventory_menu.visible = !inventory_menu.visible
	inventory_open = false
	inventory_open_change.emit(inventory_open)


func _unhandled_input(event):
	if event.is_action_pressed("ui_menu"):
		if inventory_menu.visible and drag_preview.dragged_item: return
		inventory_menu.visible = !inventory_menu.visible
		inventory_open = !inventory_open
		inventory_open_change.emit(inventory_open)
		_hotbar_position_change()
		
	if event.is_action_pressed("HOTBAR_SELECT") and !inventory_open:
		hotbar.set_selected_slot(0, int(event.as_text())-1)
		_hotbar_slot_change(Vector2(0, int(event.as_text())-1))


# Updates player's tool to what is currently in the selected slot.
func _hotbar_slot_change(pos: Vector2):
	if pos == hotbar.selected_slot:
		if ItemDatabase.get_item_by_name(hotbar.slots[pos.x][pos.y].name).type == 2:
			tool_selected.emit(hotbar.slots[pos.x][pos.y].name)
		else:
			tool_selected.emit("None")


# Checks for inventory space and adds items if possible, then sets item drop targrt if added.
func _collect_item_drop(drop_item: Node3D, target: Node3D):
	var item_quantity : int  = 1
	item_quantity = hotbar.add_item(drop_item.item, item_quantity)
	if item_quantity > 0:
		item_quantity = inventory_menu.add_item(drop_item.item, item_quantity)
	
	if item_quantity == 0:
		drop_item.set_target(target)
	


# Function responsible for item selection and transfer between UI components.
func _item_transfer(pos, ui_element_name) -> void:
	var ui_element = ui_element_table.get(ui_element_name)
	var item_picked_up = ui_element.pickup_item(pos.x, pos.y)
	
	# Determines how to update a UI element's slot contents given players currently 
	# selected item and the item in the slot that was clicked. 
	if !item_currently_picked_up.is_empty():
		if item_picked_up.name == item_currently_picked_up.name:
			var new_quantity: int = item_picked_up.quantity + item_currently_picked_up.quantity
			var max_quantity: int = ItemDatabase.get_item_by_name(item_picked_up.name).max_stack_size
			
			if new_quantity <= max_quantity:
				item_picked_up.quantity += item_currently_picked_up.quantity
				item_currently_picked_up = {}
			else:
				item_currently_picked_up.quantity -= max_quantity - item_picked_up.quantity
				item_picked_up.quantity = max_quantity
			
			ui_element.place_item(item_picked_up, pos.x, pos.y)
			drag_preview.dragged_item = item_currently_picked_up
			
		elif item_picked_up.name == "Empty":
			ui_element.place_item(item_currently_picked_up, pos.x, pos.y)
			item_currently_picked_up = {}
			drag_preview.dragged_item = {}
		else:
			ui_element.place_item(item_currently_picked_up, pos.x, pos.y)
			item_currently_picked_up = item_picked_up
			drag_preview.dragged_item = item_currently_picked_up
	else:
		if item_picked_up.name == "Empty":
			item_currently_picked_up = {}
		else:
			item_currently_picked_up = item_picked_up
			drag_preview.dragged_item = item_currently_picked_up
	

# Function for item slitting and transfer between UI components.
func _item_split(pos, ui_element_name) -> void:
	var ui_element = ui_element_table.get(ui_element_name)
	var item_split = ui_element.split_item_stack(item_currently_picked_up, 
			pos.x, pos.y)
	item_currently_picked_up = item_split
	drag_preview.dragged_item = item_currently_picked_up


# Function to set hotbar position on screen.
func _hotbar_position_change() -> void:
	var viewport_size = get_viewport_rect().size
	var hotbar_size = hotbar.size
	var border_offset_y: int = 15
	var hotbar_gap_to_menu_y: int = 50
	
	if inventory_menu and inventory_menu.visible:
		hotbar.position = Vector2(inventory_menu.position.x, 
				inventory_menu.position.y + inventory_menu.size.y + hotbar_gap_to_menu_y)
	else:
		hotbar.position = Vector2(viewport_size.x/2 - hotbar_size.x/2, 
				viewport_size.y - hotbar_size.y - border_offset_y)


# Function to set inventory menu position on screen.
func _inventory_menu_position_change() -> void:
	var viewport_size = get_viewport_rect().size
	var inventory_menu_size = inventory_menu.size
	var border_offset_x = viewport_size.x / 8
	
	inventory_menu.position = Vector2(border_offset_x, 
			viewport_size.y/2 - inventory_menu_size.y/2)


# Function to update tooltip for item transfer.
func _update_tooltip(item_name: String, visible: bool) -> void:
	tooltip.visible = visible
	tooltip.display_info(item_name)
