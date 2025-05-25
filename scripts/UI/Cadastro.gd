extends Control

@onready var nomeJogador = $NomeJogador
@onready var buttonCadastroJogador = $ButtonCadastroJogador
@onready var feedbackCadastro = $FeedbackCadastro

var gerenciadorJogadores

func _ready() -> void:
	gerenciadorJogadores = load("res://scripts/jogadores/DadosJogadores.gd").new()
	buttonCadastroJogador.pressed.connect(_on_cadastrar_pressed)
	print("oi")

func _on_cadastrar_pressed():
	print("Botão pressionado")

	var nome = nomeJogador.text.strip_edges()
	
	if nome == "":
		feedbackCadastro.text = "Preencha como gostaria de ser chamado!"
		feedbackCadastro.modulate = Color(1,0,0)
		return
	
	gerenciadorJogadores.salvar_usuario(nome)
	print(nome)
	feedbackCadastro.text = "Cadastro realizado com sucesso!"
	feedbackCadastro.modulate = Color(0,1,0)
	
	nomeJogador.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
