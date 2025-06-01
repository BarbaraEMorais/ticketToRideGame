class_name PilhaDestino extends Pilha

signal selecao_cartas_destino_solicitada

func criarpilha_inicial() -> void:
	print("CHEGOU AQUIIIII")
	self._cartas.assign(FactoryCarta.criar_pilha_destino())
	if self._cartas.is_empty() and Engine.is_editor_hint():
		print("Atenção: Pilha de trem vazia após criação pela Factory.")
	else:
		print("Pilha de Destino criada com %s cartas." % self._cartas.size())
		
func comprar_carta_da_pilha() -> Carta: # Sobrescrevendo o método da classe Pilha
	
	if _cartas.size() >= 1:
		print("PilhaDestino: Clique detectado. Solicitando início da seleção de cartas destino.")
		emit_signal("selecao_cartas_destino_solicitada")
	else:
		print("PilhaDestino: Não há cartas destino suficientes para iniciar a seleção (%s restantes)." % _cartas.size())
	
	return null 

func puxar_cartas_para_tela_selecao(quantidade: int) -> Array[CartaDestino]:
	var cartas_puxadas: Array[CartaDestino] = []
	
	if _cartas.size() < quantidade:
		print("PilhaDestino: Aviso! Tentando puxar %s cartas, mas só %s disponíveis." % [quantidade, _cartas.size()])
		quantidade = _cartas.size() 

	for i in range(quantidade):
		if not _cartas.is_empty():
			var carta: Carta = _cartas.pop_front() 
			
			if carta is CartaDestino:
				cartas_puxadas.append(carta as CartaDestino)
			
	
	print("PilhaDestino: Puxadas %s cartas para seleção." % cartas_puxadas.size())
	return cartas_puxadas
	
	
	
