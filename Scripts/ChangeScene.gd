extends Node2D

# Godot Functions
func _ready():
	pass

func _process(delta:float) -> void:
	if $MainPlace.pressed:
		get_tree().change_scene("res://Scenes/Game.tscn")
	elif $Village.pressed:
		get_tree().change_scene("res://Scenes/Worlds/TheVillage.tscn")
	elif $VillageBattle.pressed:
		get_tree().change_scene("res://Scenes/Worlds/BattleVillage.tscn")
