class_name MaoJogador extends Mao

# Como as duas ações que encerram o turno do jogador envolvem adicionar uma carta
# a sua mão, podemos emitir um sinal para o fim do turno do jogador a partir daqui

func on_card_grab_started(carta: Carta) -> void:
	print("MAO : ON CARD GRAB STARTED ", self.name)
	super(carta)

	for c in _cartas:
		c.desabilita_hover_anim()
		if c != carta:
			c.disable_drag()

	move_child(carta, -1)


func canceled_card_move(_carta: Carta) -> void:
	print("MAO - canceled_card_move ", self.name)
	_anima_cartas()


func received_own_card(_carta: Carta) -> void:
	print("MAOP - received_own_card ", self.name)
	var indice_carta = _cartas.find(_carta)
	var pos_alvo = indice_carta
	var dist_minima = INF
	
	for i in range(_posicoes.size()):
		var dist = _carta.position.distance_to(_posicoes[i])
		if dist < dist_minima:
			dist_minima = dist
			pos_alvo = i
	
	if pos_alvo != indice_carta:
		_cartas.remove_at(indice_carta)
		_cartas.insert(pos_alvo, _carta)
		_calcula_posicoes()

	_anima_cartas()


func on_card_grab_ended(_carta: Carta) -> void:
	for c in _cartas:
		c.habilita_hover_anim()
		c.enable_drag()
