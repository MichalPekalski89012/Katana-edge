extends CharacterBody2D


@onready var animation_player = $AnimationPlayer

@onready var state = PATROL

enum {
	PATROL,
	CHASE
}



func _physics_process(delta):

	match state:
		PATROL: patrol_state()
		CHASE: chase_state()



func patrol_state():
	pass

func chase_state():
	print("bede gonił gracza!!!")

func _on_attack_proximity_body_entered(body):
	animation_player.play("attack")
	print("spotkałem gracza!!!")


func _on_chase_proximity_body_entered(body):
	state = CHASE


func _on_chase_proximity_body_exited(body):
	state = PATROL
