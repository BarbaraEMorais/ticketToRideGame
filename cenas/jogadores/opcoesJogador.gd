extends Control

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
