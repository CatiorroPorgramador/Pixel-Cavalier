extends Node2D

# Godot Functions
func _ready():
	pass

func _process(_delta:float) -> void:
	if $MainPlace.pressed:
		get_tree().change_scene("res://Scenes/Game.tscn")
	elif $Village.pressed:
		get_tree().change_scene("res://Scenes/Worlds/TheVillage.tscn")
