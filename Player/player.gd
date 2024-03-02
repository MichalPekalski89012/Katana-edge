extends CharacterBody2D

@export_category("ground movement")
@export var acceleration = 250.0
@export var friction = 1500.0
@export var slide_friction = 100.0
@export var max_speed = 150.0

@export_category("air movement")
@export var jump_velocity = -300.0
@export var air_resistance_value = 350.0
@export var horizontal_air_boost = 250.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var jump_slide_timer = $JumpSlideTimer
@onready var animation_player = $AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0
var was_on_floor
var just_left_edge
var just_slided = false

enum {
	RUN,
	CLIMB,
	SLIDE,
	JUMPSLIDE
}

var move_state = RUN

func _physics_process(delta):
#	print("Velocity.x:",velocity.x)
	attack()
	apply_gravity(delta)
	direction = Input.get_axis("left", "right")

	match move_state:
		RUN: run_state(direction,delta)
		CLIMB: climb_state()
		SLIDE: slide_state(delta)
		JUMPSLIDE: jump_slide_state(direction,delta)

func run_state(direction,delta):
	jumping()
	air_resistance(delta)
	if Input.is_action_pressed("down") and is_on_floor() and not just_slided:
		jump_slide_timer.start()
		move_state = SLIDE

	just_slided = false

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

	if Input.is_action_just_pressed("jump") and jump_slide_timer.time_left > 0.0:
		velocity.x = max_speed * direction * 2
		velocity.y = jump_velocity
		move_state = JUMPSLIDE
	elif Input.is_action_just_released("down") and jump_slide_timer.time_left == 0.0:
		just_slided = true
		move_state = RUN
		print(jump_slide_timer.time_left)

	move_and_slide()

func jump_slide_state(direction,delta):
	print("JUMP sliduje!!!")
	if not is_on_floor():
		apply_gravity(delta)
		move_and_slide()
	else:
		move_state = RUN

	


func air_resistance(delta):
	if not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance_value * delta)

func jumping():
	if just_left_edge:
		coyote_jump_timer.start()
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func attack():
	if Input.is_action_pressed("attack") and not is_on_floor():
		animation_player.play("Player_high_attack")
		
	elif Input.is_action_pressed("attack") and move_state==SLIDE:
		animation_player.play("Player_low_attack")
		
	elif Input.is_action_pressed("attack"):
		animation_player.play("Player_mid_attack")


func _on_hurtbox_area_entered(area):
	print("zabili mnie!")
