extends GutTest

var map_manager: MapManager
var mock_cidade_scene: PackedScene
var mock_caminho_scene: PackedScene
var mock_image_parser: Node

func before_each():
	map_manager = MapManager.new()
	
	mock_cidade_scene = preload("res://tabuleiro/Cidade.tscn")
	mock_caminho_scene = preload("res://tabuleiro/Caminho.tscn")
	
	mock_image_parser = Node.new()
	mock_image_parser.name = "ImageParser"
	map_manager.add_child(mock_image_parser)
	
	var sprite_2d = Sprite2D.new()
	sprite_2d.name = "Sprite2D"
	map_manager.add_child(sprite_2d)
	
	map_manager.cidade_scene = mock_cidade_scene
	map_manager.caminho_scene = mock_caminho_scene


func after_each():
	if is_instance_valid(map_manager):
		map_manager.queue_free()


func test_cria_cidade_sucesso():
	var cidade_id = 2025
	var cidade_name = "Rolândia, Paraná"
	var pos = Vector2(100, 200)
	
	map_manager._cria_cidade(cidade_id, cidade_name, pos)
	
	assert_true(map_manager.cidades.has(cidade_id), "Cidade devia ser adicionada ao dict de cidades.")
	assert_eq(map_manager.cidades[cidade_id].get_script().get_global_name(), "Cidade", "Devia criar uma instancia de Cidade")


func test_cria_cidade_sem_cena():
	map_manager.cidade_scene = null
	var cidade_id = 1
	var cidade_name = "Xique-Xique, Bahia"
	var pos = Vector2(50, 100)
	
	map_manager._cria_cidade(cidade_id, cidade_name, pos)
	
	assert_false(map_manager.cidades.has(cidade_id), "Cidade não deveria ser criada sem a cena.")


func test_cria_caminho_sucesso():
	map_manager._cria_cidade(1, "Cidade A", Vector2(0, 0))
	map_manager._cria_cidade(2, "Cidade B", Vector2(100, 100))
	
	var caminho_id = 1
	var origem_id = 1
	var destino_id = 2
	var length = 150
	var lines = 2
	var colors: Array[String] = ["red", "blue"]
	var curvature = 0.5
	
	map_manager._cria_caminho(caminho_id, origem_id, destino_id, length, lines, colors, curvature)
	
	assert_eq(map_manager.caminhos.size(), 1, "Deveria adicionar um caminho ao array de caminhos")
	assert_eq(map_manager.caminhos[0].get_script().get_global_name(), "Caminho", "Deveria criar uma instância de Caminho")


func test_cria_caminho_sem_cena():
	map_manager.caminho_scene = null
	map_manager._cria_cidade(1, "Cidade A", Vector2(0, 0))
	map_manager._cria_cidade(2, "Cidade B", Vector2(100, 100))
	
	map_manager._cria_caminho(1, 1, 2, 150, 2, ["red", "blue"])
	
	assert_eq(map_manager.caminhos.size(), 0, "Caminho não deveria ser criado sem cena")


func test_cria_caminho_sem_origem():
	map_manager._cria_cidade(2, "Cidade B", Vector2(100, 100))
	
	map_manager._cria_caminho(1, 1, 2, 150, 2, ["red", "blue"])
	
	assert_eq(map_manager.caminhos.size(), 0, "Caminho não deveria ser criado sem origem")


func test_cria_caminho_sem_destino():
	map_manager._cria_cidade(1, "Cidade A", Vector2(0, 0))
	
	map_manager._cria_caminho(1, 1, 2, 150, 2, ["red", "blue"])
	
	assert_eq(map_manager.caminhos.size(), 0, "Caminho não deveria ser criado sem destino")


func test_get_vizinhos_alcancaveis_mapa_vazio():
	var cidade = Cidade.new()
	var jogador = Jogador.new()
	
	var vizinhos = map_manager.get_vizinhos_alcancaveis(cidade, jogador)
	
	assert_eq(vizinhos.size(), 0, "Deveria retornar um array de vizinhos vazio, se o mapa estiver vazio")
	
	# limpa os vestigios
	cidade.queue_free()
	jogador.queue_free()


