extends Node2D

enum CELL_TYPES{ EMPTY = -1, ACTOR, OBSTACLE, OBJECT }
var type = CELL_TYPES.EMPTY
onready var Grid = get_parent()
