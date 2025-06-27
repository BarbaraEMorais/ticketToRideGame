class_name PilhaTrem extends Pilha

func criar_pilha_inicial() -> void:
	self._cartas = FactoryCarta.criar_cartas_da_pilha("PILHA_TREM")
	if self._cartas.is_empty() and Engine.is_editor_hint(): # Testando se as cartas de pilha foram criadas
		print("Atenção: Pilha de trem vazia após criação pela Factory.")
	else:
		print("Pilha de trem criada com %s cartas." % self._cartas.size())

# Função para a PilhaExposta puxar uma carta.
func puxar_carta_para_exposta() -> CartaTrem:
	if _cartas.size() > 0:
		var carta: CartaTrem = _cartas.pop_back() 
		print("PilhaTrem: Fornecendo carta '%s' para PilhaExposta." % carta.name if carta else "NIL")
		return carta
	print("PilhaTrem: Vazia, não pode fornecer carta para PilhaExposta.")
	return null
