extends Node

class_name FactoryCarta 

static var arquivo_cartas := preload("res://cartas_ttr_caminho.json") 
static var arquivo_cartas_destino := preload("res://assets/json/Destino.json")

const _TEMPLATE_CARTA_TREM : PackedScene = preload("res://cenas/cartaTrem.tscn") 
const _TEMPLATE_CARTA_DESTINO : PackedScene = preload("res://cenas/cartaDestino.tscn") 

@export var cartas : Array[Dictionary]= [] 

func _ready() -> void:
	cartas.clear()
	var r_cartas_base : Array[Carta] 

	r_cartas_base = criar_cartas_da_pilha("PILHA_TREM")
	for carta_b in r_cartas_base:
		if carta_b is CartaTrem:
			var ct = carta_b as CartaTrem
			cartas.append({"Pilha": "PILHA_TREM", "CartaNode": ct, "Tipo": "Trem", "Cor": ct.cor, "ID_Def": ct.definicao_id})
		else:
			cartas.append({"Pilha": "PILHA_TREM", "CartaNode": carta_b, "Erro": "Não é CartaTrem."})
			
	r_cartas_base = criar_pilha_destino() as Array[Carta]
	for carta_b in r_cartas_base:
		if carta_b is CartaDestino:
			var cd = carta_b as CartaDestino
			cartas.append({
				"Pilha": "PILHA_DESTINO", "CartaNode": cd, "Tipo": "Destino", 
				"Origem": cd.cidade_origem, "Destino": cd.cidade_destino, "Pontos": cd.valor_pontos, "ID_Def": cd.definicao_id
			})
		else:
			cartas.append({"Pilha": "PILHA_DESTINO", "CartaNode": carta_b, "Erro": "Não é CartaDestino."})

static func int_if_not_empty(value, default_val : int = 0) -> int:
	if value is int: return value
	if value is float: return int(value)
	if value is String:
		if value.is_valid_int(): return value.to_int()
		elif value.is_valid_float(): return int(value.to_float())
	return default_val

static func criar_carta_destino(dados_entrada: Dictionary) -> CartaDestino:
	var nova_carta := _TEMPLATE_CARTA_DESTINO.instantiate()
	nova_carta.initialize(
		dados_entrada.get("origem"),
		dados_entrada.get("destino"),
		dados_entrada.get("pontos")
	)
	
	return nova_carta

static func criar_pilha_destino() -> Array[CartaDestino]:
	var ret : Array[CartaDestino]
	
	if arquivo_cartas_destino == null or not arquivo_cartas_destino.data:
		printerr("FactoryCarta: 'arquivo_cartas' não carregado ou JSON global mal formatado.")
		return ret
	

	var dados_da_pilha = arquivo_cartas_destino.data
	if not dados_da_pilha is Array:
		printerr("FactoryCarta: JSON da pilha de destina não é um Array.")
		return ret

	for definicao_item in dados_da_pilha:
		if not definicao_item is Dictionary:
			printerr("FactoryCarta: Item na pilha de destino não é um dicionário: " % definicao_item)
			continue
	
		ret.append(criar_carta_destino(definicao_item))
	return ret

