class_name Pilha extends CardContainer

@export var _cartas: Array[Carta]

signal carta_comprada_da_pilha(carta: Carta) # Sinal emitido quando uma carta é comprada da pilha

func _ready() -> void:    
	criarpilha_inicial() 
	if area:
		area.input_event.connect(_on_click_area_input_event)
	else:
		push_warning("Nó Area2D não encontrado em: " + name)

func criarpilha_inicial() -> void: # Esta função é intencionalmente deixada para ser implementada por classes filhas, como PilhaTrem.gd ou outras pilhas.
	pass


func comprar_carta_da_pilha() -> Carta: 
	if _cartas.size() > 0:
		var carta: Carta = _cartas.pop_back() 
		print("Pilha (%s): Carta '%s' compradaaaaaaaa." % [name, carta.name if carta else "NIL"])
		#remove_child(carta)
		emit_signal("carta_comprada_da_pilha", carta) 
		return carta 
	
	print("Pilha (%s): Vazia, não pode comprar carta." % name)
	return null

func disable_click_area() -> void:
	if area:
		area.input_pickable = false

func enable_click_area() -> void:
	if area:
		area.input_pickable = true

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var carta_puxada: Carta = comprar_carta_da_pilha()
		if carta_puxada:
			print("Pilha (%s): Evento de clique processado, carta '%s' comprada e sinal emitido." % [name, carta_puxada.name if carta_puxada else "NIL"])
		else:
			print("Pilha (%s): Tentativa de compra por clique falhou (pilha vazia?)." % name)
