class_name PilhaTrem extends Pilha

func _criar_pilha_inicial() -> void:
	self._cartas = FactoryCarta.criar_cartas_da_pilha("PILHA_TREM")
	if self._cartas.is_empty() and Engine.is_editor_hint(): # Testando se as cartas de pilha foram criadas
		print("Atenção: Pilha de trem vazia após criação pela Factory.")
	else:
		print("Pilha de trem criada com %s cartas." % self._cartas.size())
	
