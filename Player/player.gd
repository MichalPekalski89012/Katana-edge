class_name Player
extends CharacterBody2D

@export_category("ground movement")
@export var acceleration = 250.0
@export var friction = 1500.0
@export var slide_friction = 50.0
@export var max_speed = 150.0

@export_category("air movement")
@export var jump_velocity = -300.0
@export var air_resistance_value = 350.0
@export var horizontal_air_boost = 250.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var jump_slide_timer = $JumpSlideTimer
@onready var animation_player = $AnimationPlayer
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox
@onready var ladder_checker = $LadderChecker


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var horizontal_direction = 0
var vertical_direction = 0
var was_on_floor
var just_left_edge
var horizontal_direction_before_slide

enum {
	RUN,
	CLIMB,
	SLIDE,
	JUMP,
	JUMPSLIDE
}

var move_state = RUN

func _physics_process(delta):
	attack(horizontal_direction)
	apply_gravity(delta)
	
	horizontal_direction = Input.get_axis("left", "right")
	vertical_direction = Input.get_axis("jump","down") 
	match move_state:
		RUN: run_state(horizontal_direction,delta)
		CLIMB: climb_state(vertical_direction,horizontal_direction)
		SLIDE: slide_state(delta,horizontal_direction)
		JUMP: jump_state(delta)
		JUMPSLIDE: jump_slide_state(horizontal_direction,delta)

func run_state(horizontal_direction,delta):
	hurtbox.collision_layer = 2048
	hurtbox.collision_mask = 16384

	if is_on_ladder() and Input.is_action_pressed("jump"): move_state = CLIMB
	
	if just_left_edge:
		coyote_jump_timer.start()

	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_jump_timer.time_left > 0.0:
			velocity.y = jump_velocity
			velocity.x = velocity.x
			move_state = JUMP

	if Input.is_action_pressed("down") and is_on_floor():
		jump_slide_timer.start()
		horizontal_direction_before_slide = horizontal_direction
		move_state = SLIDE

	if horizontal_direction:
		if horizontal_direction == -1:
			animated_sprite_2d.play("run_left")
		else:
			animated_sprite_2d.play("run_right")
		velocity.x = move_toward(velocity.x, max_speed * horizontal_direction, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		animated_sprite_2d.play("idle")
		
	was_on_floor = is_on_floor()
	move_and_slide()
	just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0

func climb_state(vertical_horizontal_direction,horizontal_direction):
	velocity.y = 50 * vertical_direction
	if horizontal_direction or not is_on_ladder():
		move_state = RUN
	move_and_slide()

func slide_state(delta,horizontal_direction):
	hurtbox.collision_layer = 1024
	hurtbox.collision_mask = 8192
	velocity.x = move_toward(velocity.x, 0, slide_friction * delta)

	if Input.is_action_just_pressed("jump") and jump_slide_timer.time_left > 0.0:
		velocity.x = max_speed * horizontal_direction * 2
		velocity.y = jump_velocity
		move_state = JUMPSLIDE
		
	elif Input.is_action_just_pressed("jump") and jump_slide_timer.time_left == 0.0:
		move_state = RUN
	#na ten moment to musi wystarczyc jesli chodzi o cancelowanie SLIDE:
	elif horizontal_direction != horizontal_direction_before_slide:
		move_state = RUN

	move_and_slide()

func jump_slide_state(horizontal_direction,delta):
	hurtbox.collision_layer = 4096
	hurtbox.collision_mask = 32768
	if not is_on_floor():
		apply_gravity(delta)
		move_and_slide()
	else:
		move_state = RUN

	


func air_resistance(delta):
	if not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance_value * delta)

func jump_state(delta):
	hurtbox.collision_layer = 4096
	hurtbox.collision_mask = 32768
	if is_on_floor():
		move_state = RUN

	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func attack(horizontal_direction):
	if Input.is_action_just_pressed("attack"):
		if horizontal_direction == 1:
			hitbox.position.x = 19
		elif horizontal_direction == -1:
			hitbox.position.x = -19

		if not is_on_floor():
			animation_player.play("Player_high_attack")
		elif move_state==SLIDE:
			animation_player.play("Player_low_attack")
		else:
			animation_player.play("Player_mid_attack")

func is_on_ladder():
	if not ladder_checker.is_colliding(): return false
	var collider = ladder_checker.get_collider()
	if not collider is Ladder: return false
	return true

func _on_hurtbox_area_entered(area):
	print("umarlem")
	GameManager.player_died.emit()



