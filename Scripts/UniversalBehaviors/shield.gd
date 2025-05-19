extends Area3D

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

@onready var model = $Model
@onready var hitbox = $Hitbox
@onready var shield_regen_tick = $ShieldRegenTick
@onready var shield_regen_timer = $ShieldRegenTimer

@onready var shieldHP : int = get_parent().get_meta("shield")
@onready var max_shieldHP : int = get_parent().get_meta("shield")
@onready var shield_regen : bool = false
@onready var block_type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLYBULLET

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if shieldHP <= 0:
		shieldHP = 0
		model.hide()
		monitoring = false
	else:
		model.show()
		monitoring = true
		
	if shieldHP > max_shieldHP:
		shieldHP = max_shieldHP

func _on_body_entered(body):
	if "type" in body:
		if body.type == block_type:
			body.queue_free()
			shield_regen = false
			shieldHP -= body.damage
			var explosion = EXPLOSION.instantiate()
			add_sibling(explosion)
			explosion.global_position = global_position
			explosion.amount = 64
			explosion.emitting = true

func _on_shield_regen_timer_timeout():
	if "alive" in get_parent():
		if get_parent().alive:
			shield_regen = true

func _on_shield_regen_tick_timeout():
	if shield_regen:
		shieldHP += 10
