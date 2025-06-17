extends Control

@onready var qtdJogHumano = $Panel/VBoxContainer/qtdJogHum
@onready var qtdJogBot = $Panel2/VBoxContainer/qtdJogIA

var totalJogadores = 5
var sinal_bloqueado = false

func _ready() -> void:

	qtdJogHumano.min_value = 1
	qtdJogHumano.max_value = totalJogadores
	qtdJogBot.min_value = 0
	qtdJogBot.max_value = totalJogadores - 1

	qtdJogHumano.value = 1
	qtdJogBot.value = totalJogadores - qtdJogHumano.value

	qtdJogHumano.connect("value_changed", _on_qtd_jogadores_humanos_changed)
	qtdJogBot.connect("value_changed", _on_qtd_jogadores_ia_changed)


func _on_qtd_jogadores_humanos_changed(value):
	if sinal_bloqueado:
		return
	sinal_bloqueado = true
	qtdJogBot.value = totalJogadores - value
	sinal_bloqueado= false


func _on_qtd_jogadores_ia_changed(value):
	if sinal_bloqueado:
		return
	sinal_bloqueado = true
	var new_value = totalJogadores - value
	if new_value <1:
		new_value = 1
		qtdJogBot.value = totalJogadores - new_value
	qtdJogHumano.value = new_value
	sinal_bloqueado = false


func _on_btn_avancar_pressed() -> void:
	print("asklfasklda")

	var cena_destino = preload("res://cenas/jogadores/OpcoesJogador.tscn").instantiate()
	cena_destino.numJogHum = qtdJogHumano.value

	get_tree().current_scene.call_deferred("free")
	get_tree().root.add_child(cena_destino)
	get_tree().current_scene = cena_destino
