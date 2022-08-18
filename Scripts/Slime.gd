extends KinematicBody2D

signal is_dead

export (Color) var color

var speed = 4000
var motion = Vector2()

export var particles_tscn:PackedScene

var gravity = 100
var collision

# ------------------------------------------------------------------------------
func movement_control(delta: float) -> void:
	if $RayCast.is_colliding():
		if $RayCast.get_collider().name == "TileMap":
			scale.x = -scale.x
	
	motion.x = -scale.y * speed
	
	move_and_slide(motion*delta)

func emit_particle() -> void:
	var particle = particles_tscn.instance()
	particle.position = position
	particle.emitting = true
	particle.color = color
	get_parent().add_child(particle)

# ------------------------------------------------------------------------------
func _ready():
	add_to_group('Enemies')
	add_to_group("Slimes")

func _physics_process(delta):
	motion.y += gravity
	
	movement_control(delta)

# ------------------------------------------------------------------------------
func _on_KillArea_area_entered(area):
	if (area.name == "AttackArea"):
		emit_signal("is_dead")

func _on_KillArea_body_entered(body):
	if (body.is_in_group("Player")):
		get_parent().get_node("Player").jump()
		emit_signal("is_dead")

func _on_Slime_is_dead():
	emit_particle()
	set_process(false)
	set_physics_process(false)
	$AnimationPlayer.play("Dead")

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Dead"):
		emit_particle()
		queue_free()
