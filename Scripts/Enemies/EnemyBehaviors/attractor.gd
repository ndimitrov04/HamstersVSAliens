extends Node3D

@onready var attraction_area = $AttractionArea
@onready var attraction_shape = $AttractionArea/AttractionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().has_meta("attraction_radius"):
		attraction_shape.shape.radius = get_parent().get_meta("attraction_radius")
		attraction_area.gravity_point_unit_distance = get_parent().get_meta("attraction_radius")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if "alive" in get_parent():
		if get_parent().alive == false:
			queue_free()
