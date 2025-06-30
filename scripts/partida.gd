class_name Partida extends Node2D

var listaJogadores : Array[Jogador]
var partidaEmAndamento : bool = true
var _indexJogadorAtual : int = 0
var _indexJogadorUltimoTurno : int = 9999
var mesa : Mesa
var tabuleiro : MapManager
var ui : CanvasLayer
var labelJogadorAtual : Label
# SEPARAR ESTADOS/TURNO DE PARTIDA
enum {EM_ANDAMENTO, ULTIMO_TURNO, FINALIZAR}
var _estado = EM_ANDAMENTO

var calcula_pontuacao_scene = preload("res://cenas/pontuacao/calculaPontuacao.tscn")

func _ready() -> void:
	mesa = $"UI/Mesa"
	ui = $"UI"
	tabuleiro = $"Tabuleiro"
	labelJogadorAtual = $UI/NomeJogadorAtual

	# Quando uma carta é tomada da pilha exposta, o turno acaba
	mesa.pass_player_turn.connect(_on_turn_over)
	# Quando uma carta de destino é comprada, o turno acaba
	mesa.sel_destino_concluida.connect(_on_dest_cards_taken)
	
	_estado = FINALIZAR
	
	
func _process(_delta: float) -> void:
	if _estado == FINALIZAR or _estado == ULTIMO_TURNO:
		finalizar_partida()

func add_player(jogador : Jogador) -> void:
	listaJogadores.append(jogador)
	jogador.turnOver.connect(_on_turn_over)


func get_jogadores() -> Array[Jogador]:
	return listaJogadores

func update_curr_player_label():
	labelJogadorAtual.text = get_jogadores()[_indexJogadorAtual].get_nome() 

func set_partida(nomes: Array[String], player_color: String) -> void:
	var cores = ["azul_claro", "vermelho", "verde", "preto", "amarelo", "rosa", "laranja"]
	cores.erase(player_color)
	cores.shuffle()
	for i in range(nomes.size()):
		var jogador
		if i == 0:
			jogador = Jogador.create(nomes[i], player_color)
		else:
			jogador = JogadorIA.create(nomes[i], cores[i], Vector2(40, -680), Vector2(960, 0))
		jogador.set_status_param()
		add_player(jogador)
		if i > 0:
			listaJogadores[i].set_status_pos(Vector2(0, 150*(i-1)))
			listaJogadores[i].set_mao_pos(Vector2(0, 150*(i-1)))
		ui.add_child(listaJogadores[i])
	mesa.set_jogador_atual(listaJogadores[0])
	mesa.set_mesa()
	mesa.set_card_manager()
	update_curr_player_label()

func proximo_turno():
	# por segurança
	if _estado == FINALIZAR: finalizar_partida()
	else:
		_passar_turno()

func getJogadorAtual() -> Jogador:
	return listaJogadores[_indexJogadorAtual]

func _passar_turno():
	if _estado == FINALIZAR:
		finalizar_partida()
		return
	
	if _indexJogadorAtual == _indexJogadorUltimoTurno and _estado == ULTIMO_TURNO:
		_estado = FINALIZAR	
	
	
	if getJogadorAtual().get_trens() <= 2 and _estado == EM_ANDAMENTO:
		_indexJogadorUltimoTurno = _indexJogadorAtual
		_estado = ULTIMO_TURNO
	
	_indexJogadorAtual += 1
	
	if (_indexJogadorAtual >= listaJogadores.size()):
		_indexJogadorAtual = 0
	
	update_curr_player_label()
	var jog_atual = getJogadorAtual()
	if jog_atual is JogadorIA:
		mesa.disable_player_interaction()
	else:
		mesa.enable_player_interaction()
	getJogadorAtual().jogarTurno(self)


# Placeholder para a checagem da vitoria de um jogador
# Checa se a partida foi finalizada
func checar_fim_partida() -> bool:
	return false

#func determinarVitoria() -> void:
	 ##mesa.calcular_pontuacao_final(listaJogadores)
	 ##var vencedor = listaJogadores[0]
	 ##for j in listaJogadores:
		 ##if j.get_pontos() > vencedor.get_pontos():
			 ##vencedor = j
	 ##print("Vencedor: ", vencedor.get_nome())
	#pass

func finalizar_partida():
	if _estado != FINALIZAR:
		_estado = FINALIZAR 

	var tela_pontuacao = calcula_pontuacao_scene.instantiate()
	
	ui.add_child(tela_pontuacao) 
	# Ou se você quiser que ela seja uma tela separada do UI:
	#get_tree().get_root().add_child(tela_pontuacao)
	tela_pontuacao.set_mesa(mesa)
	tela_pontuacao.set_partida_node(get_jogadores()) 

	mesa.disable_player_interaction()
	tabuleiro.set_process_mode(Node.PROCESS_MODE_DISABLED) # Exemplo: Pausa o tabuleiro
	get_tree().paused = true # Pausa o jogo inteiro, se for o caso
	
	print("Tela de pontuação exibida.")

# Essa função deve ser conectada à um sinal emitido por jogador
func _handle_end_game_signal():
	if _estado == EM_ANDAMENTO:
		_estado = ULTIMO_TURNO

func _on_turn_over() -> void:
	proximo_turno()

func _on_card_taken(drop : Carta):
	proximo_turno()

func _on_pass_turn_button_pressed() -> void:
	proximo_turno()
	
func _on_dest_cards_taken():
	proximo_turno()
