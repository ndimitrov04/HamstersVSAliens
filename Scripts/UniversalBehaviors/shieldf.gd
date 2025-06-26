extends Area3D

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

@onready var model = $Model
@onready var model_inside = $ModelInside

@onready var shield_regen_tick = $ShieldRegenTick
@onready var shield_regen_timer = $ShieldRegenTimer

@onready var shieldHP : int = get_parent().get_meta("shield")
@onready var max_shieldHP : int = get_parent().get_meta("shield")
@onready var shield_regen : bool = false
@onready var block_type : ObjectTypes.TYPE = ObjectTypes.TYPE.BULLET

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if shieldHP <= 0:
		shieldHP = 0
		model.hide()
		model_inside.hide()
		monitoring = false
	else:
		model.show()
		model_inside.show()
		monitoring = true
		
	if shieldHP > max_shieldHP:
		shieldHP = max_shieldHP

func _on_body_entered(body):
	print("hit")
	if "type" in body:
		print("hitbody has type")
		if body.type == block_type:
			var explosion = EXPLOSION.instantiate()
			add_sibling(explosion)
			explosion.global_position = body.global_position
			explosion.amount = 256
			explosion.explosiveness = 0.9
			explosion.emitting = true
			print("hitbody has correct block type")
			body.queue_free()
			shield_regen = false
			shieldHP -= body.damage

func _on_shield_regen_timer_timeout():
	shield_regen = true

func _on_shield_regen_tick_timeout():
	print(shield_regen)
	if shield_regen:
		shieldHP += 10
