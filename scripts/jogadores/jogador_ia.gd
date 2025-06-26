class_name JogadorIA extends Jogador

var rng : RandomNumberGenerator = RandomNumberGenerator.new()



static func create(nome : String, cor : String, pos_status: Vector2, pos_mao: Vector2) -> Jogador:
	var jogador_cena = load("res://cenas/JogadorIA.tscn")
	var novo = jogador_cena.instantiate()
	novo._nome = nome
	novo._trens = 45
	novo._pontos= 0
	novo.set_card_color(cor)
	return novo

func jogarTurno(mesa : Mesa) -> void:
	# No momento, as ações do jogador IA não tem nenhuma lógica
	var action : int = rng.randi()
	
	await get_tree().create_timer(2).timeout
	
	if action % 2: # Pegar carta de trem
		
		# TODO: Lógica para trems arco-íriis
		for i in range(0, 1):
			var index_selecao := rng.randi_range(0,  mesa.get_pilha_exposta().getCartas().size() -1)
			var carta_sel := mesa.get_pilha_exposta().getCartas()[index_selecao]
			if get_mao().accepts_card(carta_sel):
				mesa.get_pilha_exposta().remove_carta(carta_sel)
				get_mao().add_carta(carta_sel)
			
	else: # Pegar carta de destino
		var num_cartas := rng.randi_range(1, 3)
		for i in range(num_cartas):
			if get_mao().can_receive_card():
				var carta_dest := mesa.get_pilha_destino().comprar_carta_da_pilha_IA()
				get_mao().add_carta(carta_dest)
				
	turnOver.emit()
