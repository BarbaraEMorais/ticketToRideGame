extends Control

@onready var nomeJogador = $NomeJogador
@onready var buttonCadastroJogador = $ButtonCadastroJogador
@onready var feedbackCadastro = $FeedbackCadastro
@onready var quantidadeJogadoresSlider = $QuantidadeJogadores
@onready var buttonStart = $Start

var gerenciadorJogadores
var listaJogadores : Array[String] = []
var qtdJogadores = 2  # valor inicial padrão
var sinal_bloqueado = false
var cor_atual = "vermelho"
var botoes_cor = []
var nomes_json = carregar_nomes_json("res://assets/json/nomesBots.json")

signal cor_selecionada(cor)
signal cadastro_confirmado(nome, cor)


func _ready() -> void:
	buttonStart.disabled = true
	qtdJogadores = 2

	nomes_json = carregar_nomes_json("res://assets/json/nomesBots.json")

	gerenciadorJogadores = load("res://scripts/jogadores/DadosJogadores.gd").new()

	botoes_cor = [
		$BoxContainer/btnVermelho,
		$BoxContainer/btnAzulClaro,
		$BoxContainer/btnVerde,
		$BoxContainer/btnLaranja,
		$BoxContainer/btnAmarelo,
		$BoxContainer/btnRosa,
		$BoxContainer/btnPreto
		]

	# conecta todos os botões a selecionar_cor, passando o botão como parâmetro
	for botao in botoes_cor:
		botao.pressed.connect( func(): selecionar_cor(botao) )

func selecionar_cor(botao):
	# Impede se já tiver uma cor escolhida (se todos estiverem disabled, ninguém deve conseguir mais clicar)
	if botoes_cor[0].disabled:
		return
		
	# Reseta todos os botões pra normal
	for b in botoes_cor:
		if b != botao:
			b.button_pressed = false

	# Marca o botão clicado
	botao.button_pressed = true

	# Salva cor escolhida
	match botao.name:
		"btnVermelho": cor_atual = "vermelho"
		"btnVerde":   cor_atual = "verde"
		"btnLaranja": cor_atual = "laranja"
		"btnAmarelo": cor_atual = "amarelo"
		"btnRosa":    cor_atual = "rosa"
		"btnPreto":   cor_atual = "preto"
		"btnAzulClaro": cor_atual = "azul_claro"

	emit_signal("cor_selecionada", cor_atual)


func _on_start_pressed():
	var nome = get_nomeJogador()
	if nome == "":
		feedbackCadastro.text = "Preencha como gostaria de ser chamado!"
		feedbackCadastro.modulate = Color(1, 0, 0)
		return
	
	$"Timer".start()
	buttonStart.disabled = false
	gerenciadorJogadores.salvar_usuario(nome)

	feedbackCadastro.text = "Cadastro realizado com sucesso!"
	feedbackCadastro.modulate = Color(0, 1, 0)
	nomeJogador.editable = false
	
	listaJogadores = sortear_nomes(nomes_json, qtdJogadores)
	listaJogadores.insert(0, nome)
	
	var cena_partida = load("res://cenas/partida.tscn")
	var partida = cena_partida.instantiate()
	
	get_tree().current_scene.call_deferred("free")
	get_tree().root.add_child(partida)
	get_tree().current_scene = partida
	partida.set_partida(listaJogadores, cor_atual)

func _on_qtd_jogadores_changed(value):
	qtdJogadores = int(value)

func get_nomeJogador() -> String:
	return nomeJogador.text.strip_edges()
	
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
		listaJogadores.append(item["nome"])

	return listaJogadores

func get_nomeBots():
	return listaJogadores

func _on_nome_jogador_text_changed(new_text: String) -> void:
	if nomeJogador.text != "":
		buttonStart.disabled = false
	else:
		buttonStart.disabled = true


func _on_quantidade_jogadores_value_changed(value: float) -> void:
	qtdJogadores = int(value)
