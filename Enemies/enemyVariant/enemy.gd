extends CharacterBody2D


@onready var animation_player = $AnimationPlayer


func _on_attack_proximity_body_entered(body):
	animation_player.play("attack")
	print("spotkałem gracza!!!")
