# Mesa.gd
class_name Mesa extends Node2D

@onready var _pilha_trem: PilhaTrem = $PilhaTrem 
@onready var _pilha_exposta: PilhaExposta = $PilhaExposta

# @onready var jogador_atual: Jogador 

func _ready() -> void:
	if not is_instance_valid(_pilha_trem):
		push_error("Mesa: Nó PilhaTrem não encontrado ou inválido.")
		return
	if not is_instance_valid(_pilha_exposta):
		push_error("Mesa: Nó PilhaExposta não encontrado ou inválido.")
		return

	# Configurar a PilhaExposta com a referência da PilhaTrem
	_pilha_exposta.set_pilha_trem(_pilha_trem)

	# Conectar aos sinais, se a Mesa precisar reagir a esses eventos
	_pilha_trem.carta_comprada_da_pilha.connect(_on_carta_comprada_da_pilha_trem)
	_pilha_exposta.carta_tomada_da_exposta.connect(_on_carta_tomada_da_pilha_exposta)
	
	print("Mesa configurada. PilhaExposta conectada à PilhaTrem.")

func get_trem() -> PilhaTrem:
	return _pilha_trem

func get_pilha_exposta() -> PilhaExposta: 
	return _pilha_exposta

# Callback para quando uma carta é comprada da PilhaTrem (clique direto na pilha)
func _on_carta_comprada_da_pilha_trem(carta: CartaTrem) -> void:
	print("Mesa: Jogador comprou a carta '%s' da PilhaTrem." % carta.name)
	# Aqui você adicionaria a carta à mão do jogador atual


# Callback para quando uma carta é tomada da PilhaExposta
func _on_carta_tomada_da_pilha_exposta(carta: CartaTrem) -> void:
	print("Mesa: Jogador tomou a carta '%s' da PilhaExposta." % carta.name)
	
