class_name Mesa extends Node

@onready var _pilha_trem: PilhaTrem = $PilhaTrem 
@onready var _pilha_exposta: PilhaExposta = $PilhaExposta
@onready var _pilha_destino: PilhaDestino = $PilhaDestino
@onready var tabuleiro_node: MapManager = $"../../Tabuleiro"
const PONTOS_POR_ROTA = {
	1: 1,
	2: 2,
	3: 4,
	4: 7,
	5: 10,
	6: 15
}
# @onready var jogador_atual: Jogador 
const CENA_SELECAO_DESTINO = preload("res://cenas/seleçãoDestino.tscn")
#var cena_jogador_host = preload("res://cenas/JogadorHumano.tscn")
#var cena_jogador_IA = preload("res://status_jogador.gd")

var instancia_selecao_destino_ui
var _card_manager: CardManager
var jogador_atual : Jogador

signal sel_destino_concluida
signal pass_player_turn

func _ready() -> void:
	call_deferred("conectar_sinais_das_linhas")
	
func get_trem() -> PilhaTrem:
	return _pilha_trem

func get_pilha_exposta() -> PilhaExposta: 
	return _pilha_exposta
	
func disable_player_interaction() -> void:
	_pilha_destino.can_player_interact = false
	_pilha_trem.can_player_interact = false
	_pilha_exposta.can_player_interact = false
	
func enable_player_interaction() -> void:
	_pilha_destino.can_player_interact = true
	_pilha_exposta.can_player_interact = true
	_pilha_trem.can_player_interact = true
	

# Callback para quando uma carta é comprada da PilhaTrem (clique direto na pilha)
func _on_carta_comprada_da_pilha_trem(carta: CartaTrem) -> void:
	print("Mesa: Jogador comprou a carta '%s' da PilhaTrem." % carta.name)
	carta.visible=true
	jogador_atual.get_mao().add_carta(carta)
	pass_player_turn.emit()


# Callback para quando uma carta é tomada da PilhaExposta
func _on_carta_tomada_da_pilha_exposta(carta: CartaTrem) -> void:
	jogador_atual.get_mao().add_carta(carta)
	pass_player_turn.emit()
	
func _on_pilha_destino_selecao_solicitada() -> void:
	
	
	print("Mesa: Recebida solicitação para seleção de cartas destino.")

	if not _pilha_destino.can_player_interact:
		print("Mesa: Jogador não pode interagir com a pilha de destino no momento")
		return

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
	
	disable_player_interaction()

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


func conectar_sinais_das_linhas(): # CONECTA TODAS AS LINHAS COM A FUNÇÃO QUE FAZ A VERIFICAÇÃO NA MESA
	print("Mesa: Conectando sinais das linhas do Tabuleiro...")
	
	if not is_instance_valid(tabuleiro_node):
		printerr("Mesa: Referência ao nó 'Tabuleiro' não encontrada!")
		return

	if tabuleiro_node.caminhos.is_empty(): # <--- SUSPEITO PRINCIPAL
		push_warning("Mesa: Nenhum caminho encontrado no Tabuleiro para conectar sinais.")
		return
		
	for caminho in tabuleiro_node.caminhos:
		for linha in caminho.linhas:
			if not linha.rota_reclamar_solicitada.is_connected(_on_rota_reclamar_solicitada):
				linha.rota_reclamar_solicitada.connect(_on_rota_reclamar_solicitada)
				print("linha conectada")


func _on_rota_reclamar_solicitada(linha_clicada: Linha):
	print("chegou aqui na parte de reivindicar")
	#FUNÇÃO DA MÃO QUE VERIFICA SE TEM CARTAS SUFUCIENTES PRA REIVINDICIAR E RETORNA 0 SE FOR POSSIVEL
	if jogador_atual.get_mao().gerencia_reivindicação(linha_clicada.color, linha_clicada.trilhos.size()) ==0:
		linha_clicada.claim_route(jogador_atual) 
		jogador_atual.subtrai_trens(linha_clicada.trilhos.size())
		jogador_atual.soma_pontos(PONTOS_POR_ROTA.get(linha_clicada.trilhos.size()))
		verifica_destino(jogador_atual)
	
