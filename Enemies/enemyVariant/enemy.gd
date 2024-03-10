extends CharacterBody2D


@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var switch_side_timer = $SwitchSideTimer

@onready var state = PATROL

 

enum {
	PATROL,
	CHASE
}

var player
var direction := Vector2.ZERO




func _ready():
	direction.x = 1.0

func _physics_process(delta):
	match state:
		PATROL: patrol_state()
		CHASE: chase_state()



func patrol_state():
	velocity.x = move_toward(velocity.x, 50 * direction.x, 10)
	
	move_and_slide()

func chase_state():
	#uwzglednic skakanie przeciwnika!!!
	direction = global_position.direction_to(player.global_position)
	sprite_2d.flip_h = direction.x < 0
	velocity.x = 50 * direction.x
	move_and_slide()

func _on_attack_proximity_body_entered(body):
	animation_player.play("attack")
	print("spotkałem gracza!!!")


func _on_chase_proximity_body_entered(body):
	state = CHASE
	player = body
	


func _on_chase_proximity_body_exited(body):
	state = PATROL


func _on_switch_side_timer_timeout():
	direction.x -= direction.x+1
	print(direction.x)
