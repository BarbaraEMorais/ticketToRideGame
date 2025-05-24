class_name Mesa extends Node2D

@onready var _trem: PilhaTrem = $PilhaTrem


#func _ready() -> void:



func get_trem() -> PilhaTrem:
	return _trem
	


#func get_tremE() -> PilhaExposta:
#	return _cartaTremE
