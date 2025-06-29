extends Node2D

@onready var jogadores_container = $Panel/ContainerJogadores # AGORA É UM GridContainer


# Pré-carrega a nova cena do Label da célula
var jogador_cell_label_scene = preload("res://cenas/pontuacao/jogadorCellLabel.tscn") # Caminho para a nova cena Label

func _ready():
	adicionar_cabecalho("Nome", "Reivindicada", "Não Reivindicada", "Pontos", "Total")

	adicionar_jogador("Ana", 5, 1, 100, 106)
	adicionar_jogador("Bruno", 3, 3, 90, 96)
	adicionar_jogador("Carlos", 7, 0, 120, 127) # Adicionando mais para demonstrar o grid
	adicionar_jogador("Ana", 5, 1, 100, 106)
	adicionar_jogador("Bruno", 3, 3, 90, 96)

func adicionar_cabecalho(h_nome, h_reivindicada, h_nao_reivindicada, h_pontos, h_total):
	var header_label_scene = preload("res://cenas/pontuacao/jogadorCellLabel.tscn") # Usar a mesma cena de Label

	var l_nome = header_label_scene.instantiate()
	l_nome.set_text_data(h_nome)
	jogadores_container.add_child(l_nome)
	#l_nome.add_theme_font_size_override("font_size", 20) # Para deixar maior
	#l_nome.add_theme_color_override("font_color", Color.YELLOW) # Para mudar cor

	var l_reivindicada = header_label_scene.instantiate()
	l_reivindicada.set_text_data(h_reivindicada)
	jogadores_container.add_child(l_reivindicada)

	var l_nao_reivindicada = header_label_scene.instantiate()
	l_nao_reivindicada.set_text_data(h_nao_reivindicada)
	jogadores_container.add_child(l_nao_reivindicada)

	var l_pontos = header_label_scene.instantiate()
	l_pontos.set_text_data(h_pontos)
	jogadores_container.add_child(l_pontos)

	var l_total = header_label_scene.instantiate()
	l_total.set_text_data(h_total)
	jogadores_container.add_child(l_total)

func adicionar_jogador(nome, rota_reivindicada, rota_nao_reivindicada, pontos, total):
	# Criar e adicionar os Labels para cada dado do jogador
	
	var label_nome = jogador_cell_label_scene.instantiate()
	label_nome.set_text_data(nome)
	jogadores_container.add_child(label_nome)

	var label_rota_reivindicada = jogador_cell_label_scene.instantiate()
	label_rota_reivindicada.set_text_data(str(rota_reivindicada))
	jogadores_container.add_child(label_rota_reivindicada)

	var label_rota_nao_reivindicada = jogador_cell_label_scene.instantiate()
	label_rota_nao_reivindicada.set_text_data(str(rota_nao_reivindicada))
	jogadores_container.add_child(label_rota_nao_reivindicada)

	var label_pontos = jogador_cell_label_scene.instantiate()
	label_pontos.set_text_data(str(pontos))
	jogadores_container.add_child(label_pontos)

	var label_total = jogador_cell_label_scene.instantiate()
	label_total.set_text_data(str(total))
	jogadores_container.add_child(label_total)

	print("Jogador ", nome, " adicionado ao grid. Total de filhos no GridContainer: ", jogadores_container.get_child_count())