static func criar_carta(dados_entrada: Dictionary, contexto_pilha: String) -> Carta:
	var nova_carta_base : Carta = null 
	var template_a_usar : PackedScene = null

	if contexto_pilha == "PILHA_TREM":
		template_a_usar = _TEMPLATE_CARTA_TREM
		if not template_a_usar:
			printerr("FactoryCarta: _TEMPLATE_CARTA_TREM não definido!")
			return null
		nova_carta_base = template_a_usar.instantiate() as Carta 

		if not nova_carta_base is CartaTrem:
			printerr("FactoryCarta (Trem): Template instanciado não é 'CartaTrem'.")
			if nova_carta_base: nova_carta_base.queue_free() 
			return null
		
		var script_carta_trem : CartaTrem = nova_carta_base as CartaTrem
		script_carta_trem.cor = dados_entrada.get("id_tipo_carta", "cor_desconhecida")
		
		var caminho_img : String = dados_entrada.get("imagem", "")
		var sprite_node = script_carta_trem.get_node_or_null("Sprite2D")
		if sprite_node and sprite_node is Sprite2D:
			if not caminho_img.is_empty():
				var tex : Texture2D = load(caminho_img)
				if tex: (sprite_node as Sprite2D).texture = tex
				else: printerr("FactoryCarta (Trem): Falha ao carregar textura: ", caminho_img)
		elif not caminho_img.is_empty():
			printerr("FactoryCarta (Trem): 'SpriteVisual' não encontrado ou não é Sprite2D.")

	elif contexto_pilha == "PILHA_DESTINO":
		template_a_usar = _TEMPLATE_CARTA_DESTINO
		if not template_a_usar:
			printerr("FactoryCarta: _TEMPLATE_CARTA_DESTINO não definido!")
			return null
		nova_carta_base = template_a_usar.instantiate() as Carta 

		if not nova_carta_base is CartaDestino: 
			printerr("FactoryCarta (Destino): Template instanciado não é 'CartaDestino'.")
			if nova_carta_base: nova_carta_base.queue_free()
			return null

		var script_carta_destino : CartaDestino = nova_carta_base as CartaDestino
		if script_carta_destino.has_method("configurar_dados"):
			script_carta_destino.configurar_dados(dados_entrada)
		else:
			printerr("FactoryCarta (Destino): Script 'CartaDestino' não tem 'configurar_dados(dados)'.")
		var caminho_img : String = dados_entrada.get("imagem", "")
		var sprite_node = script_carta_destino.get_node_or_null("Sprite2D")
		if sprite_node and sprite_node is Sprite2D:
			if not caminho_img.is_empty():
				var tex : Texture2D = load(caminho_img)
				if tex: (sprite_node as Sprite2D).texture = tex
				else: printerr("FactoryCarta (Destino): Falha ao carregar textura: ", caminho_img)
		elif not caminho_img.is_empty():
			printerr("FactoryCarta (Trem): 'SpriteVisual' não encontrado ou não é Sprite2D.")
	else:
		printerr("FactoryCarta: Contexto de pilha desconhecido em criar_carta: ", contexto_pilha)
		return null
	
	if nova_carta_base and "visible" in nova_carta_base:
		nova_carta_base.visible = false
	

	return nova_carta_base 


static func criar_cartas_da_pilha(pilha_nome : String) -> Array[Carta]: 
	var ret : Array[Carta] = [] 

	if arquivo_cartas == null or not arquivo_cartas.data:
		printerr("FactoryCarta: 'arquivo_cartas' não carregado ou JSON global mal formatado.")
		return ret
	
	if not pilha_nome in arquivo_cartas.data:
		printerr("FactoryCarta: Pilha '%s' não encontrada no 'arquivo_cartas.json'." % pilha_nome)
		return ret

	var dados_da_pilha = arquivo_cartas.data[pilha_nome]
	if not dados_da_pilha is Array:
		printerr("FactoryCarta: Dados para pilha '%s' no JSON não são um Array." % pilha_nome)
		return ret

	for definicao_item in dados_da_pilha:
		if not definicao_item is Dictionary:
			printerr("FactoryCarta: Item na pilha '%s' não é um dicionário: " % pilha_nome, definicao_item)
			continue

		var carta_criada : Carta = null

		if pilha_nome == "PILHA_TREM":
			var quantidade = int_if_not_empty(definicao_item.get("quantidade"), 0)
			for i in range(quantidade):
				carta_criada = criar_carta(definicao_item, pilha_nome) 
				if carta_criada:
					ret.push_back(carta_criada)
			ret.shuffle()
		elif pilha_nome == "PILHA_DESTINO":
			carta_criada = criar_carta(definicao_item, pilha_nome) 
			if carta_criada:
				ret.push_back(carta_criada)

		

	return ret 


static func _criar_todas_as_cartas_tt_ride_como_array_base() -> Array[Carta]: # nome ruim, mas vou mudar dps
	var todas_as_cartas : Array[Carta] = []
	if arquivo_cartas and arquivo_cartas.data:
		for nome_da_pilha in arquivo_cartas.data:
			todas_as_cartas.append_array(criar_cartas_da_pilha(nome_da_pilha))
		todas_as_cartas.shuffle()
	return todas_as_cartas
