class_name SkillData
extends Resource

enum Branch { FIRE, WIND, ICE, EXPLORE }

@export var id: StringName
@export var branch: Branch
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var cost: int = 1
@export var requires: Array[SkillData] = []      
@export var grants: Array[StringName] = []       
@export var stat_bonus: Dictionary = {}            
@export var tree_position: Vector2                 
