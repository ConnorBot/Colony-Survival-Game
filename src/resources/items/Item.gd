extends Resource
class_name ItemResource

# Item properties
enum ItemType { GENERIC, RESOURCE, EQUIPMENT, OBJECT }
@export var name : String
@export var stackable : bool = false
@export var max_stack_size : int = 1
@export var type : ItemType
@export var texture : Texture
@export var object : PackedScene
