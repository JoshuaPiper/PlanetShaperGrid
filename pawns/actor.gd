extends Node2D

enum CELL_TYPES{ ACTOR, OBSTACLE, OBJECT }
var type = CELL_TYPES.ACTOR
onready var Grid = get_parent()

func _ready():
	update_look_direction(Vector2(1, 0))

func _process(_delta):
	var input_direction = get_input_direction()
	if not input_direction:
		return
	update_look_direction(input_direction)

	var target_position = Grid.request_move(self, input_direction)
	if target_position:
		print(target_position)
		var floor_position = Grid.request_move(self, input_direction + Vector2(0, 1))
		move_to(target_position, floor_position)
	else:
		bump()

func get_input_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")), 0
	)

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
