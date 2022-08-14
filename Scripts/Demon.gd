extends KinematicBody2D

signal is_dead

var motion = Vector2.ZERO
var player:KinematicBody2D

export (Color) var color

export var particles_tscn:PackedScene

export var damage:float = 0.5 # Hearts
export var speed:int = 50
export var hp:int = 2
var gravity:int = 1200
var jump_force:int = -300

var angle_for_walk:float

var in_knockback:bool

# ------------------------------------------------------------------------------
func movement_control():
	if (!in_knockback):
		motion.x = $Sprite.scale.x * speed
		$AnimationPlayer.play('Run')
	else:
		$AnimationPlayer.play('Attack')

func animation_control():
	if (global_position.x > player.position.x):
		$Sprite.scale.x = -1
	else:
		$Sprite.scale.x = 1

func hit(_damage:int):
	var particle = particles_tscn.instance()
	particle.position = position
	particle.emitting = true
	particle.color = color
	
	hp -= _damage 
	
	get_parent().add_child(particle)

func knockback() -> void:
	in_knockback = true
	motion.x = -motion.x * 2.5
	$KnockbackTimer.start()

func attack_control() -> void:
	if $RayCastRight.is_colliding():
		if $RayCastRight.get_collider().is_in_group('Player'):
			player.hit(damage)
			knockback()

# ------------------------------------------------------------------------------
func _ready():
	add_to_group('Enemies')

	player = get_parent().get_node('Player')

func _process(_delta):
	animation_control()
	attack_control()

	if (hp <= 0): emit_signal("is_dead")
	
func _physics_process(delta):
	motion.y += gravity * delta
	
	movement_control()

	move_and_slide(motion)

# ------------------------------------------------------------------------------
func _on_KillArea_area_entered(area):
	if (area.name == "AttackArea"):
		hit(1)
		knockback()

func _on_Demon_is_dead():
	queue_free()

func _on_KnockbackTimer_timeout():
	in_knockback = false
