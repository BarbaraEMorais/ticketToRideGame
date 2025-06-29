extends GutTest

var map_manager: MapManager
var mock_cidade_scene: PackedScene
var mock_caminho_scene: PackedScene
var mock_image_parser: Node

# é a mesma coisa dos unit tests
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


func test_integration_cria_cidades_e_caminhos():
	var cidade_a_id = 1
	var cidade_b_id = 2
	var caminho_id = 1
	
	# cria as cidades
	map_manager._cria_cidade(cidade_a_id, "Cidade A", Vector2(0, 0))
	map_manager._cria_cidade(cidade_b_id, "Cidade B", Vector2(100, 100))
	
	# cria um caminho entre elas
	map_manager._cria_caminho(caminho_id, cidade_a_id, cidade_b_id, 150, 1, ["red"])
	
	# testa os treco
	assert_eq(map_manager.cidades.size(), 2, "Devia ter 2 cidades")
	assert_eq(map_manager.caminhos.size(), 1, "Devia ter 1 caminho")
	assert_true(map_manager.cidades.has(cidade_a_id), "Devia ter a cidade A")
	assert_true(map_manager.cidades.has(cidade_b_id), "Devia ter a cidade B")
	
	# verifica se o caminho tem as propriedades certas
	var caminho = map_manager.caminhos[0]
	assert_eq(caminho.id, caminho_id, "Caminho devia ter o ID correto")
	assert_eq(caminho.origem, map_manager.cidades[cidade_a_id], "Caminho devia ter a origem correta")
	assert_eq(caminho.destino, map_manager.cidades[cidade_b_id], "Caminho devia ter o destino correto")
	assert_eq(caminho.linhas.size(), 1, "Caminho devia ter o numero correto de linhas")
