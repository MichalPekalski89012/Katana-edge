@tool
class_name Ladder
extends Area2D

@export var ladder_length = 5
var ladder_sprite = preload("res://obstacles/ladder/ladder_sprite.tscn")

@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_container = $SpriteContainer



func _ready():
	for n in ladder_length:
		var ladder_sprite_instance = ladder_sprite.instantiate()
		sprite_container.add_child(ladder_sprite_instance)
		ladder_sprite_instance.position = Vector2(0,-16 * n)
		collision_shape_2d.position.y = -8 * n
		collision_shape_2d.scale.y = n + 1

