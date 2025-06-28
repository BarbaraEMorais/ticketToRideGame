class_name PilhaExposta extends CardContainer

const MAX_CARTAS_EXPOSTAS: int = 5
const LARGURA_CARTA: float = 146.0
const ESPACAMENTO_ENTRE_CARTAS: float = 20.0
const LARGURA_CARTA_EM_PE: float = 146.0
const ALTURA_CARTA_EM_PE: float = 250.0

const ESPACAMENTO_VERTICAL_ENTRE_CARTAS: float = 20.0 
const LARGURA_VISUAL_CARTA_DEITADA: float = ALTURA_CARTA_EM_PE
const ALTURA_VISUAL_CARTA_DEITADA: float = LARGURA_CARTA_EM_PE  

signal carta_tomada_da_exposta(carta: CartaTrem) 

var _cartas: Array[CartaTrem] 
var pilha_trem: PilhaTrem

func _ready() -> void:
	_cartas.clear()
	if "can_receive_cards" in self:
		can_receive_cards = false
	call_deferred("popular_pilha_exposta_inicialmente")

# Guarda a referência da pilha de trem recebida na variável "pilha_trem" da classe.
# Não sei se é a melhor forma de fazer isso
func set_pilha_trem(p_pilha_trem: PilhaTrem) -> void:
	pilha_trem = p_pilha_trem
	if pilha_trem == null:
		push_warning("PilhaExposta: PilhaTrem não foi definida.")
	else:
		if is_inside_tree() and _cartas.is_empty() and get_child_count() == 0:
			popular_pilha_exposta_inicialmente()


func popular_pilha_exposta_inicialmente() -> void:
	if not is_instance_valid(pilha_trem):
		push_error("PilhaExposta: PilhaTrem não definida ou inválida. Não é possível popular.")
		return
	print("PilhaExposta: Populando inicialmente...")
	for i in range(MAX_CARTAS_EXPOSTAS):
		if _cartas.size() < MAX_CARTAS_EXPOSTAS:
			_repor_uma_carta_na_exposta()
		else:
			break


func _repor_uma_carta_na_exposta() -> void:
	if _cartas.size() >= MAX_CARTAS_EXPOSTAS:
		return

	if not is_instance_valid(pilha_trem):
		push_warning("PilhaExposta: PilhaTrem não está disponível para repor carta.")
		return

	if pilha_trem._cartas.is_empty():
		print("PilhaExposta: PilhaTrem está vazia. Não é possível repor carta.")
		return

	var nova_carta: CartaTrem = pilha_trem.puxar_carta_para_exposta()
	
	if is_instance_valid(nova_carta):
		add_child(nova_carta)
		
		_cartas.append(nova_carta)
		nova_carta.visible = true
		
		nova_carta.drag_enabled = false
		nova_carta.rotation_degrees = 270
		nova_carta.position = pilha_trem.position

		var callable_method = Callable(self, "_on_carta_exposta_foi_clicada")

		var err = nova_carta.carta_clicada.connect(callable_method)  
	
		print("PilhaExposta: Carta '%s' adicionada. Arrastar: %s." % [nova_carta.name, nova_carta.drag_enabled])
		_atualizar_posicoes_cartas()
		
		print("PilhaExposta: Carta '%s' adicionada. Arrastar: %s." % [nova_carta.name, nova_carta.drag_enabled])
		_atualizar_posicoes_cartas()
	else:
		print("PilhaExposta: Não foi possível obter nova carta da PilhaTrem.")


func _on_carta_exposta_foi_clicada(carta_clicada: CartaTrem) -> void:
	if not _cartas.has(carta_clicada):
		print("PilhaExposta: Carta clicada ('%s') não encontrada na lista interna. Ignorando." % carta_clicada.name)
		return

	print("PilhaExposta: Carta '%s' clicada e será adicionada ao jogador." % carta_clicada.name)
	emit_signal("carta_tomada_da_exposta", carta_clicada)
	carta_clicada.drag_enabled = true
	_cartas.erase(carta_clicada)
	call_deferred("_repor_uma_carta_na_exposta")
	call_deferred("_atualizar_posicoes_cartas")
	

func _atualizar_posicoes_cartas() -> void:
	for i in range(_cartas.size()):
		var carta_node: CartaTrem = _cartas[i]
		if not is_instance_valid(carta_node):
			push_error("PilhaExposta: Tentando posicionar carta inválida no índice " + str(i))
			if i < _cartas.size(): 
				_cartas.remove_at(i)
			i -= 1 
			continue

		var x_pos: float = LARGURA_VISUAL_CARTA_DEITADA/2

		var y_pos: float = float(i) * (ALTURA_VISUAL_CARTA_DEITADA + ESPACAMENTO_VERTICAL_ENTRE_CARTAS)
		
		var tween = get_tree().create_tween()
		tween.tween_property(carta_node, "position", Vector2(x_pos, y_pos), 0.2).set_trans(Tween.TRANS_SINE)
	
		var total_width_area = LARGURA_VISUAL_CARTA_DEITADA

		var total_height_area = 0.0
		if _cartas.size() > 0:
			total_height_area = float(_cartas.size()) * ALTURA_VISUAL_CARTA_DEITADA + float(max(0, _cartas.size() - 1)) * ESPACAMENTO_VERTICAL_ENTRE_CARTAS
		
		self.size = Vector2(total_width_area, total_height_area)
		


func remove_carta(carta: Carta) -> void:
	if carta is CartaTrem and carta in _cartas:
		print("PilhaExposta: `remove_carta` chamada para '%s' (não esperado para clique)." % carta.name)
		_cartas.erase(carta as CartaTrem)
		call_deferred("_repor_uma_carta_na_exposta")
		call_deferred("_atualizar_posicoes_cartas")
	else:
		push_warning("PilhaExposta: `remove_carta` chamada para carta desconhecida '%s'." % carta.name)


func canceled_card_move(carta: Carta) -> void:
	print("PilhaExposta: `canceled_card_move` para '%s' (não esperado, arrastar desabilitado)." % carta.name)
	call_deferred("_atualizar_posicoes_cartas") 

func received_own_card(carta: Carta) -> void:
	print("PilhaExposta: `received_own_card` para '%s' (não esperado, arrastar desabilitado)." % carta.name)
	call_deferred("_atualizar_posicoes_cartas")

func accepts_card(_carta: Carta) -> bool:
	return false

func getCartas() -> Array[CartaTrem]:
	return _cartas
