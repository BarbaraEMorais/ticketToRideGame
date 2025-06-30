# cenas/pontuacao/calculaPontuacao.gd
extends Node2D

@onready var jogadores_container = $Panel/ContainerJogadores
@onready var _mesa_real = $"Mesa" # Referência para a Mesa real, usada em tempo de jogo

var _mesa_mock: Node = null # Variável para armazenar o mock da Mesa em modo de teste
var _partida_referencia: Node = null
var jogadores: Array[Jogador] 
var jogador_cell_label_scene = preload("res://cenas/pontuacao/jogadorCellLabel.tscn")

func _ready() -> void:
	adicionar_cabecalho("Nome", "Rotas Reivindicadas", "Rotas Não Reivindicadas", "Pontuação Final")

func set_mesa(mesa: Mesa):
	_mesa_mock = mesa
	
# Este método é para uso em produção, quando a PartidaManager injeta a Partida real
func set_partida_node(_jogadores: Array[Jogador]):
	
	jogadores = _jogadores
	if jogadores.is_empty():
		push_warning("calculaPontuacao: Nenhum jogador encontrado através da Partida referenciada.")
		return
	atualizar_tabela_de_pontuacao_final()
	#else:
		#printerr("calculaPontuacao: Referência de Partida inválida recebida.")

func _set_test_data(test_jogadores: Array[Jogador], test_mesa_mock: Node):
	self.jogadores = test_jogadores
	self._mesa_mock = test_mesa_mock 

func atualizar_tabela_de_pontuacao_final():

	var mesa_para_usar = _mesa_mock if _mesa_mock else _mesa_real

	if not is_instance_valid(mesa_para_usar):
		printerr("calculaPontuacao: Referência à Mesa (real ou mock) é inválida. Não é possível calcular pontuações.")
		return
	if jogadores.is_empty():
		push_warning("calculaPontuacao: Sem jogadores para calcular pontuações finais.")
		return

	# Chama calcular_pontuacao_final na Mesa (será o mock durante o teste)
	mesa_para_usar.calcular_pontuacao_final(jogadores)

	_limpar_linhas_de_jogadores()

	jogadores.sort_custom(_sort_jogadores_por_pontuacao)

	for jogador in jogadores:
		
		var nome = jogador.get_nome()
		var rotas_reivindicadas = jogador.get_qtd_rotas_reivindicadas()
		var rotas_nao_reivindicadas = jogador.get_qtd_rotas_nao_reivindicadas()
		var pontos = jogador.get_pontos()

		_adicionar_linha_jogador(
			nome,
			rotas_reivindicadas,
			rotas_nao_reivindicadas,
			pontos,
		)
	print("calculaPontuacao: Tabela de pontuação final atualizada com sucesso.")

func _sort_jogadores_por_pontuacao(jogador_a: Jogador, jogador_b: Jogador) -> bool:
	return jogador_a.get_pontos() > jogador_b.get_pontos()

func _limpar_linhas_de_jogadores():
	
	for i in range(jogadores_container.get_child_count() - 1, 3, -1):
		var child = jogadores_container.get_child(i)
		if is_instance_valid(child):
			child.queue_free()

func adicionar_cabecalho(h_nome, h_reivindicada, h_nao_reivindicada, h_total_final):
	
	for i in range(min(4, jogadores_container.get_child_count())):
		var child = jogadores_container.get_child(i)
		if is_instance_valid(child):
			child.queue_free()

	var labels_cabecalho = [h_nome, h_reivindicada, h_nao_reivindicada, h_total_final]
	for text in labels_cabecalho:
		var l = jogador_cell_label_scene.instantiate()
		l.set_text_data(text) 
		jogadores_container.add_child(l)

func _adicionar_linha_jogador(nome, rota_reivindicada, rota_nao_reivindicada, total_final):
	var data_labels = [nome, str(rota_reivindicada), str(rota_nao_reivindicada), str(total_final)]

	for data in data_labels:
		var label = jogador_cell_label_scene.instantiate()
		label.set_text_data(data)
		jogadores_container.add_child(label)
