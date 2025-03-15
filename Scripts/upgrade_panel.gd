extends Panel

@onready var index = get_meta("index")
@onready var u_name = $UName
@onready var u_description = $UDescription
@onready var u_image = $UImage

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().apply_upgrade_choice(self)
