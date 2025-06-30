extends Node

@onready var _partida_node = $"Partida"
@onready var _calcula_pontuacao_node = $"../cenas/pontuacao/calculaPontuacao" # Onde a tela de pontuação está

func _ready():
	# Certifique-se de que ambos os nós são válidos
	if is_instance_valid(_partida_node) and is_instance_valid(_calcula_pontuacao_node):
		_calcula_pontuacao_node.set_partida_node(_partida_node)
	else:
		printerr("Não foi possível passar a referência da Partida para a tela de pontuação.")
