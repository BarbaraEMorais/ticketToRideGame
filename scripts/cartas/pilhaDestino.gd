class_name PilhaDestino extends Pilha

func _criar_pilha_inicial() -> void:
	# assign faz a conversão de CartaDestino para Carta
	self._cartas.assign(FactoryCarta.criar_pilha_destino())
	if self._cartas.is_empty() and Engine.is_editor_hint(): # Testando se as cartas de pilha foram criadas
		print("Atenção: Pilha de trem vazia após criação pela Factory.")
	else:
		print("Pilha de trem criada com %s cartas." % self._cartas.size())
	
