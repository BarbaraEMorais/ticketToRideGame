class_name CartaTrem extends Carta

var cor: String

@onready var shadow: Sprite2D = $CardShadow

func _init(_cor= "") -> void:
	cor=_cor


func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	shadow.visible = true
	self.z_index = 2


func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	shadow.visible = false
	self.z_index = 0
