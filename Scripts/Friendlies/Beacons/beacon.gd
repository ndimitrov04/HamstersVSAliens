extends RigidBody3D

@onready var model = $Model

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

@onready var max_hp : int = get_meta("hp")
@onready var hp : int = get_meta("hp")
@onready var fallpoint : int = get_meta("fallpoint")
@onready var max_shield : int = get_meta("shield")
@onready var shield : int = get_meta("shield")
@onready var shield_regen : bool = false
@onready var shield_regen_timer = $ShieldRegenTimer

@onready var boost_area = $BoostArea

@onready var type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLY
@onready var build_spot = null

@onready var build_type : ObjectTypes.BUILDTYPE = ObjectTypes.BUILDTYPE.SPEEDBOOST

var tower = null

var upgraded : bool = false
var upgrade_cost_1 = 35
var upgrade_cost_2 = 55
var upgrade_description_1 = "10% Faster acceleration"
var upgrade_description_2 = "50% Bigger AOE"

func upgrade1():
	upgraded = true
	tower.b_model.material_override.albedo_color = Color("ff0909")
	boost_area.boosted_boost = 1.2
	
func upgrade2():
	upgraded = true
	tower.b_model.material_override.albedo_color = Color("387248")
	boost_area.supportbox.shape.radius = 300
	boost_area.area_viewer.size.x = 800
	boost_area.area_viewer.size.z = 800
	

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.2).timeout
	position += Vector3(0,10,0)
	rotation = Vector3(0,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if hp > max_hp:
		hp = max_hp
	
	if hp <= 0:
		build_spot.building = null
		queue_free()

func take_damage(damage : int, explosion = EXPLOSION.instantiate()):
	add_sibling(explosion)
	explosion.global_position = global_position
	shield_regen = false
	shield_regen_timer.start()
	if shield <= 0:
		hp -= damage
		explosion.amount = 256
		explosion.emitting = true
	else:
		shield -= damage
		explosion.amount = 64
		explosion.emitting = true

func _on_shield_regen_timer_timeout():
	shield_regen = true

func _on_shield_regen_tick_timeout():
	if shield_regen:
		shield += 10
