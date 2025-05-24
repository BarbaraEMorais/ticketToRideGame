class_name Pilha extends CardContainer

@export var _cartas: Array[Carta]
func _ready() -> void:	
	_criar_pilha_inicial()
	area.input_event.connect(_on_click_area_input_event)


func _criar_pilha_inicial() -> void:
	pass


func puxar_carta() -> void:
	if _cartas.size() > 0:
		var carta = _cartas.pop_back()
		remove_child(carta)
		carta.visible = true
		print("puxou cartaaaa")
		add_child(carta)
		


func disable_click_area() -> void:
	area.input_pickable = false


func enable_click_area() -> void:
	area.input_pickable = true


func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		puxar_carta()
