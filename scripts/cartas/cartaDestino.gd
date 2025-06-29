class_name CartaDestino extends Carta

var pontos: int
var completado: bool = false
var cidade_origem: String
var cidade_destino: String
var esta_selecionada: bool
var selecionavel: bool

@onready var LabelOrigem = $"Origem"
@onready var LabelDestino = $"Destino"
@onready var LabelPontos = $"Pontuação"

# Avisa quando o estado de seleção DESTA CARTA muda.
signal selecao_individual_alterada(carta: CartaDestino, novo_estado_selecao: bool)

func _init(_pontos: int = 0) -> void:
	pontos = _pontos
	completado = false
	esta_selecionada = false
	selecionavel = true


func configurar_dados(dados: Dictionary) -> void:
	cidade_origem = dados.get("origem", "desconhecida")
	cidade_destino = dados.get("destino", "desconhecida")
	pontos = dados.get("pontos", 0)
	esta_selecionada = false


func _ready():
	# Aguardar um frame para garantir que todos os nós estão prontos
	await get_tree().process_frame

	LabelOrigem.text = cidade_origem.capitalize()
	LabelDestino.text = cidade_destino.capitalize()
	LabelPontos.text = str(pontos)

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
	if selecionavel:
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


func desativar_selecionavel():
	selecionavel = false
	esta_selecionada = false
	_atualizar_visual_selecao()
	z_index = 0
	base_scale = Vector2.ONE * 0.85
	pivot_offset *= 0.85


func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	self.z_index = 2


func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	self.z_index = 0
