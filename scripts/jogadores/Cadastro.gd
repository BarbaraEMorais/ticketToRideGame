extends Control

@onready var nomeJogador = $NomeJogador
@onready var buttonCadastroJogador = $ButtonCadastroJogador
@onready var feedbackCadastro = $FeedbackCadastro
@onready var quantidadeJogadoresSlider = $QuantidadeJogadores
@onready var buttonStart = $Start

var gerenciadorJogadores
var nomes_json = []
var listBotsJogadores : Array[String] = []
var qtdJogadores = 2  # valor inicial padrão

func _ready() -> void:
	buttonStart.disabled = true
	quantidadeJogadoresSlider.min_value = 2
	quantidadeJogadoresSlider.max_value = 5

	qtdJogadores = int(quantidadeJogadoresSlider.value)

	nomes_json = carregar_nomes_json("res://assets/json/nomesBots.json")

	gerenciadorJogadores = load("res://scripts/jogadores/DadosJogadores.gd").new()
	quantidadeJogadoresSlider.value_changed.connect(_on_qtd_jogadores_changed)

func _on_start_pressed():
	listBotsJogadores = sortear_nomes(nomes_json, qtdJogadores)
	listBotsJogadores.insert(0, gerenciadorJogadores.carrega_usuario())
	var partida = Partida.create_partida()
	add_child(partida)
	partida.set_partida(listBotsJogadores, qtdJogadores)

func _on_qtd_jogadores_changed(value):
	qtdJogadores = int(value)
	print("Número de jogadores:", qtdJogadores)

func get_nomeJogador() -> String:
	return nomeJogador.text.strip_edges()

func _on_cadastrar_pressed():
	var nome = get_nomeJogador()
	
	if nome == "":
		feedbackCadastro.text = "Preencha como gostaria de ser chamado!"
		feedbackCadastro.modulate = Color(1, 0, 0)
		return
	
	buttonStart.disabled = false
	gerenciadorJogadores.salvar_usuario(nome)
	
	print("Nome cadastrado: ", nome)
	buttonCadastroJogador.disabled = true
	
	feedbackCadastro.text = "Cadastro realizado com sucesso!"
	feedbackCadastro.modulate = Color(0, 1, 0)
	
	nomeJogador.editable = false
	
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
		listBotsJogadores.append(item["nome"])
	
	print(listBotsJogadores)
	return listBotsJogadores


func get_nomeBots():
	var nomes_bots = listBotsJogadores
	return nomes_bots