# FUNÇÃO PRINCIPAL DE BUSCA DE CAMINHO
# Verifica se existe uma conexão contínua de rotas do 'jogador'
# entre as cidades com os nomes 'nome_origem' e 'nome_destino'.
func verificar_conexao_entre_cidades(jogador: Jogador, nome_origem: String, nome_destino: String) -> bool:
	# 1. Encontrar os nós das cidades a partir dos seus nomes
	print("chegou aqui")
	var no_origem: Cidade = _encontrar_cidade_por_nome(nome_origem)
	var no_destino: Cidade = _encontrar_cidade_por_nome(nome_destino)
	print("\n[VERIFICANDO ROTA] De '%s' Para '%s'" % [nome_origem, nome_destino])
	if not is_instance_valid(no_origem) or not is_instance_valid(no_destino):
		printerr("Mesa: Não foi possível encontrar a cidade de origem ou destino ('%s', '%s') no mapa." % [nome_origem, nome_destino])
		return false
	
	# 2. Preparar as listas para a busca
	var fila_para_visitar: Array[Cidade] = [no_origem] # A "onda" de exploração começa na origem
	var cidades_ja_visitadas: Array[Cidade] = [no_origem] # Para não nos perdermos em ciclos

	# 3. O Loop de Exploração
	while not fila_para_visitar.is_empty():
		# Pega a próxima cidade da fila para explorar
		var cidade_atual: Cidade = fila_para_visitar.pop_front()
		# CONDIÇÃO DE VITÓRIA: Chegamos ao destino?
		if cidade_atual == no_destino:
			print("Busca de Caminho: SUCESSO! Conexão encontrada entre '%s' e '%s'." % [nome_origem, nome_destino])
			return true # Destino completado!

		# Pede ao MapManager a lista de vizinhos alcançáveis a partir daqui
		var vizinhos = tabuleiro_node.get_vizinhos_alcancaveis(cidade_atual, jogador)
		
		for vizinho in vizinhos:
			# Se é um vizinho que ainda não foi visitado...
			if not vizinho in cidades_ja_visitadas:
				cidades_ja_visitadas.append(vizinho) # Marque como visitado
				fila_para_visitar.append(vizinho) # Adicione à fila para explorar a partir dele depois

	# Se o loop terminar e nunca encontramos o destino, não há caminho.
	print("Busca de Caminho: FALHA! Nenhuma conexão encontrada entre '%s' e '%s'." % [nome_origem, nome_destino])
	return false

# FUNÇÃO AUXILIAR para encontrar um nó de cidade pelo seu nome
func _encontrar_cidade_por_nome(nome_cidade: String) -> Cidade:
	if not is_instance_valid(tabuleiro_node): return null
	
	# Itera sobre todos os valores (que são os nós Cidade) no dicionário 'cidades' do MapManager
	for cidade_node in tabuleiro_node.cidades.values():
		if cidade_node.cidade_name == nome_cidade:
			return cidade_node
	return null
	

func verifica_destino(jogador_atual: Jogador):
	if not is_instance_valid(jogador_atual): return

	
	# Itera sobre todas as cartas na mão do jogador
	for carta in jogador_atual.get_mao().get_cartas() :
		# Filtra apenas as Cartas Destino
		if carta is CartaDestino:
			var carta_destino = carta as CartaDestino
			
			print("Verificando destino: de '%s' para '%s' (vale %s pontos)..." % [carta_destino.cidade_origem, carta_destino.cidade_destino, carta_destino.pontos])
			
			# Chama a nossa função principal de busca!
			var foi_completado = verificar_conexao_entre_cidades(jogador_atual, carta_destino.cidade_origem, carta_destino.cidade_destino)
			
			if foi_completado and carta_destino.completado==false:
				print("  --> DESTINO COMPLETO! +%s pontos." % carta_destino.pontos)
				jogador_atual.soma_pontos(carta_destino.pontos)
				carta_destino.completado=true
				






