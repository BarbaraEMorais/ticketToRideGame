class_name Caminho extends Node2D

@export var origem_id: int = -1
@export var destino_id: int = -1
@export var tamanho: int = 1
@export var linhas: int = 1

@export var trilho_scene: PackedScene

var _origem_pos: Vector2
var _destino_pos: Vector2

func _ready():
	gera_caminho()


func setup_caminho(origem: Cidade, destino: Cidade, _tamanho: int, _linhas: int):
	origem_id = origem.cidade_id
	destino_id = destino.cidade_id
	_origem_pos = origem.position
	_destino_pos = destino.position
	tamanho = _tamanho
	linhas = _linhas


func gera_caminho():
	var direction = _destino_pos - _origem_pos
	var curr_pos_in_direction = _origem_pos
	var novo_trilho = trilho_scene.instantiate() as Trilho

	var trilho_shape = _get_trilho_shape(novo_trilho)
	novo_trilho.queue_free()
	var ort = direction.orthogonal().normalized()
	var gap_y = 10
	var largura_linhas = (trilho_shape.y * linhas) + (gap_y * (linhas-1))


	var gap_x = 10
	var actual_length = trilho_shape.x * tamanho + gap_x * (tamanho-1)
	var margin = (direction.length() - actual_length) / 2

	curr_pos_in_direction += direction.normalized() * (margin + trilho_shape.x/2)

	for i in range(tamanho):
		if (i > 0):
			curr_pos_in_direction += direction.normalized() * (gap_x + trilho_shape.x)

		for l in range(linhas):
			novo_trilho = trilho_scene.instantiate() as Trilho
			novo_trilho.rotation = direction.angle()
			var pos_trilho = curr_pos_in_direction + ort * (largura_linhas/2 - (l+1)*largura_linhas/(linhas))
			novo_trilho.position = pos_trilho
			add_child(novo_trilho)


func _get_trilho_shape(trilho_node: Area2D):
	if not is_instance_valid(trilho_node):
		push_warning("Caminho: o node do trilho não é válido")
		return

	var collision_shape_node = trilho_node.get_node_or_null("CollisionShape2D")

	if collision_shape_node and collision_shape_node.shape:
		if collision_shape_node.shape is RectangleShape2D:
			return collision_shape_node.shape.size
