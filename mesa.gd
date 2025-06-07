class_name Mesa extends Node2D

@onready var _pilha_trem: PilhaTrem = $PilhaTrem 
@onready var _pilha_exposta: PilhaExposta = $PilhaExposta
@onready var _pilha_destino: PilhaDestino = $PilhaDestino

# @onready var jogador_atual: Jogador 
const CENA_SELECAO_DESTINO = preload("res://cenas/seleçãoDestino.tscn")
var cena_jogador_host = preload("res://cenas/jogador.tscn")
var instancia_selecao_destino_ui
var jogador = Jogador
var _card_manager: CardManager
func _ready() -> void:
	jogador= cena_jogador_host.instantiate()
	add_child(jogador)
	set_card_manager()
	add_child(_card_manager)
	
	if not is_instance_valid(_pilha_trem):
		push_error("Mesa: Nó PilhaTrem não encontrado ou inválido.")
		return
	if not is_instance_valid(_pilha_exposta):
		push_error("Mesa: Nó PilhaExposta não encontrado ou inválido.")
		return
	
	
	
	
	_pilha_exposta.set_pilha_trem(_pilha_trem)

	# Conectar aos sinais, se a Mesa precisar reagir a esses eventos
	_pilha_trem.carta_comprada_da_pilha.connect(_on_carta_comprada_da_pilha_trem)
	_pilha_exposta.carta_tomada_da_exposta.connect(_on_carta_tomada_da_pilha_exposta)
	
	print("Mesa configurada. PilhaExposta conectada à PilhaTrem.")
	if is_instance_valid(_pilha_destino):
		var err = _pilha_destino.selecao_cartas_destino_solicitada.connect(_on_pilha_destino_selecao_solicitada)
	#else:
	#	push_warning("Mesa: Instância de _pilha_destino não é válida. Não foi possível conectar sinal.")
	
func get_trem() -> PilhaTrem:
	return _pilha_trem

func get_pilha_exposta() -> PilhaExposta: 
	return _pilha_exposta

# Callback para quando uma carta é comprada da PilhaTrem (clique direto na pilha)
func _on_carta_comprada_da_pilha_trem(carta: CartaTrem) -> void:
	print("Mesa: Jogador comprou a carta '%s' da PilhaTrem." % carta.name)
	carta.visible=true
	jogador.get_mao().add_carta(carta)


# Callback para quando uma carta é tomada da PilhaExposta
func _on_carta_tomada_da_pilha_exposta(carta: CartaTrem) -> void:
	
	jogador.get_mao().add_carta(carta)
	
func _on_pilha_destino_selecao_solicitada() -> void:
	print("Mesa: Recebida solicitação para seleção de cartas destino.")

	if not is_instance_valid(_pilha_destino):
		printerr("Mesa: _pilha_destino não é válida ao tentar puxar cartas.")
		return

	# Se a tela de seleção já estiver aberta, não faça nada
	if is_instance_valid(instancia_selecao_destino_ui) and instancia_selecao_destino_ui.is_inside_tree():
		print("Mesa: Tela de seleção de destinos já está aberta.")
		return

	var cartas_destino_puxadas: Array[CartaDestino] = _pilha_destino.puxar_cartas_para_tela_selecao(3)

	if cartas_destino_puxadas.is_empty():
		print("Mesa: Nenhuma carta destino foi puxada.")
		return

	# Instanciando a cena da "telinha" de seleção
	instancia_selecao_destino_ui = CENA_SELECAO_DESTINO.instantiate()
	if not is_instance_valid(instancia_selecao_destino_ui):
		printerr("Mesa: Falha ao instanciar CENA_SELECAO_DESTINO.")
		return

	add_child(instancia_selecao_destino_ui)
	print("Mesa: Instância de SelecaoDestinoUI adicionada à cena.")

	# Passando 'cartas_destino_puxadas' para essa telinha. 
	if instancia_selecao_destino_ui.has_method("apresentar_cartas_para_selecao"):
		instancia_selecao_destino_ui.apresentar_cartas_para_selecao(cartas_destino_puxadas)
	else:
		printerr("Mesa: Instância de SelecaoDestinoUI não tem o método 'apresentar_cartas_para_selecao'.")
		instancia_selecao_destino_ui.queue_free() # Remove se não puder configurar
		instancia_selecao_destino_ui = null
		return

	# 4.Conectando ao sinal de conclusão da seleção
	if instancia_selecao_destino_ui.has_signal("selecao_de_destinos_concluida"):
		instancia_selecao_destino_ui.selecao_de_destinos_concluida.connect(_on_selecao_de_destinos_concluida)
		print("Mesa: Conectado ao sinal 'selecao_de_destinos_concluida' da UI de seleção.")
	else:
		push_warning("Mesa: Instância de SelecaoDestinoUI não tem o sinal 'selecao_de_destinos_concluida'.")

#método para lidar com o resultado da seleção
func _on_selecao_de_destinos_concluida(cartas_escolhidas: Array[CartaDestino]):
	print("Mesa: Seleção de destinos concluída. Cartas escolhidas:")
	if cartas_escolhidas.is_empty():
		print("  Nenhuma carta destino foi mantida.")
	else:
		for carta in cartas_escolhidas:
			if is_instance_valid(carta): 
				print("  - De: %s Para: %s (Pontos: %s)" % [carta.cidade_origem, carta.cidade_destino, carta.pontos])
				carta.visible=true
				jogador.get_mao().add_carta(carta)
				
				
			else:
				print("  - Uma carta escolhida tornou-se inválida antes do processamento.")


	if is_instance_valid(instancia_selecao_destino_ui):
		
		pass 
	instancia_selecao_destino_ui = null # Limpa a referência

func set_card_manager() -> void:
	_card_manager = CardManager.new()
	_card_manager.name = "CardManager"
	jogador.get_mao().set_signals_to_manager(_card_manager)
