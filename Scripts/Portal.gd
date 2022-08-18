extends RayCast2D

export (String) var scene_to

# Godot Functions
func _ready():
	add_to_group("Portal")

func _process(delta:float) -> void:
	$Label.visible = self.is_colliding()
	
	if self.is_colliding() and self.get_collider().is_in_group("Player"):
		if self.get_collider().get("can_get"):
			get_tree().change_scene(scene_to)
