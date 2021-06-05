extends Node2D

enum CELL_TYPES{ EMPTY = -1, ACTOR, OBSTACLE, OBJECT }
enum ELEMENT_TYPES{ Q = -1, EARTH, WATER, FIRE, WIND }
var type = CELL_TYPES.OBJECT

onready var Grid = get_parent()
	
func object_moved(input_direction):
	# Prevent pushing two or more objects in a row
	if Grid.get_cell_type(self, input_direction) == CELL_TYPES.EMPTY:
		# Same logic as the actor move and fall
		var target_position = Grid.request_move(self, input_direction)
		if target_position:
			var floor_position = Grid.request_move(self, input_direction + Vector2(0, 1))
			move_to(target_position, floor_position)
		else:
			return -1
	else:
		return -1
	
func move_to(target_position, floor_position=null):
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
