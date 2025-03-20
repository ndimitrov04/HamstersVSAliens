extends CanvasLayer

@onready var player = $"../Friendlies/Player"

@onready var player_data = $PlayerData
@onready var level_data = $LevelData
@onready var debug_data = $DebugData
@onready var crosshair = $Crosshair
@onready var hp_bar = $HPBar
@onready var speed_bar = $SpeedBar
@onready var overheat_bar = $OverheatBar
@onready var hp_label = $HPLabel
@onready var gold = $Gold
@onready var buy_menu = $BuyMenu
@onready var level_up = $LevelUp
@onready var stats = $Stats
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

func _on_retry_pressed():
	get_tree().reload_current_scene()
