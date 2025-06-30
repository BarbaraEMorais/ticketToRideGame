class_name Jogador extends Control

signal turnOver

var _nome : String
var _trens : int
var _pontos : int
var _destinos: int
var _cor: String
var _destino_cumprido: int
var _destino_nao_cumprido: int

@onready var _mao = $Mao
@onready var _status_card = $"Status Jogador"

func _ready() -> void:
	_mao.received_new_card.connect(_on_player_hand_received_card)

# Lógica relacionada ao turno do usuário
func jogarTurno(part : Partida):
	pass

func _process(_delta: float) -> void:
	$"Status Jogador/Pontos".text = str(_pontos)
	$"Status Jogador/Qtd_Trens".text = str(_trens)
	$"Status Jogador/Qtd_Destinos".text = str(_mao.get_qtd_cartas_destino())
	$"Status Jogador/Qtd_Mao".text = str(_mao.get_qtd_cartas_trem())

static func create(nome : String, cor : String, pos_status: Vector2 = Vector2(0,0), pos_mao: Vector2 = Vector2(0,0)) -> Jogador:
	var jogador_cena = load("res://cenas/JogadorHumano.tscn")
	var novo = jogador_cena.instantiate()
	novo._nome = nome
	novo._trens = 45
	novo._pontos = 0
	novo._cor = cor
	novo.set_card_color(cor)
	return novo

func set_status_param() -> void:
	$"Status Jogador/Nome".text = _nome
	$"Status Jogador/Pontos".text = str(_pontos)
	$"Status Jogador/Qtd_Trens".text = str(_trens)
	$"Status Jogador/Qtd_Destinos".text = str(_destinos)

func set_card_color(color: String) -> void:
	var color_path = "res://assets/Bilhete_" + color + ".png"
	print(color_path)
	$"Status Jogador".texture = load(color_path)

func set_status_pos(_pos: Vector2) -> void:
	$"Status Jogador".position = _pos

func set_mao_pos(_pos: Vector2) -> void:
	$"Mao".position = _pos

func set_pontos(_num: int) -> void:
	_pontos = int(_num)

func set_trens(_num: int) -> void:
	_trens = int(_num)

func set_destinos(_num: int) -> void:
	_destinos = int(_num)

func get_destinos() -> int:
	return _destinos

func get_pontos() -> int:
	return _pontos

func get_trens() -> int:
	return _trens

func get_mao() -> Mao:
	return _mao

func get_nome() -> String:
	return _nome

func _on_player_hand_received_card():
	turnOver.emit()
func get_status() -> Node2D:
	return _status_card

func soma_pontos(_num: int) -> void:
	_pontos += _num 
	
func subtrai_trens(_num: int) -> void:
	_trens -= _num
func get_cor() -> String:
	return _cor

#func add_rota_reivindicada(rota: Linha) -> void:
	#if not _rotas_reivindicadas.has(rota): # Evita adicionar a mesma rota múltiplas vezes
		#_rotas_reivindicadas.append(rota)
		#print("Jogador %s reivindicou a rota entre %s e %s (cor: %s, tamanho: %s)." % [_nome, rota.caminho.origem.cidade_name, rota.caminho.destino.cidade_name, rota.color, rota.trilhos.size()])
#
func soma_rota_reivindicada(value):
	_destino_cumprido +=value
	
func get_qtd_rotas_reivindicadas():
	return _destino_cumprido

func get_qtd_rotas_nao_reivindicadas():
	_destino_nao_cumprido = _destinos - get_qtd_rotas_reivindicadas()
	return _destino_nao_cumprido
	
#func get_qtd_rotas_reivindicadas() -> int:
	#var num_rotas_reivindicadas = get_rotas_reivindicadas()
	#return num_rotas_reivindicadas.size()
