class_name JogadorIA extends Jogador

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var num_cards_bought_in_turn : int = 0
var bought_joker : bool = false

var lista_prox_caminho : Array[Dictionary] = []

func player_owns_path(cam : Caminho):
	return cam.linhas.any(func (l : Linha):
							l.dono == self)

func has_destination_card() -> bool:
	for carta in get_mao().get_cartas():
		if carta is CartaDestino:
			return true
	
	return false

# Basic djikstra algorith implementation. Terminated early once end is reached
func find_shortest_path(start : String, end : String, map : MapManager) -> Array[Caminho]:
	var start_id := map.id_via_nome(start)
	var end_id := map.id_via_nome(end)
	
	if start_id == -1 or end_id == -1:
		return []
	
	var dist : Dictionary = {}
	var prev : Dictionary = {}
	var nodes_to_test : Array[int] = []
	for cidade_id in map.cidades:
		dist[cidade_id] = 9999
		prev[cidade_id] = []
		nodes_to_test.append(cidade_id)

	dist[start_id] = 0
	
	while not nodes_to_test.is_empty():
		var curr_node : int = nodes_to_test[0]
		for node in nodes_to_test:
			if dist[node] < dist[curr_node]:
				curr_node = node
		
		if curr_node == end_id:
			# Finish search
			var ret  : Array[Caminho]
			ret.assign(prev[curr_node])
			return ret
		nodes_to_test.erase(curr_node)

		var available_paths : Array[Caminho]= map.caminhos.filter(
			func(cam : Caminho):
				if cam.origem.cidade_id != curr_node and cam.destino.cidade_id != curr_node:
					return false
				
				return cam.linhas.all(
					func(lin: Linha):
						return lin.dono == null or lin.dono == self
				)
		)


		for path in available_paths:
			var origin := path.origem.cidade_id
			var dest := path.destino.cidade_id

			if dest == curr_node:
				var temp := dest
				dest = origin
				origin = temp
			
			var tam : int = path.tamanho if not player_owns_path(path) else 0

			var alt : int = dist[curr_node] + tam
			if alt <= dist[dest]:
				dist[dest] = alt
				var temp = prev[curr_node].duplicate()
				temp.append(path)
				prev[dest] = temp
		
	return prev[end_id]


func compute_best_path(map : MapManager) -> Array[Dictionary]:
	var dj_result : Array[Caminho] = []
	var best_points = 0

	for carta in get_mao().get_cartas():
		if carta is CartaDestino and (carta as CartaDestino).pontos > best_points:
			dj_result = find_shortest_path(carta.cidade_origem, carta.cidade_destino, map)

	if dj_result.is_empty():
		return []

	var new_arr = dj_result.map(
		func (cam : Caminho) -> Dictionary:
			var res : Dictionary = {}
			
			res['caminho'] = cam
			res['linha'] = cam.linhas[0]
			res['cor'] = ""

			for lin in cam.linhas:
				if lin.dono != null:
					continue
				if lin.color == "grey" or res['cor'].is_empty():
					res['cor'] = lin.color
					res['linha'] = lin
			
			
			res['tamanho'] = cam.tamanho

			return res
	)
	var ret : Array[Dictionary]
	ret.assign(new_arr)
	return ret

static func create(nome : String, cor : String, pos_status: Vector2 = Vector2(0,0), pos_mao: Vector2 = Vector2(0,0)) -> Jogador:
	var jogador_cena = load("res://cenas/JogadorIA.tscn")
	var novo = jogador_cena.instantiate()
	novo._nome = nome
	novo._trens = 45
	novo._pontos= 0
	novo.set_card_color(cor)
	novo._cor=(cor)
	return novo

func buy_destination_card(part : Partida):
	var num_cartas := rng.randi_range(1, 3)
	for i in range(num_cartas):
		if get_mao().can_receive_card():
			if part.mesa.get_pilha_destino().get_quantidade() >0:
				var carta_dest : CartaDestino = part.mesa.get_pilha_destino().comprar_carta_da_pilha_IA()
				get_mao().add_carta(carta_dest)

func buy_exposed_train(part: Partida, color : String):
	var exposed_pile : PilhaExposta = part.mesa.get_pilha_exposta()

	for carta in exposed_pile._cartas:
		if carta.cor == "coringa":
			if num_cards_bought_in_turn == 0 and rng.randi() % 2 == 0:
				if get_mao().accepts_card(carta):
					part.mesa.get_pilha_exposta().remove_carta(carta)
					get_mao().add_carta(carta)
					bought_joker = true
					return

		if carta.cor == color:
			if get_mao().accepts_card(carta):
				part.mesa.get_pilha_exposta().remove_carta(carta)
				get_mao().add_carta(carta)

func buy_pile_train(part: Partida):
	if get_mao().can_receive_card():
		get_mao().add_carta(part.mesa._pilha_trem.ai_buy_card())
		
			