func test_get_vizinhos_alcancaveis_com_rotas_dele():
	# cria cidades e bota no mapa
	map_manager._cria_cidade(1, "Cidade A", Vector2(0, 0))
	map_manager._cria_cidade(2, "Cidade B", Vector2(100, 100))
	map_manager._cria_cidade(3, "Cidade C", Vector2(200, 200))
	
	var cidade_a = map_manager.cidades[1]
	var cidade_b = map_manager.cidades[2]
	var cidade_c = map_manager.cidades[3]
	
	# cria os caminhos entre as cidades
	map_manager._cria_caminho(1, 1, 2, 150, 1, ["red"])
	map_manager._cria_caminho(2, 1, 3, 200, 1, ["blue"])
	
	var jogador = Jogador.new()
	var other_jogador = Jogador.new()
	
	# faz nosso jogador reivindicar a rota
	map_manager.caminhos[0].linhas[0].dono = jogador
	# a outra rota é do outro jogador
	map_manager.caminhos[1].linhas[0].dono = other_jogador
	
	var vizinhos = map_manager.get_vizinhos_alcancaveis(cidade_a, jogador)
	
	assert_eq(vizinhos.size(), 1, "Devia retornar um vizinho acessível")
	assert_eq(vizinhos[0], cidade_b, "Devia retornar cidade B como vizinho acessível")
	
	# limpa os vestigios
	jogador.queue_free()
	other_jogador.queue_free()


func test_get_vizinhos_alcancaveis_bidirectional():
	# cria as cidades, bota no mapa, e cria os caminhos
	map_manager._cria_cidade(1, "Cidade A", Vector2(0, 0))
	map_manager._cria_cidade(2, "Cidade B", Vector2(100, 100))
	
	var cidade_a = map_manager.cidades[1]
	var cidade_b = map_manager.cidades[2]
	
	map_manager._cria_caminho(1, 2, 1, 150, 1, ["red"]) # origem=2, destino=1
	
	var jogador = Jogador.new()
	map_manager.caminhos[0].linhas[0].dono = jogador
	
	# teste da cidade A (destino no caminho)
	var vizinhos = map_manager.get_vizinhos_alcancaveis(cidade_a, jogador)
	
	assert_eq(vizinhos.size(), 1, "Devia funcionar bidirecionalmente")
	assert_eq(vizinhos[0], cidade_b, "Devia retornar cidade B quando cidade A é destino")
	
	# limpa os vestigios
	jogador.queue_free()


func test_get_vizinhos_alcancaveis_rota_com_varias_linhas():
	# cria as cidades e bota no mapa
	map_manager._cria_cidade(1, "Cidade A", Vector2(0, 0))
	map_manager._cria_cidade(2, "Cidade B", Vector2(100, 100))
	
	var cidade_a = map_manager.cidades[1]
	var cidade_b = map_manager.cidades[2]
	
	# cria o caminho com várias linhas (2)
	map_manager._cria_caminho(1, 1, 2, 150, 2, ["red", "blue"])
	
	var jogador = Jogador.new()
	var other_jogador = Jogador.new()
	
	# a primeira linha é do nosso jogador, a outra é do outro cara
	map_manager.caminhos[0].linhas[0].dono = other_jogador
	map_manager.caminhos[0].linhas[1].dono = jogador
	
	var vizinhos = map_manager.get_vizinhos_alcancaveis(cidade_a, jogador)
	
	assert_eq(vizinhos.size(), 1, "Devia achar rota com pelo menos uma linha dele")
	assert_eq(vizinhos[0], cidade_b, "Devia retornar a cidade conectada")
	
	# limpa os vestigios
	jogador.queue_free()
	other_jogador.queue_free()


func test_get_vizinhos_alcancaveis_sem_rotas_dele():
	# cria as cidades, cria caminho
	map_manager._cria_cidade(1, "Cidade A", Vector2(0, 0))
	map_manager._cria_cidade(2, "Cidade B", Vector2(100, 100))
	
	var cidade_a = map_manager.cidades[1]
	
	map_manager._cria_caminho(1, 1, 2, 150, 1, ["red"])
	
	var jogador = Jogador.new()
	var other_jogador = Jogador.new()
	
	# a rota é do outro cara
	map_manager.caminhos[0].linhas[0].dono = other_jogador
	
	var vizinhos = map_manager.get_vizinhos_alcancaveis(cidade_a, jogador)
	
	assert_eq(vizinhos.size(), 0, "Não devia retornar nenhum vizinho quando nenhuma rota é dele")
	
	# limpa os vestigios
	jogador.queue_free()
	other_jogador.queue_free()


func test_json_map_parser_arquivo_nao_achado():
	var invalid_path = "res://invalido/caminho.json"
	
	# não devia crashar aqui rs
	map_manager.json_map_parser(invalid_path)
	
	assert_true(true, "A funcão devia lidar com o arquivo faltante")


func test_on_image_saved_file_not_found():
	var invalid_path = "user://imagem_de_mentira.png"
	
	# não devia crashar aqui rs
	map_manager._on_image_saved(invalid_path)
	
	assert_true(true, "A funcão devia lidar com a imagem faltante")
