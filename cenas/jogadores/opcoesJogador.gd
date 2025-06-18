extends Control

var numBots
var card = preload("res://cenas/jogadores/cardJogador.tscn").instantiate()
@onready var container = $CenterContainer/HBoxContainer
var nomes_json = carregar_nomes_json("res://assets/json/nomesBots.json")
var nomes_jogador : Array[String]

func _ready():
	container.add_child(card)
	card.connect("cor_selecionada", _on_cor_selecionada)
	card.connect("cadastro_confirmado", _on_cadastro_confirmado)

func _on_cor_selecionada(cor):
	print("Cor escolhida:", cor)

func _on_cadastro_confirmado(nome, cor):
	nomes_jogador = sortear_nomes(nomes_json, numBots)
	nomes_jogador.insert(0, nome)

func _on_iniciar_partida_pressed() -> void:
	var cena_partida = load("res://cenas/partida.tscn")
	var partida = cena_partida.instantiate()

	get_tree().current_scene.call_deferred("free")
	get_tree().root.add_child(partida)
	get_tree().current_scene = partida

	partida.set_partida(nomes_jogador)

### Nomes bots
func carregar_nomes_json(caminho: String) -> Array:
	var file = FileAccess.open(caminho, FileAccess.READ)
	if not file:
		push_error("Erro ao abrir arquivo JSON")
		return []
	var conteudo = file.get_as_text()
	file.close()

	var json_parser = JSON.new()
	var result = json_parser.parse(conteudo)

	if result != OK:
		push_error("Erro ao fazer parse do JSON: %s" % result)
		return []

	return json_parser.data


func sortear_nomes(nomes_array: Array, quantidade: int) -> Array[String]:
	var nomes_copiados = nomes_array.duplicate()
	nomes_copiados.shuffle()
	quantidade = quantidade - 1

	if quantidade > nomes_copiados.size():
		quantidade = nomes_copiados.size()

	var selecionados = nomes_copiados.slice(0, quantidade)

	for item in selecionados:
		nomes_jogador.append(item["nome"])
	return nomes_jogador
