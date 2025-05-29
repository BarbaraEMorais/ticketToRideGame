class_name Partida extends Node2D

@export
var listaJogadores : Array[JogadorTemp]

@export_range(2, 6)
var maxJogadores : int

var partidaEmAndamento : bool = true

var _indexJogadorAtual : int = 0

var mesa : Mesa

enum {EM_ANDAMENTO, ULTIMO_TURNO, FINALIZAR}

var _estado = EM_ANDAMENTO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesa = $Mesa
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_player(jogador : JogadorTemp) -> void:
	if(listaJogadores.size() == maxJogadores):
		printerr("Não é possível adicionar novo jogador: Partida Cheia")
		return
	
	listaJogadores.append(jogador)


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
	
	
