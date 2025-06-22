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

@onready var build_type : ObjectTypes.BUILDTYPE = ObjectTypes.BUILDTYPE.SHIELD

var tower = null

var upgraded : bool = false
var upgrade_cost_1 = 150
var upgrade_cost_2 = 70
var upgrade_description_1 = "Always regenerate shield"
var upgrade_description_2 = "50% Higher shield max HP"

func upgrade1():
	upgraded = true
	tower.b_model.material_override.albedo_color = Color("ff0909")
	shield_regen_timer.wait_time = 0.1
	shield_regen_timer.start(0.1)
	
func upgrade2():
	upgraded = true
	tower.b_model.material_override.albedo_color = Color("387248")
	max_shield = 1500
	shield = 1500

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
	hp -= damage
	explosion.amount = 256
	explosion.emitting = true
