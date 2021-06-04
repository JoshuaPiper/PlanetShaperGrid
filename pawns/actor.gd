extends Node2D

enum CELL_TYPES{ EMPTY = -1, ACTOR, OBSTACLE, OBJECT }
var type = CELL_TYPES.ACTOR
var last_direction = 1 # 1 is right, -1 is left
onready var Grid = get_parent()

func _ready():
	update_look_direction(Vector2(last_direction, 0))

func _process(_delta):
	var input_direction = get_input_direction()
	if input_direction.x != 0:
		if input_direction.x != last_direction:
			# Only change direction without move if turning around
			last_direction = input_direction.x
			update_look_direction(Vector2(last_direction, 0))
		else:
			input_direction = Vector2(input_direction.x, 0)
			var target_position = Grid.request_move(self, input_direction)
			if target_position:
				# Determine if actor is falling
				var floor_position = Grid.request_move(self, input_direction + Vector2(0, 1))
				if floor_position:
					print(floor_position)
				else:
					print(target_position)
				move_to(target_position, floor_position)
			else:
				bump()
	elif input_direction.y != 0:
		input_direction = Vector2(0, input_direction.y)
		# Make sure to:
		# - No object above you
		# - No object in the final destination of the jump
		# - Have an object in your direction (so you need to climb on it)
		# Use dryRun to not actually move or push anything
		if Grid.get_cell_type(self, input_direction) == CELL_TYPES.EMPTY and \
		   Grid.get_cell_type(self, input_direction + Vector2(last_direction, 0)) == CELL_TYPES.EMPTY and \
		   Grid.get_cell_type(self, Vector2(last_direction, 0)) != CELL_TYPES.EMPTY:
			var target_position = Grid.request_move(self, input_direction, true)
			var floor_position = Grid.request_move(self, input_direction + Vector2(last_direction, 0))
			move_to(target_position, floor_position)
			print(floor_position)
		else:
			bump()
	elif get_input_grab() == 1:
		if Grid.get_cell_type(self, Vector2(last_direction, 0)) == CELL_TYPES.OBJECT:
			var obj_pawn = Grid.get_cell_pawn(Grid.get_cell_pos(self, Vector2(last_direction, 0)))
			input_direction = Vector2(0 - last_direction, 0)
			var target_position = Grid.request_move(self, input_direction)
			if target_position:
				# Determine if actor is falling
				var floor_position = Grid.request_move(self, input_direction + Vector2(0, 1))
				if floor_position:
					print(floor_position)
				else:
					print(target_position)
				move_to(target_position, floor_position)
				obj_pawn.object_moved(input_direction)
			else:
				bump()
		else:
			bump()
			

func get_input_direction():
	return Vector2(
		int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_pressed("ui_left")),
		int(0 - int(Input.is_action_just_pressed("ui_up")))
	)
	
func get_input_grab():
	return int(Input.is_action_just_pressed("ui_grab"))

func update_look_direction(direction):
	$Sprite.rotation = direction.angle()

func move_to(target_position, floor_position):
	set_process(false)
	$AnimationPlayer.play("walk")

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - position).normalized()
		
	$Tween.interpolate_property(
		self,"position",
		position,target_position,
		$AnimationPlayer.current_animation_length,
		Tween.TRANS_LINEAR, Tween.EASE_IN)

	$Tween.start()

	# Stop the function execution until the animation finished
	yield($AnimationPlayer, "animation_finished")
	
	if floor_position:
		$AnimationPlayer.play("walk")

		# Move the node to the target cell instantly,
		# and animate the sprite moving from the start to the target cell
		move_direction = (floor_position - position).normalized()
			
		$Tween.interpolate_property(
			self,"position",
			position,floor_position,
			$AnimationPlayer.current_animation_length,
			Tween.TRANS_LINEAR, Tween.EASE_IN)

		$Tween.start()

		# Stop the function execution until the animation finished
		yield($AnimationPlayer, "animation_finished")	
	
	set_process(true)


func bump():
	set_process(false)
	$AnimationPlayer.play("bump")
	yield($AnimationPlayer, "animation_finished")
	set_process(true)
