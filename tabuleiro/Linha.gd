class_name Linha extends Node2D

var origem: Cidade
var destino: Cidade

var color: String
var trilhos: Array[Trilho] = []
var dono: Jogador

func _init(_color: String):
	color = _color


func add_trilho(trilho: Trilho):
	trilhos.append(trilho)
	add_child(trilho)

	trilho.track_color = color

	trilho.trilho_hovered.connect(_on_trilho_hovered)
	trilho.trilho_unhovered.connect(_on_trilho_unhovered)
	trilho.trilho_clicked.connect(_on_trilho_clicked)


func claim_route(jogador: Jogador):
	owner = jogador


func _on_trilho_hovered(trilho: Trilho):
	highlight_linha()


func _on_trilho_unhovered(trilho: Trilho):
	unhighlight_linha()


func _on_trilho_clicked(trilho: Trilho):
	print("Clicked trilho at linha")


func highlight_linha():
	for trilho in trilhos:
		trilho.highlight()

func unhighlight_linha():
	for trilho in trilhos:
		trilho.unhighlight()
