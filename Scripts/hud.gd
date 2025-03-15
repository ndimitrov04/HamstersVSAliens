extends CanvasLayer

@onready var player = $"../Friendlies/Player"

@onready var player_data = $PlayerData
@onready var level_data = $LevelData
@onready var debug_data = $DebugData
@onready var crosshair = $Crosshair
@onready var hp_bar = $HPBar
@onready var hp_label = $HPLabel
@onready var gold = $Gold
@onready var buy_menu = $BuyMenu
@onready var level_up = $LevelUp
@onready var stats = $Stats
@onready var game_over = $GameOver
@onready var retry = $GameOver/Retry

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_retry_pressed():
	get_tree().reload_current_scene()
