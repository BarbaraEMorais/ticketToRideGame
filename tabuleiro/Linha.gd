class_name Linha extends Node2D

var origem: Cidade
var destino: Cidade

var color: String
var trilhos: Array[Trilho] = []
var dono: Jogador = null
signal rota_reclamar_solicitada(linha_selecionada: Linha)
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
	dono = jogador
	for t in trilhos:
		t.claim(dono.get_cor())
		print(dono.get_cor())
	

func _on_trilho_hovered(_trilho: Trilho):
	highlight_linha()


func _on_trilho_unhovered(_trilho: Trilho):
	unhighlight_linha()


func _on_trilho_clicked(_trilho: Trilho):
	# TEMP
	var jogador_placeholder = Jogador.new()
	if !dono:
		emit_signal("rota_reclamar_solicitada", self) 


func highlight_linha():
	for t in trilhos:
		t.highlight()


func unhighlight_linha():
	for t in trilhos:
		t.unhighlight()
