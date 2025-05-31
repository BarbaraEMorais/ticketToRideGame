class_name CartaDestino extends Carta

var pontos: int
var completado: bool
var cidade_origem: String
var cidade_destino: String
var esta_selecionada: bool

# Avisa quando o estado de seleção DESTA CARTA muda.
signal selecao_individual_alterada(carta: CartaDestino, novo_estado_selecao: bool)

func _init(_pontos: int = 0, _img_path: String = "res://assets/exodia.jpeg") -> void:
	pontos = _pontos
	completado = false
	esta_selecionada = false

func configurar_dados(dados: Dictionary) -> void:
	cidade_origem = dados.get("cidade_origem", "desconhecida")
	cidade_destino = dados.get("cidade_destino", "desconhecida")
	pontos = dados.get("pontos", 0)
	esta_selecionada = false
	completado = false

func _ready():
	# Aguardar um frame para garantir que todos os nós estão prontos
	await get_tree().process_frame
	
	# Garantir que a carta possa receber input
	process_mode = Node.PROCESS_MODE_INHERIT
	
	drag_enabled = false
	print("CartaDestino ('%s'): _ready() EXECUTADO." % self.name)
	
	var callable_proprio_clique = Callable(self, "_on_proprio_clique")
	if not carta_clicada.is_connected(callable_proprio_clique):
		var err = carta_clicada.connect(callable_proprio_clique)
	else:
		print("CartaDestino ('%s'): SINAL 'carta_clicada' já estava conectado a '_on_proprio_clique'." % self.name) # DEBUG

# Callback para o sinal 'carta_clicada' da própria carta
func _on_proprio_clique(_instancia_da_carta_que_foi_clicada: Carta):
	print("CartaDestino ('%s'): _on_proprio_clique FOI CHAMADO." % self.name) # debug
	alternar_selecao()

func alternar_selecao():
	print("CartaDestino ('%s'): alternar_selecao() FOI CHAMADO." % self.name) # DEBUG
	esta_selecionada = not esta_selecionada
	print("CartaDestino ('%s-%s'): AGORA SELECIONADA: %s" % [self.cidade_origem, self.cidade_destino, esta_selecionada]) # DEBUG
	
	# VISUAL: Alterar a escala ou cor para indicar seleção
	_atualizar_visual_selecao()
	
	emit_signal("selecao_individual_alterada", self, esta_selecionada)
	print("CartaDestino ('%s'): Sinal 'selecao_individual_alterada' emitido com estado: %s" % [self.name, esta_selecionada]) # DEBUG

func _atualizar_visual_selecao():
	if esta_selecionada:
		modulate = Color(1.2, 1.2, 0.8)  # Amarelo
		z_index = 15
	else:
		modulate = Color.WHITE  # normal, quando não selecionada
		z_index = 10

# Método para forçar deseleção (útil para reset)
func deselecionar():
	if esta_selecionada:
		alternar_selecao()

# Método para verificar se pode ser clicada 
func _input_event(viewport: Node, event: InputEvent, shape_idx: int):
	print("CartaDestino ('%s'): _input_event chamado com evento: %s" % [self.name, event])
	return false  
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var carta_rect = Rect2(global_position - Vector2(50, 70), Vector2(100, 140))
		if carta_rect.has_point(mouse_pos):
			print("CLIQUE DETECTADO na carta %s!" % name)
			alternar_selecao()
