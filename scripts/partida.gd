class_name Partida extends Node2D

var listaJogadores : Array[Jogador]
var partidaEmAndamento : bool = true
var _indexJogadorAtual : int = 0
var _indexJogadorUltimoTurno : int = 9999
var mesa : Mesa
var tabuleiro : MapManager
var UI : CanvasLayer
var labelJogadorAtual : Label
# SEPARAR ESTADOS/TURNO DE PARTIDA
enum {EM_ANDAMENTO, ULTIMO_TURNO, FINALIZAR}
var _estado = EM_ANDAMENTO

func _ready() -> void:
	mesa = $"Container/UI/Mesa"
	UI = $"Container/UI"
	tabuleiro = $"Container/Tabuleiro"
	labelJogadorAtual = $Container/NomeJogadorAtual

	# Quando uma carta é tomada da pilha exposta, o turno acaba
	mesa.get_pilha_exposta().carta_tomada_da_exposta.connect(_on_card_taken)
	# Quando uma carta de destino é comprada, o turno acaba
	mesa.sel_destino_concluida.connect(_on_dest_cards_taken)

	
func _process(_delta: float) -> void:
	pass

func add_player(jogador : Jogador) -> void:
	listaJogadores.append(jogador)
	jogador.turnOver.connect(_on_turn_over)


func get_jogadores() -> Array[Jogador]:
	return listaJogadores

func update_curr_player_label():
	labelJogadorAtual.text = "Turno de: " + get_jogadores()[_indexJogadorAtual].get_nome() 

func set_partida(nomes: Array[String], player_color: String) -> void:
	print(nomes);
	var cores = ["azul_claro", "vermelho", "azul_escuro", "verde", "preto", "amarelo", "rosa", "branco"]
	cores.erase(player_color)
	cores.shuffle()
	for i in range(nomes.size()):
		var jogador
		if i == 0:
			jogador = Jogador.create(nomes[i], player_color, Vector2(40, -680), Vector2(960, 0))
		else:
			jogador = JogadorIA.create(nomes[i], cores[i], Vector2(40, -680), Vector2(960, 0))
		jogador.set_status_param()
		add_player(jogador)
	for i in range(listaJogadores.size()):
		if i > 0:
			listaJogadores[i].set_status_pos(Vector2(20, 200*(i-1)))
			listaJogadores[i].set_mao_pos(Vector2(60, 200*(i-1)))
		UI.add_child(listaJogadores[i])
	mesa.set_jogador_atual(listaJogadores[0])
	mesa.set_mesa()
	mesa.set_card_manager()
	update_curr_player_label()


func proximo_turno():
	# por segurança
	if _estado == FINALIZAR: determinarVitoria()
	else:
		_passar_turno()

func getJogadorAtual() -> Jogador:
	return listaJogadores[_indexJogadorAtual]

func _passar_turno():
	if _estado == FINALIZAR:
		# Implementar lógica de fim de partida
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
	getJogadorAtual().jogarTurno(mesa)


# Placeholder para a checagem da vitoria de um jogador
# Checa se a partida foi finalizada
func checar_fim_partida() -> bool:
	return false

func determinarVitoria() -> void:
	pass

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
