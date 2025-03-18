extends Panel

@onready var upgrade_1 = $Upgrade1
@onready var u_name_1 = $Upgrade1/UName1
@onready var u_description_1 = $Upgrade1/UDescription1
@onready var u_image_1 = $Upgrade1/UImage1

@onready var upgrade_2 = $Upgrade2
@onready var u_name_2 = $Upgrade2/UName2
@onready var u_description_2 = $Upgrade2/UDescription2
@onready var u_image_2 = $Upgrade2/UImage2

@onready var PLACEHOLDERIMAGE = preload("res://Textures/Terrain/green.jpg")

var up1 = ["Power Boost", "Boosts your damage dealt by 10 (Starting amount = 50)", PLACEHOLDERIMAGE]
func up1f():
	get_parent().player.damage_buff += 10
	
var up2 = ["Speed Boost", "Boosts your speed by 5000 (Starting amount = 60000)", PLACEHOLDERIMAGE]
func up2f():
	get_parent().player.speed_buff += 5000

var up3 = ["Jump Boost", "Boosts your jump by 5000 (Starting amount = 60000)", PLACEHOLDERIMAGE]
func up3f():
	get_parent().player.jump_buff +=  5000

var up4 = ["HP Boost", "Boosts your max HP by 10 (Starting amount = 50)", PLACEHOLDERIMAGE]
func up4f():
	get_parent().player.max_hp += 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func initiate_upgrade_phase():
	show()
	rand_upgrade(upgrade_1)
	rand_upgrade(upgrade_2)
	
func rand_upgrade(upgrade_panel):
	match randi_range(1,4):
		1:
			upgrade_panel.index = 1
			upgrade_panel.u_name.text = up1[0]
			upgrade_panel.u_description.text = up1[1]
			upgrade_panel.u_image.texture = up1[2]
		2:
			upgrade_panel.index = 2
			upgrade_panel.u_name.text = up2[0]
			upgrade_panel.u_description.text = up2[1]
			upgrade_panel.u_image.texture = up2[2]
		3:
			upgrade_panel.index = 3
			upgrade_panel.u_name.text = up3[0]
			upgrade_panel.u_description.text = up3[1]
			upgrade_panel.u_image.texture = up3[2]
		4:
			upgrade_panel.index = 4
			upgrade_panel.u_name.text = up4[0]
			upgrade_panel.u_description.text = up4[1]
			upgrade_panel.u_image.texture = up4[2]

func apply_upgrade_choice(upgrade):
	match upgrade.index:
		1:
			up1f()
		2:
			up2f()
		3:
			up3f()
		4:
			up4f()
	hide()
