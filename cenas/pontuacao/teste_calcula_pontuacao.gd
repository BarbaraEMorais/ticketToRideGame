extends Node

const MOCK_JOGADOR_SCRIPT = preload("res://cenas/jogadores/mock_jogador.gd") # Ajuste o caminho conforme onde salvou
const MOCK_MESA_SCRIPT = preload("res://scripts/mock_mesa.gd") # <--- NOVO: Pré-carregue o script do mock da Mesa

@onready var _calcula_pontuacao_node = $"CalculaPontuacao" 

func _ready():
	print("--- INICIANDO TESTE MANUAL DA TELA DE PONTUAÇÃO ---")

	var mock_jogadores = _criar_mock_jogadores()
	var mock_mesa = _criar_mock_mesa() # Esta função agora retorna uma instância do script mock da Mesa

	if is_instance_valid(_calcula_pontuacao_node):
		_calcula_pontuacao_node._set_test_data(mock_jogadores, mock_mesa)
		_calcula_pontuacao_node.atualizar_tabela_de_pontuacao_final()
		_verificar_resultados(mock_jogadores)
	else:
		printerr("ERRO: O nó 'CalculaPontuacao' não foi encontrado. Verifique o caminho em @onready.")

	print("--- TESTE MANUAL CONCLUÍDO ---")

# --- Funções Auxiliares ---

func _criar_mock_jogadores() -> Array[Jogador]: 

	var jogador_mock_a = MOCK_JOGADOR_SCRIPT.new("Zeca", 120, 2, 1) 
	var jogador_mock_b = MOCK_JOGADOR_SCRIPT.new("Maria", 180, 4, 0)
	var jogador_mock_c = MOCK_JOGADOR_SCRIPT.new("João", 90, 1, 2)
	var jogador_mock_d = MOCK_JOGADOR_SCRIPT.new("Ana", 180, 3, 0)

	return [jogador_mock_a, jogador_mock_b, jogador_mock_c, jogador_mock_d]

func _criar_mock_mesa() -> Node: 
	var mock_mesa_instance = MOCK_MESA_SCRIPT.new() 
	return mock_mesa_instance

func _verificar_resultados(initial_jogadores: Array[Jogador]): 
	print("\n--- Verificação de Resultados do Teste ---")

	print("\nOrdem dos jogadores na lista interna do calculaPontuacao (deve ser decrescente por pontuação):")
	for i in range(_calcula_pontuacao_node.jogadores.size()):
		var jogador = _calcula_pontuacao_node.jogadores[i]
		print(str(i+1) + ". " + jogador.get_nome() + " (Pontos: " + str(jogador.get_pontos()) + ")")

	for i in range(1, _calcula_pontuacao_node.jogadores.size()):
		var prev_jogador = _calcula_pontuacao_node.jogadores[i-1]
		var curr_jogador = _calcula_pontuacao_node.jogadores[i]
		if prev_jogador.get_pontos() >= curr_jogador.get_pontos():
			print(str(prev_jogador.get_nome()) + " (" + str(prev_jogador.get_pontos()) + ") >= " +
				str(curr_jogador.get_nome()) + " (" + str(curr_jogador.get_pontos()) + ") - OK")
		else:
			printerr("ERRO: Ordem incorreta! " + str(prev_jogador.get_nome()) + " (" + str(prev_jogador.get_pontos()) + ") < " +
				str(curr_jogador.get_nome()) + " (" + str(curr_jogador.get_pontos()) + ")")
	
	print("\nVerificando se os Labels no GridContainer foram preenchidos na ordem correta:")
	var current_child_index = 4 
	for i in range(_calcula_pontuacao_node.jogadores.size()):
		var expected_jogador = _calcula_pontuacao_node.jogadores[i]
		
		var name_label = _calcula_pontuacao_node.jogadores_container.get_child(current_child_index)
		var claimed_label = _calcula_pontuacao_node.jogadores_container.get_child(current_child_index + 1)
		var unclaimed_label = _calcula_pontuacao_node.jogadores_container.get_child(current_child_index + 2)
		var total_label = _calcula_pontuacao_node.jogadores_container.get_child(current_child_index + 3)

		if is_instance_valid(name_label) and name_label.has_method("get_text_data"): 
			if name_label.get_text_data() == expected_jogador.get_nome() and \
			   claimed_label.get_text_data() == str(expected_jogador.get_qtd_rotas_reivindicadas()) and \
			   unclaimed_label.get_text_data() == str(expected_jogador.get_qtd_rotas_nao_reivindicadas()) and \
			   total_label.get_text_data() == str(expected_jogador.get_pontos()):
				print("UI OK para Jogador: ",expected_jogador.get_nome())
			else:
				printerr("ERRO na UI para Jogador: ",expected_jogador.get_nome(),". Valores exibidos não correspondem aos esperados.")
		else:
			printerr("ERRO: Label não encontrado ou sem o método get_text_data no índice ",current_child_index,". A UI pode não ter sido preenchida corretamente.")

		current_child_index += 4
