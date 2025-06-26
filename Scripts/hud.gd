extends CanvasLayer

@onready var ARCADE_GAME_POWER_UP_EPIC_STOCK_MEDIA_1_00_00 = preload("res://SFX/UI/arcade-game-power-up-epic-stock-media-1-00-00.mp3")
@onready var HOMINGSFX = preload("res://SFX/UI/mobile-game-smash-betacut-1-00-01.mp3")
@onready var DASHSFX = preload("res://SFX/UI/sci-fi-interface-menu-select-betacut-1-00-01.mp3")

@onready var player = $"../Friendlies/Player"
@onready var friendlies = $"../Friendlies"
@onready var enemies = $"../Enemies"
@onready var buy_spots = $"../BuySpots"
@onready var main = $".."
@onready var wave_timer = $"../NextWave"

@onready var shift_1_icon = $ComboBar/Shift1Icon
@onready var shift_2_icon = $ComboBar/Shift2Icon
@onready var rmb_icon = $ComboBar/RMBIcon

@onready var animation_player = $GameOver/AnimationPlayer
@onready var fade_out = $FadeOut

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
@onready var upgrade_menu = $UpgradeMenu
@onready var level_up = $LevelUp
@onready var stats = $Stats
@onready var next_wave = $NextWave
@onready var game_over = $GameOver
@onready var menu = $Menu
@onready var weapon_list = $WeaponList

@onready var enemy_list = $EnemyList

@onready var combo_sfx = $ComboBar/ComboSFX

@onready var comms = $Comms
@onready var comm_pic = $Comms/CommPic
@onready var comm_message = $Comms/CommMessage
@onready var comm_notification = $Comms/CommNotification

var dash_sfx_played = false
var homing_sfx_played = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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
		if not dash_sfx_played:
			combo_sfx.stream = DASHSFX
			combo_sfx.play()
			dash_sfx_played = true
			shift_1_icon.show()
			shift_2_icon.show()
	else:
		dash_sfx_played = false
		shift_1_icon.hide()
		shift_2_icon.hide()
		
	if player.combo > player.homing_cost:
		if not homing_sfx_played:
			combo_sfx.stream = HOMINGSFX
			combo_sfx.play()
			homing_sfx_played = true
			rmb_icon.show()
	else:
		homing_sfx_played = false
		rmb_icon.hide()

func _on_retry_pressed():
	get_tree().reload_current_scene()
