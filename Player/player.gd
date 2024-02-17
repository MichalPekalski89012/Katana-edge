extends CharacterBody2D

@export_category("ground movement")
@export var acceleration = 250.0
@export var friction = 1500.0
@export var slide_friction = 15.0
@export var max_speed = 150.0

@export_category("air movement")
@export var jump_velocity = -300.0
@export var air_resistance_value = 150.0
@export var horizontal_air_boost = 250.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var jump_slide_timer = $JumpSlideTimer
@onready var animation_player = $AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0
var was_on_floor
var just_left_edge
var is_sliding

enum {
	RUN,
	CLIMB,
	SLIDE,
	JUMPSLIDE
}

var move_state = RUN

func _physics_process(delta):
	attack()
	if not is_on_floor():
		velocity.y += gravity * delta

	direction = Input.get_axis("left", "right")

	match move_state:
		RUN: run_state(direction,delta)
		CLIMB: climb_state()
		SLIDE: slide_state(delta)
		JUMPSLIDE: jump_slide_state()

func run_state(direction,delta):
	print("biegam!!!")
	jumping()
	if Input.is_action_pressed("down") and is_on_floor():
		jump_slide_timer.start()
		move_state = SLIDE

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

func climb_state():
	pass

func slide_state(delta):
	print("sliduje!!!")
	velocity.x = move_toward(velocity.x, 0, slide_friction * delta)
#	if Input.is_action_just_pressed("jump") and jump_slide_timer.time_left == 0.0:
#		move_state = RUN
#	elif Input.is_action_just_pressed("jump") and jump_slide_timer.time_left > 0.0:
#		move_state = JUMPSLIDE
#	elif Input.is_action_just_released("down"):
#		move_state = RUN
	if Input.is_action_just_released("down"):
		if Input.is_action_just_pressed("jump") and jump_slide_timer.time_left > 0.0:
			move_state = JUMPSLIDE
		else:
			move_state = RUN

	move_and_slide()

func jump_slide_state():
	print("JUMP sliduje!!!")
	


func air_resistance(input_axis,delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance_value * delta)

func jumping():
	if just_left_edge:
		coyote_jump_timer.start()
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity


func attack():
	if Input.is_action_pressed("attack") and not is_on_floor():
		animation_player.play("Player_high_attack")
		
	elif Input.is_action_pressed("attack") and is_sliding:
		animation_player.play("Player_low_attack")
		
	elif Input.is_action_pressed("attack"):
		animation_player.play("Player_mid_attack")
