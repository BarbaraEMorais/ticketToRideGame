class_name JogadorIA extends Jogador

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var lista_prox_caminho : Array[Dictionary] = []

func has_destination_card():
	for carta in _mao:
		if carta is CartaDestino:
			return true
	
	return false

# Basic djikstra algorith implementation. Terminated early once end is reached
func find_shortest_path(start : String, end : String, map : MapManager) -> Array[Dictionary]:
	var start_id := map.id_via_nome(start)
	var end_id := map.id_via_nome(end)
	
	
	var dist : Dictionary = {}
	var prev : Dictionary = {}
	var nodes_to_test : Array[int] = []
	for cidade_id in map.cidades:
		dist[cidade_id] = 9999
		prev[cidade_id] = []
		nodes_to_test.append(cidade_id)

	dist[start_id] = 0
	
	while not nodes_to_test.is_empty():
		var curr_node : int = 0

		for node in dist:
			if dist[node] < dist[curr_node]:
				curr_node = node
		
		if curr_node == end_id:
			# Finish search
			return prev[curr_node]
		nodes_to_test.erase(curr_node)

		var available_paths : Array[Caminho]= map.caminhos.filter(
			func(cam : Caminho):
				if not cam.origem.cidade_id == curr_node or cam.destino.cidade_id == curr_node:
					return false
				
				return cam.linhas.all(
					func(lin: Linha):
						return lin.dono != null or lin.dono == self
				)
		)


		for path in available_paths:
			var origin := path.origem.cidade_id
			var dest := path.destino.cidade_id

			if dest == curr_node:
				var temp := dest
				dest = origin
				origin = temp
			
			var tam : int = path.tamanho if path.dono != self else 0

			var alt : int = dist[curr_node] + tam
			if alt < dist[dest]:
				dist[dest] = alt
				prev[dest] = prev[curr_node].append(path)
		
	return []


func compute_best_path(map : MapManager) -> Array[Dictionary]:
	var best_path : Array[Dictionary] = []
	var best_points = 0

	for carta in get_mao().get_cartas():
		if carta is CartaDestino and (carta as CartaDestino).pontos > best_points:
			best_path = find_shortest_path(carta.cidade_origem, carta.cidade_destino, map)

	return best_path

static func create(nome : String, cor : String, pos_status: Vector2 = Vector2(0,0), pos_mao: Vector2 = Vector2(0,0)) -> Jogador:
	var jogador_cena = load("res://cenas/JogadorIA.tscn")
	var novo = jogador_cena.instantiate()
	novo._nome = nome
	novo._trens = 45
	novo._pontos= 0
	novo.set_card_color(cor)
	return novo

func buy_destination_card(part : Partida):
	var num_cartas := rng.randi_range(1, 3)
	for i in range(num_cartas):
		if get_mao().can_receive_card():
			var carta_dest : CartaDestino = part.mesa.get_pilha_destino().comprar_carta_da_pilha_IA()
			get_mao().add_carta(carta_dest)

func buy_exposed_train(part: Partida, color : String):
	var exposed_pile : PilhaExposta = part.mesa.get_pilha_exposta()

	for carta in exposed_pile._cartas:
		if carta.cor == color:
			if get_mao().accepts_card(carta):
				part.mesa.get_pilha_exposta().remove_carta(carta)
				get_mao().add_carta(carta)

func buy_pile_train(part: Partida):
	if get_mao().can_receive_card():
		get_mao().add_carta(part.mesa._pilha_trem.ai_buy_card())
		
			

func buy_route(route):
	pass

func exposed_pile_has_card_of_color(part : Partida, color: String) -> bool:
	var exposed_pile : PilhaExposta = part.mesa.get_pilha_exposta()

	for carta in exposed_pile._cartas:
		if carta.cor == color:
			return true
	
	return false


func can_buy_route(route : Dictionary) -> bool:
	var num_cards_of_color := 0
	for carta in get_mao()._cartas:
		if carta is CartaTrem and carta.cor == route['color']:
			num_cards_of_color+= 1

	return num_cards_of_color >= route['tamanho']

func is_route_owned(cam : Caminho) -> bool:
	for linha in cam.linhas:
		if linha.dono == null: # Pelo menos uma linha no caminho não tem dono
			return false
			
	return true

func buy_random_cheap_route(part: Partida):
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

	
	# Check if there's destination cards in hand
	if not has_destination_card():
		buy_destination_card(part)
		turnOver.emit()
		return
	
	# Check if there's a viable path
	if lista_prox_caminho.is_empty():
		var temp : Array[Dictionary] = compute_best_path(part.tabuleiro)
		if temp.is_empty():
			buy_destination_card(part)
			turnOver.emit()
			return
		lista_prox_caminho = temp
	
	# Check if there's any owned routes in computed path
	for route in lista_prox_caminho:
		if is_route_owned(route['caminho']):
			compute_best_path(part.tabuleiro)
			break

	var cheapest_route = lista_prox_caminho[0]
	# Check if any route in path can be bought
	for route in lista_prox_caminho:
		if can_buy_route(route):
			buy_route(route)
			return
		if cheapest_route['tamanho'] > route['tamanho']:
			cheapest_route = route

	for i in range(2):
		if cheapest_route['cor'] == "grey":
			buy_pile_train(part)
		
		else:
			if exposed_pile_has_card_of_color(part, cheapest_route['cor']):
				buy_exposed_train(part, cheapest_route['cor'])
			else:
				buy_pile_train(part)
	
	await get_tree().create_timer(2).timeout
