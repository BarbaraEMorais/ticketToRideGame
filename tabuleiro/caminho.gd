class_name Caminho extends Node2D

@export var trilho_scene: PackedScene

@export var id: int
@export var origem: Cidade
@export var destino: Cidade

@export var tamanho: int
@export var linhasQtd: int
@export var coresLinhas: Array[String]
@export var curvature: int

var trilhos: Array[Array]

func setup_caminho(_id: int, _origem: Cidade, _destino: Cidade, _tamanho: int, _linhasQtd, cores: Array, _curvature: int = 0):
	id = _id
	origem = _origem
	destino = _destino
	tamanho = _tamanho
	linhasQtd = _linhasQtd
	coresLinhas = cores
	curvature = _curvature

	trilhos.resize(linhasQtd)
	for i in range(linhasQtd):
		trilhos[i] = []


func _ready():
	gera_caminho()


func gera_caminho():
	var parabola = Parabola.new(origem.position, destino.position, curvature * tamanho / 4, 30)

	# just to take the size of the trilho
	var trilho = trilho_scene.instantiate() as Trilho
	var trilho_shape = _get_trilho_shape(trilho)
	trilho_shape *= Vector2(0.32, 0.3)
	trilho.queue_free()

	for i in range(tamanho):
		var direction = parabola.get_tangent_vector_at_parameter((i+0.5)/float(tamanho))
		var normal = direction.orthogonal()

		for j in range(linhasQtd):
			var normal_offset = (linhasQtd/2.0 - 1/2.0) * trilho_shape.y * normal - (j * trilho_shape.y * normal)

			trilho = trilho_scene.instantiate() as Trilho
			trilho.rotation = direction.angle()
			trilho.position = parabola.get_parabola_point((i+0.5)/float(tamanho)) + normal_offset - (normal.normalized() * curvature)/2
			trilho.scale = Vector2(0.32, 0.3)

			trilho.trilho_hovered.connect(_on_trilho_hovered)
			trilho.trilho_unhovered.connect(_on_trilho_unhovered)
			trilho.trilho_clicked.connect(_on_trilho_clicked)

			add_child(trilho)

			trilho.linha = j
			trilho.track_color = coresLinhas[j]

			trilhos[j].append(trilho)


func _get_trilho_shape(trilho_node: Area2D):
	if not is_instance_valid(trilho_node):
		push_warning("Caminho: o node do trilho não é válido")
		return

	var collision_shape_node = trilho_node.get_node_or_null("CollisionShape2D")

	if collision_shape_node and collision_shape_node.shape:
		if collision_shape_node.shape is RectangleShape2D:
			return collision_shape_node.shape.size


func _on_trilho_hovered(trilho: Trilho):
	highlight_linha(trilho.linha)

func _on_trilho_unhovered(trilho: Trilho):
	unhighlight_linha(trilho.linha)

func _on_trilho_clicked(trilho: Trilho):
	print("Clicked trilho at linha ", trilho.linha)

func highlight_linha(linha_index: int):
	for trilho in trilhos[linha_index]:
		if trilho:
			trilho.highlight()

func unhighlight_linha(linha_index: int):
	for trilho in trilhos[linha_index]:
		if trilho:
			trilho.unhighlight()
