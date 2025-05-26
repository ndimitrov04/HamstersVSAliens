extends RichTextLabel

func _ready():
	self.meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta):
	OS.shell_open(meta)
