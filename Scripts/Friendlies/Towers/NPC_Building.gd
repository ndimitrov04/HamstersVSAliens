extends RigidBody3D

@onready var lower_detail = $Model/LowerDetail
@onready var base_hitbox = $BaseHitbox
@onready var drop_sfx = $DropSFX
@onready var main = $"../.."
@onready var damage_taken = $DamageTaken
@onready var player = $"../Player"
@onready var distress_ping = $DistressPing
@onready var danger_indicators = $"../../HUD/Crosshair/DangerIndicators"

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")
@onready var DANGER_POINTER = preload("res://Scenes/HUD/danger_pointer.tscn")

@onready var max_hp : int = get_meta("hp")
@onready var hp : int = get_meta("hp")
@onready var fallpoint : int = get_meta("fallpoint")
@onready var pointer = null

@onready var type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLY
@onready var build_spot = null
@onready var npc_building = true

signal base_exploded

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("base_exploded", _on_base_exploded)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if hp > max_hp:
		hp = max_hp
	
	if hp <= fallpoint:
		if lower_detail:
			detach_base()
		axis_lock_linear_x = false
		axis_lock_linear_y = false
		axis_lock_linear_z = false
		axis_lock_angular_x = false
		axis_lock_angular_y = false
		axis_lock_angular_z = false
	if hp <= 0:
		#build_spot.building = null
		queue_free()
		
	if hp >= 0 and not damage_taken.is_stopped():
		distress_ping.look_at(player.global_position, Vector3.UP, true)

func take_damage(damage : int, explosion = EXPLOSION.instantiate()):
	visual_explosion(self, explosion)
	hp -= damage
	damage_taken.start()
	if pointer == null:
		pointer = DANGER_POINTER.instantiate()
		danger_indicators.add_child(pointer)
		pointer.point_direction = distress_ping
	
func visual_explosion(detail, explosion = EXPLOSION.instantiate()):
	if detail != null:
		detail.add_sibling(explosion)
		explosion.global_position = global_position
		explosion.amount = 256
		explosion.emitting = true
		if detail == lower_detail:
			emit_signal("base_exploded")

func detach_base():
	visual_explosion(lower_detail)

func _on_base_exploded():
	lower_detail.queue_free()
	base_hitbox.queue_free()

func _on_body_entered(body):
	if body.name == "HTerrain":
		drop_sfx.play()

func _on_damage_taken_timeout():
	if pointer:
		pointer.queue_free()
