extends CanvasLayer

var player:KinematicBody2D

func _ready() -> void:
	player = get_parent().get_node('Player')
	
	update_ui()

func _input(event) -> void:
	if event in InputEventScreenTouch or event is InputEventScreenDrag:
		if $Controls/JoyStick.is_pressed():
			$Controls/JoyStick/Arrow.look_at(event.position)
			player.angle_for_attack = $Controls/JoyStick/Arrow.rotation_degrees
			player.side = bool(event.position.x < 450)

func update_ui() -> void:
	$Life/Outline.rect_size = Vector2(player.max_hearts*16, 16)
	$Life/Hearts.rect_size = Vector2(player.hearts*16, 16)
