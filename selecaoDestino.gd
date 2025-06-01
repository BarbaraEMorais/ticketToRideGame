extends CanvasLayer

signal selecao_de_destinos_concluida(cartas_escolhidas: Array[CartaDestino])


@onready var painel_node: Panel = $Panel 
@onready var slot_carta_1: Node2D = $Panel/Slot1
@onready var slot_carta_2: Node2D = $Panel/Slot2
@onready var slot_carta_3: Node2D = $Panel/Slot3
@onready var botao_continuar: Button = $botaoContinuar 

var cartas_em_exibicao: Array[CartaDestino] = []
var cartas_realmente_selecionadas: Array[CartaDestino] = []

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("SelecaoDestinoUI: _ready() EXECUTADO.") #DEBUG

	if not is_instance_valid(botao_continuar):
		
		return
	
	botao_continuar.disabled = true
	if not botao_continuar.pressed.is_connected(_on_botao_continuar_pressionado):
		botao_continuar.pressed.connect(_on_botao_continuar_pressionado)
		print("SelecaoDestinoUI: Sinal 'pressed' do botao_continuar conectado.") #DEBUG
	else:
		print("SelecaoDestinoUI: Sinal 'pressed' do botao_continuar JÁ ESTAVA conectado.") #DEBUG

func apresentar_cartas_para_selecao(p_cartas_destino_recebidas: Array[CartaDestino]):

	if p_cartas_destino_recebidas.is_empty():
		self.queue_free()
		return

	print("SelecaoDestinoUI: Recebidas %s cartas para apresentar." % p_cartas_destino_recebidas.size())
	for idx in range(p_cartas_destino_recebidas.size()):
		var c_info = p_cartas_destino_recebidas[idx]
		if is_instance_valid(c_info):
			print("  DEBUG Apresentacao - Carta %s recebida: '%s' (%s-%s)" % [idx, c_info.name, c_info.cidade_origem, c_info.cidade_destino])
		else:
			print("  DEBUG Apresentacao - Carta %s recebida é INVÁLIDA" % idx)

	cartas_em_exibicao = p_cartas_destino_recebidas
	cartas_realmente_selecionadas.clear()

	_limpar_slots_anteriores()

	var slots: Array[Node2D] = [slot_carta_1, slot_carta_2, slot_carta_3]

	for i in range(slots.size()):
		var s_node = slots[i]
		var slot_name_for_debug = "slot_carta_%s" % (i+1)

	for i in range(min(cartas_em_exibicao.size(), slots.size())):
		var carta_atual: CartaDestino = cartas_em_exibicao[i]
		var slot_designado: Node2D = slots[i]
		
		var slot_name_debug = "SlotInválido"
		if is_instance_valid(slot_designado): slot_name_debug = slot_designado.name
		var carta_name_debug = "CartaInválida"
		if is_instance_valid(carta_atual): carta_name_debug = carta_atual.name


		if is_instance_valid(carta_atual.get_parent()):
			print("    DEBUG Posicionamento: Carta '%s' já tem pai ('%s'). Removendo." % [carta_atual.name, carta_atual.get_parent().name])
			carta_atual.get_parent().remove_child(carta_atual)

		slot_designado.add_child(carta_atual)
		carta_atual.position = Vector2.ZERO
		carta_atual.visible = true
		
		#Garantindo que a carta possa receber input
		carta_atual.process_mode = Node.PROCESS_MODE_INHERIT
		carta_atual.z_index = 10 
		
		#Desabilitando drag nas cartas de destino durante seleção
		if carta_atual.has_method("disable_drag"):
			carta_atual.disable_drag()
		
		print("    DEBUG Posicionamento: Carta '%s' adicionada. Posição local: %s. Visível: %s." % [carta_atual.name, carta_atual.position, carta_atual.visible])

		if carta_atual.esta_selecionada:
			carta_atual.alternar_selecao()

		if carta_atual.has_signal("selecao_individual_alterada"):
			var callable_metodo_callback = Callable(self, "_on_uma_carta_mudou_seu_estado_selecao")
			if not carta_atual.selecao_individual_alterada.is_connected(callable_metodo_callback):
				var err = carta_atual.selecao_individual_alterada.connect(callable_metodo_callback)
			else:
				print("    DEBUG Conexão UI: 'selecao_individual_alterada' da carta '%s' JÁ ESTAVA CONECTADA." % carta_atual.name)
		#else:
		#	push_warning("SelecaoDestinoUI: CARTA '%s' NÃO TEM o sinal 'selecao_individual_alterada'!" % carta_atual.name)

	_atualizar_logica_botao_continuar()
	
	# CORREÇÃO: Aguardando um frame antes de tornar visível para garantir que tudo foi configurado
	await get_tree().process_frame
	self.visible = true
	print("SelecaoDestinoUI: 'apresentar_cartas_para_selecao' concluído. UI visível: %s" % self.visible)

func _limpar_slots_anteriores():
	print("SelecaoDestinoUI: _limpar_slots_anteriores() CHAMADO.") 
	for slot_node in [slot_carta_1, slot_carta_2, slot_carta_3]:
		if is_instance_valid(slot_node):
			for child_node_atual in slot_node.get_children():
				slot_node.remove_child(child_node_atual)
				if child_node_atual.has_method("enable_drag"):
					child_node_atual.enable_drag()

func _on_uma_carta_mudou_seu_estado_selecao(carta_que_mudou: CartaDestino, novo_estado_selecao: bool):
	print("SelecaoDestinoUI (CALLBACK Sinal Carta): Carta '%s-%s' mudou seleção para: %s" % [carta_que_mudou.cidade_origem, carta_que_mudou.cidade_destino, novo_estado_selecao]) # DEBUG
	
	cartas_realmente_selecionadas.clear()
	for carta_iter in cartas_em_exibicao:
		if is_instance_valid(carta_iter) and carta_iter.esta_selecionada:
			cartas_realmente_selecionadas.append(carta_iter)
	
	_atualizar_logica_botao_continuar()

func _atualizar_logica_botao_continuar():
	var pelo_menos_uma_escolhida = cartas_realmente_selecionadas.size() >= 1
	
	if is_instance_valid(botao_continuar):
		botao_continuar.disabled = not pelo_menos_uma_escolhida
	print("SelecaoDestinoUI: Botão 'Continuar' habilitado: %s (Total selecionadas: %s)" % [not botao_continuar.disabled if is_instance_valid(botao_continuar) else "BOTÃO INVÁLIDO", cartas_realmente_selecionadas.size()]) #debug

func _on_botao_continuar_pressionado():
	
	
	print("Cartas escolhidas para enviar à Mesa:")
	for carta_escolhida in cartas_realmente_selecionadas:
		print("  - '%s' (%s-%s)" % [carta_escolhida.name, carta_escolhida.cidade_origem, carta_escolhida.cidade_destino])

	emit_signal("selecao_de_destinos_concluida", cartas_realmente_selecionadas)
	
	self.visible = false
