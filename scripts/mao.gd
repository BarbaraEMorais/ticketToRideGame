class_name Mao extends CardContainer

@export var _cartas: Array[Carta]
var _posicoes: Array[Vector2]
var _limite_cartas: int
var largura_carta := 146
var _contagem_por_cor: Dictionary = {
	"red": 0,
	"blue": 0,
	"green": 0,
	"yellow": 0,
	"black": 0,
	"pink": 0,
	"orange": 0,
	"coringa": 0
}

signal received_new_card

func _ready() -> void:
	super._ready()
	_cartas = []
	_limite_cartas = 6
	_calcula_posicoes()
	print("INSTANCIADA")

func _calcula_posicoes() -> void:
	var qtd_cartas = _cartas.size()

	var padding = 10

	_posicoes.clear()
	
	if _cartas.is_empty():
		return
	
	var largura_total = (largura_carta + padding) * qtd_cartas
	var pos_inicial_x = largura_carta/2.0 - largura_total/2.0

	for i in range(_cartas.size()):
		var pos := Vector2(
			pos_inicial_x + (largura_carta + padding) * i,
			0
		)
		_posicoes.append(pos)


func accepts_card(_carta: Carta) -> bool:
	return _cartas.size() < _limite_cartas

func can_receive_card() -> bool:
	return _cartas.size() < _limite_cartas


func add_carta(carta: Carta) -> void:
	connect_carta(carta)

	_cartas.push_front(carta)
	if is_instance_valid(carta.get_parent()):
		carta.get_parent().remove_child(carta) #tira o pai anterior (pilha)
	add_child(carta)
	if carta is CartaTrem:
		_contagem_por_cor[carta.cor] += 1
	if carta is CartaDestino:
		var escalaNecessaria = largura_carta / carta.size.x
		carta.scale = Vector2(escalaNecessaria, escalaNecessaria)
		
	_calcula_posicoes()
	_anima_cartas()


func remove_carta(carta: Carta) -> void:
	disconnect_carta(carta)
	remove_child(carta)
	_contagem_por_cor[carta.cor] -= 1
	var i = _cartas.find(carta)
	_cartas.remove_at(i)

	_calcula_posicoes()
	_anima_cartas()

func _anima_cartas() -> void:
	for i in range(_cartas.size()):
		var carta = _cartas[i]
		var tween = create_tween()
		tween.tween_property(carta, "rotation_degrees", 0,0)
		tween.tween_property(carta, "position", _posicoes[i], 0.2)

		
func get_limite():
	return _limite_cartas

func get_cartas_na_mao():
	return _cartas.size()

func gerencia_reivindicação(cor_rota: String, tamanho_requerido: int):
	#OBS: FOI CRIADO UM DICIONARIO PRA MAPEAR A QUANTIDADE DE CADA COR DE CARTA NA MÃO DO JOGADOR
	var qtd_coringa = _contagem_por_cor.get("coringa", 0)
	var qtd_cor = _contagem_por_cor.get(cor_rota, 0)
	var cartas_da_cor: Array[CartaTrem] = []
	var cartas_coringa: Array[CartaTrem] = []
	if cor_rota != "grey": # SE A ROTA  NÃO FOR CINZA
		if (_contagem_por_cor.get(cor_rota) + qtd_coringa >= tamanho_requerido): #VÊ SE TEMOS CARTAS SUFICIENTES PRA REIVINDICAR ROTA	
			print("chegou aqui")
			for carta in _cartas:  #PASSA ARMAZENANDO AS CARTAS DA COR REQUISITADA PARA TIRAR DA MÃO POSTERIORMENTE
				if carta is CartaTrem:
					if carta.cor == cor_rota:
						cartas_da_cor.append(carta)
					elif carta.cor == "coringa":
						cartas_coringa.append(carta)
						
			for i in range (tamanho_requerido):
				print ("i:", i)
				if cartas_da_cor.size()>0:
					remove_carta(cartas_da_cor[0]) #TIRA DA MÃO
					cartas_da_cor.pop_front()
				elif cartas_coringa.size()>0:
					remove_carta(cartas_coringa[0])
					cartas_coringa.pop_front()
			return 0
	else: # cor_requerida == "grey"
		
		var maior_qtd = 0
		var cor_maior
		print("coringa:",qtd_coringa)
		for i in _contagem_por_cor:
			if i == "coringa": continue # Pula a chave "coringa" no loop principal
			if  _contagem_por_cor[i]> maior_qtd: # PROCURA A COR DE TREM DE MAIOR QUANTIDADE NA MÃO DO JOGADOR
				maior_qtd= _contagem_por_cor[i]
				cor_maior=i
		print("maior cor", maior_qtd)
		if maior_qtd + qtd_coringa >= tamanho_requerido:  #VÊ SE TEMOS CARTAS SUFICIENTES PRA REIVINDICAR ROTA	
			for carta in _cartas:
				if carta is CartaTrem:
					if carta.cor == cor_maior:
						cartas_da_cor.append(carta)
					elif carta.cor == "coringa":
						cartas_coringa.append(carta)
						
			for i in range (tamanho_requerido):
				print ("i:", i)
				if cartas_da_cor.size()>0:
					remove_carta(cartas_da_cor[0]) 
					cartas_da_cor.pop_front()
				else:
							remove_carta(cartas_coringa[0])
							cartas_coringa.pop_front()
			return 0

	

			
