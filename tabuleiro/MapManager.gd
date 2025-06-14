class_name MapManager extends Node2D

@export var cidade_scene: PackedScene
@export var caminho_scene: PackedScene

@onready var sprite_2d_node = $Sprite2D
@onready var image_parser = $ImageParser

var cidades: Dictionary = {}
var caminhos: Array[Caminho] = []

func _ready():
	image_parser.image_saved.connect(_on_image_saved)
	json_map_parser("res://dados/mapa-brasil.json")


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
		cidade_node.scale = Vector2(0.5, 0.5)
		add_child(cidade_node)
		cidades[id] = cidade_node
		# print("Created cidade: ", cidade_node.cidade_name)
	else:
		push_warning("MapManager: Cidade scene não setada.")


func _cria_caminho(id: int, origem_id: int, destino_id: int, length: int, lines: int, colors: Array[String], curvature = 0):
	if not caminho_scene:
		push_warning("MapManager: Caminho scene não setada.")
		return

	if not cidades.has(origem_id) or not cidades.has(destino_id):
		push_warning("MapManager: Não deu pra criar o caminho. Tá faltando o destino ou a origem.")
		return

	var origem_node: Cidade = cidades[origem_id]
	var cidade_node: Cidade = cidades[destino_id]

	var caminho_node = caminho_scene.instantiate() as Caminho
	caminho_node.setup_caminho(id, origem_node, cidade_node, length, lines, colors, curvature)
	add_child(caminho_node)
	caminhos.append(caminho_node)


func json_map_parser(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)

	if !file:
		printerr("Não foi possível abrir o arquivo do mapa")
		return

	var content = file.get_as_text()
	file.close()

	var json_result = JSON.parse_string(content)
	if !json_result:
		printerr("Erro no parsing do JSON do mapa: ", json_result.get_error_message())

	# plano de fundo
	var output_path = "user://decoded_image.png"
	image_parser.parseImage(json_result["detailedBackgrounds"]["skyNoRoads"], output_path)

	# dimensoes do mapa
	var width = (json_result["outline"]["width"] + json_result["outline"]["offset_x"]) * 2
	var height = (json_result["outline"]["height"] + json_result["outline"]["offset_y"]) * 2
	var dimensions = json_result["dimensions"]

	# cidades
	for cidade in json_result["destinations"]:
		var pos = Vector2(-width/2 + cidade["x"] * width / dimensions[0], height/2 + -cidade["y"] * height)
		_cria_cidade(cidade["id"], cidade["name"], pos)

	# caminhos
	for t in json_result["tracks"]:
		# t["lines"].map(func(e): return e["colour"]) as Array[String]
		_cria_caminho(t["id"], t["start"], t["end"], t["length"], t["lineAmount"], ["grey", "grey","grey", "grey"], t["curvature"])


func _on_image_saved(image_path: String):
	if not FileAccess.file_exists(image_path):
		push_error("File not found: " + image_path)
	else:
		print("Found it!")
	# 1) read file bytes
	var f := FileAccess.open(image_path, FileAccess.READ)

	if f == null:
		push_error("Could not open " + image_path)
		return
	var buf := f.get_buffer(f.get_length())
	f.close()
	# 2) decode PNG (or JPEG) from bytes
	var img := Image.new()
	var err := img.load_png_from_buffer(buf)
	if err != OK:
		push_error("PNG decode failed: %s" % err)
		return
	# 3) make a texture
	var texture := ImageTexture.create_from_image(img)
	# 4) apply
	sprite_2d_node.texture = texture
