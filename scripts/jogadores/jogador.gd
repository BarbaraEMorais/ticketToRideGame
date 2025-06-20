class_name Jogador extends Node2D

var _nome : String
var _trens : int
var _pontos : int
var _destinos: int
@onready var _mao = $CanvasLayer/HBoxContainer/Mao

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	$"CanvasLayer/HBoxContainer/Status Jogador/Pontos".text = str(_pontos)
	$"CanvasLayer/HBoxContainer/Status Jogador/Qtd_Trens".text = str(_trens)
	$"CanvasLayer/HBoxContainer/Status Jogador/Qtd_Destinos".text = str(_destinos)

static func create(nome : String, cor : String, pos_status: Vector2, pos_mao: Vector2) -> Jogador:
	var jogador_cena = load("res://cenas/JogadorHumano.tscn")
	var novo = jogador_cena.instantiate()
	novo._nome = nome
	novo._trens = 45
	novo._pontos= 0
	novo.set_card_color(cor)
	return novo

func set_status_param() -> void:
	$"CanvasLayer/HBoxContainer/Status Jogador/Nome".text = _nome
	$"CanvasLayer/HBoxContainer/Status Jogador/Pontos".text = str(_pontos)
	$"CanvasLayer/HBoxContainer/Status Jogador/Qtd_Trens".text = str(_trens)
	$"CanvasLayer/HBoxContainer/Status Jogador/Qtd_Destinos".text = str(_destinos)

func set_card_color(color: String) -> void:
	var color_path = "res://assets/Bilhete_" + color + ".png"
	$"CanvasLayer/HBoxContainer/Status Jogador/Bilhete".texture = load(color_path)

func set_status_pos(_pos: Vector2) -> void:
	$"CanvasLayer/HBoxContainer/Status Jogador".position = _pos

func set_mao_pos(_pos: Vector2) -> void:
	$"CanvasLayer/HBoxContainer/Mao".position = _pos

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
