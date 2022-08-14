extends KinematicBody2D

signal is_dead


export var particles_tscn:PackedScene
var player:KinematicBody2D
export (Color) var color

export (int) var speed = 3000

var motion:Vector2 = Vector2()

var in_knowckback:bool = false

# Functions
func movement_control(delta:float) -> void:
	if !in_knowckback:
		motion = position.direction_to(player.position)
	
	move_and_slide(motion*speed*delta)

func emit_particle() -> void:
	var particle = particles_tscn.instance()
	particle.position = position
	particle.emitting = true
	particle.color = color
	get_parent().add_child(particle)

func knowckback() -> void:
	in_knowckback = true
	motion.x = -motion.x * 2.5
	motion.y = -motion.y * 2.5
	$KnockbackTime.start()

# Godot Functions
func _ready():
	player = get_parent().get_node('Player')
	add_to_group('Enemies')
	add_to_group('Ghosts')

func _physics_process(delta:float) -> void:
	movement_control(delta)

# Methods
func _on_KillArea_area_entered(area):
	if (area.name == 'AttackArea'):
		emit_signal('is_dead')

func _on_KillArea_body_entered(body):
	if body.is_in_group('Player'):
		body.hit(1)
		knowckback()

func _on_Ghost_is_dead():
	emit_particle()
	queue_free()

func _on_KnockbackTime_timeout():
	in_knowckback = false
