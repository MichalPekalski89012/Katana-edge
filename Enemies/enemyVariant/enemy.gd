extends CharacterBody2D


@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var switch_side_timer = $SwitchSideTimer
@onready var enemy_hitbox = $EnemyHitbox


@onready var state = PATROL

 

enum {
	PATROL,
	CHASE
}

var player
var direction := Vector2.ZERO
var will_flip = false


func _ready():
	direction.x = 1.0

func _physics_process(delta):
	match state:
		PATROL: patrol_state()
		CHASE: chase_state()



func patrol_state():
	if not will_flip:
		velocity.x = move_toward(velocity.x, 50, 10)
	else:
		velocity.x = move_toward(velocity.x, -50, 10)
	move_and_slide()

func chase_state():
	var normalized_velocity = velocity.normalized()
	direction = global_position.direction_to(player.global_position)
	if normalized_velocity.x == 1:
		enemy_hitbox.position.x = 24
	elif normalized_velocity.x == -1:
		enemy_hitbox.position.x = -24
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
	will_flip = !will_flip
	switch_side_timer.start()
