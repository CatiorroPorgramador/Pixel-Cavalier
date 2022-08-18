extends KinematicBody2D

signal is_dead

# Constants
const const_gravity:int = 30000
const const_jump_force:int = -250

# Variables
export var item_tscn:PackedScene

var items = {
	"Knife": {
		"texture": preload("res://Data/Weapons/weapon_knife.png"),
		"hit pos": Vector2.ZERO,
		"damage": 20,
	},
	"Axe": {
		"texture": preload("res://Data/Weapons/weapon_axe.png"),
		"hit pos": Vector2.ZERO,
		"damage": 40,
	},
	"Hammer": {
		"texture": preload("res://Data/Weapons/weapon_knife.png"),
		"hit pos": Vector2.ZERO,
		"damage": 60,
	}
}

var motion:Vector2 = Vector2()
export (int) var hearts = 3
export (int) var max_hearts = 3
export (int) var speed = 6000
export (int) var damage = 1
export (int) var dash_speed = 20000
var index_item:int = 0
var gravity:int = const_gravity

var jump_force:int = -15000
var jump_cout:int = 2

var angle_for_attack:float
var side:bool = false # false = left | right = true

onready var inventory_canvas = [
	get_node("UI/Inventory/Slot1"),
	get_node("UI/Inventory/Slot2"),
]
onready var inventory_canvas_slots = [
	get_node("UI/Inventory/Slot1/Sprite"),
	get_node("UI/Inventory/Slot2/Sprite"),
]

var inventory = [
	preload("res://Data/Weapons/weapon_knife.png"),
	preload("res://Data/Weapons/weapon_hammer.png")
]

var can_get:bool = false
var in_dash:bool = false
var dash_to:int

# ------------------------------------------------------------------------------
func movement_control(delta: float) -> void:
	if not in_dash:
		motion.x = (int(Input.is_action_pressed('ui_right')) - int(Input.is_action_pressed("ui_left"))) * speed
	else:
		motion.x = dash_speed * dash_to
	
	if is_on_wall(): in_dash = false
	
	if Input.is_action_just_pressed("ui_jump"): jump()
	
	elif Input.is_action_just_pressed("ui_dash"): dash()
	
	move_and_slide(motion*delta, Vector2.UP)

func climb_control() -> void:
	if is_on_wall() and not motion.y < 0:
		gravity = 1000
	else:
		gravity = const_gravity

func attack_control() -> void:
	if $RayCastAttack.is_colliding():
		if range(inventory.size()).has(index_item): $Gun/AnimationPlayer.play("Attack")

func inventory_control() -> void:
	if (Input.is_action_just_pressed("ui_drop_item")):
		drop_item()
		
		update_inventory()

	elif (Input.is_action_just_pressed("ui_select_item_1")):
		index_item = 0
		update_inventory()

	elif (Input.is_action_just_pressed("ui_select_item_2")):
		index_item = 1
		update_inventory()

	if (Input.is_action_just_pressed("ui_interact")): can_get = true
	else: can_get = false

func drop_item() -> void:
	update_inventory()

	if (inventory.size() >= 1):
		var item = item_tscn.instance()
		item.position = Vector2(position.x, position.y-20)
		item.item = inventory[index_item]
		item.set_texture(inventory[index_item])
		
		get_parent().add_child(item)
		
		inventory.pop_at(index_item)
		index_item -= 1
	
	update_inventory()

func hit(_damage:float) -> void:
	hearts -= _damage
	update_ui()

func update_inventory() -> void:
	if (!inventory.size() <= 0 and range(inventory.size()).has(index_item)):
		$Gun/Sprite.texture = inventory[index_item]
	else:
		$Gun/Sprite.texture = null
		index_item = 0

	for slot in inventory_canvas_slots:
		slot.texture = null

	for index_slot in inventory.size():
		var slot = inventory_canvas_slots[index_slot]
		var item = inventory[index_slot]

		slot.texture = item

func update_ui() -> void:
	get_node('UI').update_ui()

func weapon_stuff() -> void:
	$Gun.rotation_degrees = angle_for_attack
	$RayCastAttack.rotation_degrees = $Gun.rotation_degrees - 90
	$Sprite.flip_h = side
	
	if side: $Gun.scale.y = -1
	else: $Gun.scale.y = 1

func animation_control() -> void:
	if not is_on_floor() and is_on_wall() and not in_dash:
		$Sprite.flip_h = is_on_wall_left()
		$AnimationPlayer.play("Climb")
	
	elif motion.x and is_on_floor():
		$AnimationPlayer.play("Run")
	
	elif motion.y and not is_on_wall() and not is_on_floor() and not in_dash:
		$AnimationPlayer.play("Fall")
		
	elif !motion.x and is_on_floor() and not in_dash:
		$AnimationPlayer.play("Idle")
	
	if Input.is_action_just_pressed("ui_dash"):
		$AnimationPlayer.play("Dash")
	
	if is_on_wall(): side = !is_on_wall_left()

func jump() -> void:
	if jump_cout:
		if is_on_wall(): motion.x = int(float(side) - 0.5)-1
		
		motion.y = jump_force
		jump_cout -= 1

func dash() -> void:
	in_dash = true
	dash_to = -(float($Sprite.flip_h) - 0.5)*2
	$DashTimer.start()

func is_on_wall() -> bool:
	return $ClimbLeft.is_colliding() or $ClimbRight.is_colliding()

func is_on_wall_left() -> bool:
	return $ClimbLeft.is_colliding()

func is_on_wall_right() -> bool:
	return $ClimbRight.is_colliding()

# ------------------------------------------------------------------------------
func _ready():
	add_to_group("Player")
	inventory_canvas[index_item].frame = 1
	
	update_inventory()

func _process(_delta:float) -> void:
	animation_control()
	attack_control()
	weapon_stuff()
	inventory_control()
	
	if hearts <= 0:
		emit_signal('is_dead')
	
	if is_on_floor() or is_on_wall():
		jump_cout = 2

func _physics_process(delta: float) -> void:
	motion.y += gravity * delta
	
	if is_on_floor():
		motion.y = 0
	
	if is_on_ceiling():
		motion.y = 1000
	
	movement_control(delta)
	climb_control()

func _on_DashTimer_timeout():
	in_dash = false

func _on_Player_is_dead():
	pass
