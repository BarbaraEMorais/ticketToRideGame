class_name Caminho extends Node2D

@export var trilho_scene: PackedScene

@export var origem: Cidade
@export var destino: Cidade

@export var tamanho: int
@export var linhasQtd: int
@export var linhas: Array[Dictionary] = []

func setup_caminho(_origem: Cidade, _destino: Cidade, _tamanho: int, _linhasQtd, _cores_linhas: Array[String]):
	origem = _origem
	destino = _destino
	tamanho = _tamanho
	linhasQtd = _linhasQtd
	linhas = _cores_linhas.map(func(e): return {"color": e, "locomotives": 0})


func _ready():
	gera_caminho()


func gera_caminho():
	var parabola = Parabola.new(origem.position, destino.position, -70)

	# just to take the size of the trilho
	var trilho = trilho_scene.instantiate() as Trilho
	var trilho_shape = _get_trilho_shape(trilho)
	trilho.queue_free()

	for i in range(tamanho):
		for j in range(linhasQtd):
			var direction = parabola.get_tangent_vector_at_parameter((i+0.5)/float(tamanho))
			var normal = direction.orthogonal()

			trilho = trilho_scene.instantiate() as Trilho
			trilho.rotation = direction.angle()
			trilho.position = parabola.get_parabola_point((i+0.5)/float(tamanho)) + (linhasQtd/2.0 - 1/2.0) * normal - (j * trilho_shape.y * normal)
			add_child(trilho)


func _get_trilho_shape(trilho_node: Area2D):
	if not is_instance_valid(trilho_node):
		push_warning("Caminho: o node do trilho não é válido")
		return

	var collision_shape_node = trilho_node.get_node_or_null("CollisionShape2D")

	if collision_shape_node and collision_shape_node.shape:
		if collision_shape_node.shape is RectangleShape2D:
			return collision_shape_node.shape.size
