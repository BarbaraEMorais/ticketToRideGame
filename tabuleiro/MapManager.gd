class_name MapManager extends Node2D

@export var cidade_scene: PackedScene
@export var caminho_scene: PackedScene

var cidades: Dictionary = {}
var caminhos: Array[Caminho] = []

func _ready():
	_cria_varias_cidades_exemplo()
	_cria_caminho(1, 2, 5, 1, ["Red"])
	_cria_caminho(2, 3, 3, 3, ["Green", "DarkGray", "Blue"], 30)


func _cria_varias_cidades_exemplo():
	var cidades_dados = [
		{ "id": 1, "name": "North Gate", "pos": Vector2(100, 50) },
		{ "id": 2, "name": "South Market", "pos": Vector2(500, 450) },
		{ "id": 3, "name": "East Woods", "pos": Vector2(700, 200) }
	]
	for dados in cidades_dados:
		_cria_cidade(dados["id"], dados["name"], dados["pos"])


func _cria_cidade(id: int, cidade_name: String, pos: Vector2):
	if cidade_scene:
		var cidade_node = cidade_scene.instantiate() as Cidade
		cidade_node.setup_cidade(id, cidade_name, pos)
		add_child(cidade_node)
		cidades[id] = cidade_node
		print("Created cidade: ", cidade_node.cidade_name)
	else:
		push_warning("MapManager: cidadeino scene não setada.")


func _cria_caminho(origem_id: int, cidade_id: int, length: int, lines: int, colors: Array[String], curvature = 0):
	if not caminho_scene:
		push_warning("MapManager: Caminho scene não setada.")
		return

	if not cidades.has(origem_id) or not cidades.has(cidade_id):
		push_warning("MapManager: Não deu pra criar o caminho. Tá faltando o cidade ou a origem.")
		return

	var origem_node: Cidade = cidades[origem_id]
	var cidade_node: Cidade = cidades[cidade_id]

	var caminho_node = caminho_scene.instantiate() as Caminho
	caminho_node.setup_caminho(origem_node, cidade_node, length, lines, colors, curvature)
	add_child(caminho_node)
	caminhos.append(caminho_node)
