class_name Jogador extends Node



var _nome : String
var _trens : int
var _pontos : int
@onready var _mao: Mao = $Mao 

func set_jogador(nome : String = "") -> void:	
	_nome = nome
	_trens = 45
	_pontos= 0
	
func get_mao() -> Mao:
	return _mao
	
