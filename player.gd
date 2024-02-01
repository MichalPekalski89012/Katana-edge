extends CharacterBody2D

@export_category("ground movement")
@export var acceleration = 250.0
@export var friction = 500.0
@export var max_speed = 150.0

@export_category("air movement")
@export var jump_velocity = -300.0
@export var air_resistance_value = 50.0

@onready var animated_sprite_2d = $AnimatedSprite2D


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		air_resistance(direction,delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

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

	move_and_slide()

func air_resistance(input_axis,delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, air_resistance_value * delta) 
	

