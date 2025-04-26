extends CanvasLayer

@onready var player = $"../Friendlies/Player"
@onready var friendlies = $"../Friendlies"
@onready var enemies = $"../Enemies"
@onready var buy_spots = $"../BuySpots"
@onready var main = $".."
@onready var wave_timer = $"../NextWave"

@onready var shift_1_icon = $ComboBar/Shift1Icon
@onready var shift_2_icon = $ComboBar/Shift2Icon
@onready var rmb_icon = $ComboBar/RMBIcon

@onready var player_data = $PlayerData
@onready var level_data = $LevelData
@onready var debug_data = $DebugData
@onready var game_info = $GameInfo
@onready var crosshair = $Crosshair
@onready var hp_bar = $HPBar
@onready var speed_bar = $SpeedBar
@onready var speed_limit = $SpeedLimit
@onready var overheat_bar = $OverheatBar
@onready var combo_bar = $ComboBar
@onready var hp_label = $HPLabel
@onready var gold = $Gold
@onready var buy_menu = $BuyMenu
@onready var level_up = $LevelUp
@onready var stats = $Stats
@onready var next_wave = $NextWave
@onready var game_over = $GameOver
@onready var retry = $GameOver/Retry
@onready var menu = $Menu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if not menu.visible:
			menu.show()
		else:
			menu.hide()
			menu.graphics_menu.hide()
	update_player_info()
	if not wave_timer.is_stopped():
		next_wave.text = "Next wave coming in: " + str(int(wave_timer.time_left))

func update_game_info():
	await get_tree().create_timer(0.2).timeout
	var enemy_count : int = 0
	for object in enemies.get_children():
		if "type" in object:
			if object.type == ObjectTypes.TYPE.ENEMY:
				enemy_count += 1
	game_info.text = "Enemies Left: " + str(enemy_count) + "\nCurrent Wave: " + str(main.current_wave)

func update_player_info():
	hp_bar.max_value = player.max_hp
	hp_bar.value = lerp(hp_bar.value, float(player.hp), 0.1)
	hp_label.text = str(int(lerp(hp_bar.value, float(player.hp), 0.1)))
	#speed_bar.max_value = player.MAXVELOCITY * player.speedboost
	speed_bar.value = lerp(speed_bar.value, max(abs(player.linear_velocity.x), abs(player.linear_velocity.z)), 0.05)
	speed_limit.value = lerp(speed_limit.value, player.MAXVELOCITY + player.combo / 10, 0.05)
	overheat_bar.value = lerp(overheat_bar.value, float(player.heat), 0.1)
	combo_bar.value = lerp(combo_bar.value, float(player.combo), 0.1)
	crosshair.value = ((player.homing_cooldown.wait_time - player.homing_cooldown.time_left) / player.homing_cooldown.wait_time) * 100
	gold.text = "HamsterCoins: " + str(player.gold)
	
	if player.combo > player.dash_cost:
		#play sound
		shift_1_icon.show()
		shift_2_icon.show()
	else:
		shift_1_icon.hide()
		shift_2_icon.hide()
		
	if player.combo > player.homing_cost:
		#play sound
		rmb_icon.show()
	else:
		rmb_icon.hide()

func _on_retry_pressed():
	get_tree().reload_current_scene()
