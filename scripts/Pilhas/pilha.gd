class_name Pilha extends CardContainer

signal carta_comprada_da_pilha(carta: Carta) # Sinal emitido quando uma carta é comprada da pilha


@export var _cartas: Array[Carta]

func _ready() -> void:
	criar_pilha_inicial()


func criar_pilha_inicial() -> void: # Esta função é intencionalmente deixada para ser implementada por classes filhas, como PilhaTrem.gd ou outras pilhas.
	pass


func comprar_carta_da_pilha() -> Carta:

	if not can_player_interact:
		return

	if _cartas.size() > 0:
		var carta: Carta = _cartas.pop_back()
		print("Pilha (%s): Carta '%s' compradaaaaaaaa." % [name, carta.name if carta else "NIL"])
		emit_signal("carta_comprada_da_pilha", carta)
		return carta

	print("Pilha (%s): Vazia, não pode comprar carta." % name)
	return null


func disable_click_area() -> void:
	pass


func enable_click_area() -> void:
	pass


func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var carta_puxada: Carta = comprar_carta_da_pilha()
		if carta_puxada:
			print("Pilha (%s): Evento de clique processado, carta '%s' comprada e sinal emitido." % [name, carta_puxada.name if carta_puxada else "NIL"])
		else:
			print("Pilha (%s): Tentativa de compra por clique falhou (pilha vazia?)." % name)
			
func get_quantidade () -> int:
	return _cartas.size() 
