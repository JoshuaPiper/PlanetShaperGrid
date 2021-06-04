extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT}

func _ready():
	for child in get_children():
		set_cellv(world_to_map(child.position), child.type)
		
func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return(node)

func request_move(pawn, direction, dryRun=false):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		EMPTY:
			if direction.y >= 1:
				# Recursive falling
				return request_move(pawn, direction + Vector2(0, 1))
			else:
				return update_pawn_position(pawn, cell_start, cell_target, dryRun)
		OBSTACLE:
			if direction.y >= 2:
				return update_pawn_position(pawn, cell_start + Vector2(direction.x, 0), 
											cell_target + Vector2(0, -1), dryRun)
		OBJECT:
			if direction.y >= 2:
				return update_pawn_position(pawn, cell_start + Vector2(direction.x, 0), 
											cell_target + Vector2(0, -1), dryRun)
			if direction.y == 0 and not dryRun:
				# If pushing an object, then move the box as well
				var object_pawn = get_cell_pawn(cell_target)
				if object_pawn.object_moved(direction) != -1:
					return update_pawn_position(pawn, cell_start, cell_target)

func update_pawn_position(pawn, cell_start, cell_target, dryRun=false):
	if not dryRun:
		set_cellv(cell_target, pawn.type)
		set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size / 2
