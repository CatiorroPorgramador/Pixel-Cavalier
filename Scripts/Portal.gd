extends Area2D



# Godot Functions
func _ready():
	add_to_group("Portal")


func _on_Portal_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene("res://Scenes/ChangeScene.tscn")


func _on_Portal_body_exited(body):
	pass # Replace with function body.
