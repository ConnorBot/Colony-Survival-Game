extends Node

var items = Array()

func _ready():
	# Open items directory and get contents.
	var directory = DirAccess.open("res://src/resources/items")
	directory.list_dir_begin()
	
	# Loop through contents of items directory and save resource files to array.
	var filename = directory.get_next()
	while(filename):
		if not directory.current_is_dir() and filename.get_extension() == "tres":
			items.append(load("res://src/resources/items/%s" % filename))
		
		filename = directory.get_next()


# Finds and returns item in item array matching name input, else returns null. 
func get_item_by_name(item_name: String):
	for i in items:
		if i.name == item_name:
			return i
	
	return null
