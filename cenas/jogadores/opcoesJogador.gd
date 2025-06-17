extends Control

const PARTIDA_SCENE = preload("res://cenas/partida.tscn")

var numJogHum = 0
@onready var container = $CenterContainer/HBoxContainer

func _ready():

	print("Número de jogadores humanos:", numJogHum)
	for i in range(numJogHum):
		var card = preload("res://cenas/jogadores/cardJogador.tscn").instantiate()
		container.add_child(card)
		card.connect("cor_selecionada", _on_cor_selecionada)
		card.connect("cadastro_confirmado", _on_cadastro_confirmado)

func _on_cor_selecionada(cor):
	print("Cor escolhida:", cor)

func _on_cadastro_confirmado(nome, cor):
	print("Cadastro confirmado - Nome:", nome, "Cor:", cor)
	# aqui você adicionaria o jogador a uma lista ou seguiria para a próxima cena
	#
	# pra finalmente ir pro jogo vai pro codigo abaixo:
	# GameDataTransfer.set_match_data(listBotsJogadores, qtdJogadores)
	# get_tree().change_scene_to_packed(PARTIDA_SCENE)
