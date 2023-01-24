extends Node3D
class_name Tool

# Tool properties
enum ToolType { PICKAXE, SWORD, HATCHET }
@export var damage : int
@export var type : ToolType
