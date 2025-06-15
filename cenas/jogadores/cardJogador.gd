extends Control

signal cor_selecionada(cor)
signal cadastro_confirmado(nome, cor)

var cor_atual = Color(1,1,1)
var botoes_cor = []

@onready var nome_jogador = $ColorRect/NomeJogador
@onready var btn_confirmar = $ColorRect/btnConfirmar

func _ready():

	botoes_cor = [
		$ColorRect/BoxContainer/btnVermelho,
		$ColorRect/BoxContainer/btnAzul,
		$ColorRect/BoxContainer/btnVerde,
		$ColorRect/BoxContainer/btnLaranja,
		$ColorRect/BoxContainer/btnAmarelo,
		$ColorRect/BoxContainer/btnRoxo,
		$ColorRect/BoxContainer/btnPreto
	]

	# conecta todos os botões a selecionar_cor, passando o botão como parâmetro
	for botao in botoes_cor:
		botao.pressed.connect( func(): selecionar_cor(botao) )

	btn_confirmar.pressed.connect(_on_confirmar_pressed)

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
		"btnVermelho": cor_atual = Color(1,0,0)
		"btnAzul":    cor_atual = Color(0,0,1)
		"btnVerde":   cor_atual = Color(0,1,0)
		"btnLaranja": cor_atual = Color(1,0.5,0)
		"btnAmarelo": cor_atual = Color(1,1,0)
		"btnRoxo":    cor_atual = Color(0.5,0,0.5)
		"btnPreto":   cor_atual = Color(0,0,0)

	emit_signal("cor_selecionada", cor_atual)

	## Desabilita todos os botões após a escolha
	#for b in botoes_cor:
		#b.disabled = true


func _on_confirmar_pressed():
	var nome = nome_jogador.text
	emit_signal("cadastro_confirmado", nome, cor_atual)

	nome_jogador.editable = false
	btn_confirmar.disabled = true
	### preciso tratar erro de editar cor pós confirmacao
