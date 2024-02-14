class_name ArrowsRain
extends CharacterBody2D

@export var speed_modifier = 7.5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	velocity.y = speed_modifier * gravity * delta
	move_and_slide()