# Exemplo de função que seria chamada no final do jogo
func calcular_pontuacao_final(jogador_atual: Jogador):
	if not is_instance_valid(jogador_atual): return

	print("\n--- CALCULANDO PONTUAÇÃO FINAL PARA O JOGADOR: %s ---" % jogador_atual.name)
	
	var mao_do_jogador = jogador_atual.get_mao()
	
	# Itera sobre todas as cartas na mão do jogador
	for carta in mao_do_jogador.get_cartas() :
		# Filtra apenas as Cartas Destino
		if carta is CartaDestino:
			var carta_destino = carta as CartaDestino
			
			print("Verificando destino: de '%s' para '%s' (vale %s pontos)..." % [carta_destino.cidade_origem, carta_destino.cidade_destino, carta_destino.pontos])
			
			# Chama a nossa função principal de busca!
			var foi_completado = verificar_conexao_entre_cidades(jogador_atual, carta_destino.cidade_origem, carta_destino.cidade_destino)
			
			if foi_completado:
				print("  --> DESTINO COMPLETO! +%s pontos." % carta_destino.pontos)
				jogador_atual.soma_pontos(carta_destino.pontos) # Supondo que você tenha este método no Jogador
			else:
				print("  --> DESTINO NÃO COMPLETO! -%s pontos." % carta_destino.pontos)
				jogador_atual.soma_pontos(-carta_destino.pontos) # Subtrai os pontos
	
	print("--- PONTUAÇÃO FINAL DE %s: %s ---" % [jogador_atual.name, jogador_atual._pontos])


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
				jogador_atual.get_mao().add_carta(carta)
				
				
			else:
				print("  - Uma carta escolhida tornou-se inválida antes do processamento.")
	
	enable_player_interaction()
	sel_destino_concluida.emit()

	if is_instance_valid(instancia_selecao_destino_ui):
		pass 
	instancia_selecao_destino_ui = null # Limpa a referência

func set_jogador_atual(jogador: Jogador):
	jogador_atual = jogador

func set_card_manager() -> void:
	_card_manager = CardManager.new()
	_card_manager.name = "CardManager"
	jogador_atual.get_mao().set_signals_to_manager(_card_manager)
	add_child(_card_manager)

func set_mesa():
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



func get_pilha_destino() -> PilhaDestino:
	return _pilha_destino


	if not is_instance_valid(tabuleiro_node):
		printerr("DIAGNÓSTICO: Não foi possível printar as linhas, referência ao tabuleiro é inválida.")
		return

	print("\n--- LISTA DE LINHAS (ROTAS) CARREGADAS NO MAPA ---")
	
	if tabuleiro_node.caminhos.is_empty():
		print("Nenhum caminho (e portanto, nenhuma linha) foi carregado no MapManager.")
		return
		
	# Itera sobre cada 'Caminho' (conexão entre duas cidades) no tabuleiro
	for caminho in tabuleiro_node.caminhos:
		if not is_instance_valid(caminho) or not is_instance_valid(caminho.origem) or not is_instance_valid(caminho.destino):
			print(" - Caminho inválido encontrado.")
			continue
			
		var nome_origem = caminho.origem.cidade_name
		var nome_destino = caminho.destino.cidade_name
		
		# Para cada 'Caminho', itera sobre as 'Linhas' (as rotas coloridas) que ele contém
		if caminho.linhas.is_empty():
			print(" - Caminho de '%s' para '%s' não tem linhas." % [nome_origem, nome_destino])
		else:
			for linha in caminho.linhas:
				# Printa os detalhes da linha
				var cor_linha = linha.color
				var tamanho_linha = linha.trilhos.size()
				print(" - Linha [Cor: %s, Tamanho: %s] de '%s' para '%s'" % [cor_linha.capitalize(), tamanho_linha, nome_origem, nome_destino])

	print("--------------------------------------------------\n")
