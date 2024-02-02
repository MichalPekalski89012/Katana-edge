extends CharacterBody2D

@export_category("ground movement")
@export var acceleration = 250.0
@export var friction = 1500.0
@export var max_speed = 150.0

@export_category("air movement")
@export var jump_velocity = -300.0
@export var air_resistance_value = 150.0
@export var horizontal_air_boost = 250.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0
var was_on_floor
var just_left_edge

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		air_resistance(direction,delta)

	jumping()

	direction = Input.get_axis("left", "right")
	
	if direction:
		if direction == -1:
			animated_sprite_2d.play("run_left")
		else:
			animated_sprite_2d.play("run_right")
		velocity.x = move_toward(velocity.x, max_speed * direction, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		animated_sprite_2d.play("idle")
		
	was_on_floor = is_on_floor()
	move_and_slide()
	just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0

func air_resistance(input_axis,delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance_value * delta)

func jumping():
	if just_left_edge:
		coyote_jump_timer.start()
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		