func buy_route(route : Dictionary, part: Partida):
	var linha : Linha = route['linha']
	print("aaaaaaaaaaaaaaaaaaaaaaaaaaaa", self.get_cor())
	
	linha.claim_route(self)
	self.subtrai_trens(linha.trilhos.size())
	self.soma_pontos(part.mesa.PONTOS_POR_ROTA.get(linha.trilhos.size()))
	var num_tri_need = route['tamanho']

	for card in get_mao().get_cartas():
		if (card is CartaTrem and (card as CartaTrem).cor == route['cor']) or (card is CartaTrem and card.cor == 'coringa'):
			get_mao().remove_carta(card)
			num_tri_need -= 1
		
		if num_tri_need == 0:
			break

func exposed_pile_has_card_of_color(part : Partida, color: String) -> bool:
	var exposed_pile : PilhaExposta = part.mesa.get_pilha_exposta()

	for carta in exposed_pile._cartas:
		if carta.cor == color:
			return true
	
	return false


func num_cards_by_color() -> Dictionary:
	var ret := {}
	
	for carta in get_mao().get_cartas():
		if carta is CartaTrem:
			if carta.cor not in ret:
				ret[carta.cor] = 1
			else:
				ret[carta.cor] += 1
	
	return ret

func can_buy_route(route : Dictionary) -> bool:	
	
	
	var cards_of_color := num_cards_by_color()
	
	if route['cor'] == 'grey':
		for color in cards_of_color:
			if cards_of_color[color] >= route['tamanho']:
				return true
		return false

	if route['cor'] not in cards_of_color:
		return false

	if 'coringa' in cards_of_color:
		return cards_of_color[route['cor']] + cards_of_color['coringa'] >= route['tamanho']
	
	return cards_of_color[route['cor']] >= route['tamanho']

func is_route_owned(cam : Caminho) -> bool:
	for linha in cam.linhas:
		if linha.dono == null: # Pelo menos uma linha no caminho não tem dono
			return false
			
	return true

func buy_random_route(part: Partida):
	pass

func jogarTurno(part : Partida) -> void:

	# Em seu turno o jogador IA:
	# 1. Checa se há cartas de destino em mão
	# 	1.1 Se não, compre uma carta
	# 2. Checa se o caminho ótimo até o destino é possível
	# 	2.1 Se não, tente calcular uma nova rota
	#		3.1.1 Se não for possivel, compre uma carta de destino
	# 3. Verifica se tem cartas o suficiente para comprar o caminho
	# 	3.1 Se sim, reinvindica rota
	#	3.2 Se não, compra carta de trem
	#		3.2.1 Se a pilha exposta possuí carta da cor necessária, compre da pilha exposta
	#		3.2.2 Se não, compre da pilha de trems	


	if not get_mao().can_receive_card():
		buy_random_route(part)

	
	# Check if there's destination cards in hand
	if not has_destination_card():
		buy_destination_card(part)
		
		end_turn_timeout()
		print("IA %s não tem cartas de destino, comprou carta de destino" % name)
		return
	
	# Check if there's a viable path
	if lista_prox_caminho.is_empty():
		var temp : Array[Dictionary] = compute_best_path(part.tabuleiro)
		if temp.is_empty():
			buy_destination_card(part)
			print("IA %s não consegue determinar um caminho viável, comprou carta de destino" % name)
			end_turn_timeout()
			return
		lista_prox_caminho = temp
	
	# Check if there's any owned routes in computed path
	for route in lista_prox_caminho:
		if is_route_owned(route['caminho']):
			compute_best_path(part.tabuleiro)
			break

	var cheapest_route = lista_prox_caminho[0]
	# Check if any route in path can be bought
	# If not, keep track of the cheapest
	for route in lista_prox_caminho:
		if can_buy_route(route):
			buy_route(route, part)
			print("IA %s encontrou uma rota em seu caminho ideal que pode comprar, reinvidicou rota" % name)
			end_turn_timeout()
			return
		if cheapest_route['tamanho'] > route['tamanho']:
			cheapest_route = route

	for i in range(2):
		if cheapest_route['cor'] == "grey":
			buy_pile_train(part)
			print("IA %s quer comprar um caminho cinza, comprou carta da pilha" % name)
		
		else:
			if exposed_pile_has_card_of_color(part, cheapest_route['cor']):
				buy_exposed_train(part, cheapest_route['cor'])
				print("IA %s quer comprar carta de uma cor especifica que esta na pilha exposta, comprou carta exposta" % name)
				if bought_joker:
					break
			else:
				buy_pile_train(part)
				print("IA %s não encontrou cor especifica na pilha exposta, comprou da pilha de trem" % name)

	num_cards_bought_in_turn = 0
	bought_joker = false
	end_turn_timeout()

func end_turn_timeout():
	await get_tree().create_timer(2).timeout
	turnOver.emit()
