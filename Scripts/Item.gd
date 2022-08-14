extends RigidBody2D

var item

# ------------------------------------------------------------------------------
func set_item(new_item):
	self.item = new_item
	$Slot.texture = self.item

func set_texture(new_texture):
	$Slot.texture = new_texture

# ------------------------------------------------------------------------------
func _ready():
	add_to_group("Items")
	$InteractNode/Label.visible = false

func _process(_delta):
	if (get_parent().get_node("Player").can_get and $InteractNode/Label.visible):
		get_parent().get_node("Player").inventory.append(self.item)
		get_parent().get_node("Player").update_inventory()
		queue_free()

# ------------------------------------------------------------------------------
func _on_InteractArea_body_entered(body):
	$InteractNode/Label.visible = body.is_in_group("Player")

func _on_InteractArea_body_exited(body):
	$InteractNode/Label.visible = !body.is_in_group("Player")
