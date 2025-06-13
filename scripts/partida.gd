class_name Partida extends Node2D

var listaJogadores : Array[Jogador]
var maxJogadores : int
var partidaEmAndamento : bool = true
var _indexJogadorAtual : int = 0
var mesa : Mesa
var tabuleiro : MapManager

# SEPARAR ESTADOS/TURNO DE PARTIDA
enum {EM_ANDAMENTO, ULTIMO_TURNO, FINALIZAR}
var _estado = EM_ANDAMENTO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesa = $Mesa
	mesa.set_jogador_atual(listaJogadores[0])
	mesa.set_mesa()
	mesa.set_card_manager()

	tabuleiro = $Tabuleiro

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func create_partida() -> Partida:
	var partida_cena = preload("res://cenas/partida.tscn")
	var partida = partida_cena.instantiate()
	return partida

func add_player(jogador : Jogador) -> void:
	if(listaJogadores.size() == maxJogadores):
		printerr("Não é possível adicionar novo jogador: Partida Cheia")
		return
	listaJogadores.append(jogador)

func get_jogadores() -> Array[Jogador]:
	return listaJogadores

func set_partida(nomes: Array[String], qtd_jogadores: int) -> void:
	maxJogadores = qtd_jogadores
	var cores = ["azul_claro", "vermelho", "azul_escuro", "verde", "preto", "amarelo", "rosa"]
	for i in range(maxJogadores):
		var jogador
		if i == 0:
			jogador = Jogador.create(nomes[i], cores[i], Vector2(40, -680), Vector2(960, 0))
		else:
			jogador = JogadorIA.create(nomes[i], cores[i], Vector2(40, -680), Vector2(960, 0))	
		jogador.set_status_param()
		add_player(jogador)
	for i in range(listaJogadores.size()):
		add_child(listaJogadores[i])
		if i > 0:
			print("setou bot position")
			listaJogadores[i].set_status_pos(Vector2(20, 200*(i-1)))
			listaJogadores[i].set_mao_pos(Vector2(60, 200*(i-1)))

func proximo_turno():
	# por segurança
	if _estado == FINALIZAR: determinarVitoria()
	else:
		_passar_turno()

func _passar_turno():
	_indexJogadorAtual += 1
	if (_indexJogadorAtual >= listaJogadores.size()):
		_indexJogadorAtual = 0
		
	$NomeJogadorAtual.text = "Turno de: " + listaJogadores[_indexJogadorAtual].nome
	listaJogadores[_indexJogadorAtual].jogarTurno()
	
	if _estado == ULTIMO_TURNO:
		_estado = FINALIZAR

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
