extends Control

@onready var nomeJogador = $NomeJogador
@onready var buttonCadastroJogador = $ButtonCadastroJogador
@onready var feedbackCadastro = $FeedbackCadastro
@onready var qtdJogadores = $QuantidadeJogadores.value

var gerenciadorJogadores

func _ready() -> void:
	$QuantidadeJogadores.min_value = 2
	$QuantidadeJogadores.max_value = 5
	gerenciadorJogadores = load("res://scripts/jogadores/DadosJogadores.gd").new()
	buttonCadastroJogador.pressed.connect(_on_cadastrar_pressed)
	print("oi")

func on_qtd_jogadores_changed(value):
	print("num jogadores: ", value)

func _on_cadastrar_pressed():
	print("Botão pressionado")

	var nome = nomeJogador.text.strip_edges()
	
	if nome == "":
		feedbackCadastro.text = "Preencha como gostaria de ser chamado!"
		feedbackCadastro.modulate = Color(1,0,0)
		return
	
	gerenciadorJogadores.salvar_usuario(nome)
	print(nome)
	buttonCadastroJogador.disabled = true
	feedbackCadastro.text = "Cadastro realizado com sucesso!"
	feedbackCadastro.modulate = Color(0,1,0)
	
	nomeJogador.text = nome
	nomeJogador.editable = false

func _process(delta: float) -> void:
	pass
