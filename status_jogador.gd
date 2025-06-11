extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_card_color("vermelho") #PLACEHOLDER


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_card_color(color: String) -> void:
	var color_path = "res://assets/Bilhete_" + color + ".png"
	$Bilhete.texture = load(color_path)

func set_nome(nome: String) -> void:
	$Nome.text = nome

func set_pontos(num: int) -> void:
	$Pontos.text = num

func set_qtd_rotas(num: int) -> void:
	$Qtd_Rotas.text = num
	
func set_qtd_vagoes(num: int) -> void:
	$Qtd_Vagoes.text = num

func set_qtd_mao(num: int) -> void:
	$Qtd_Mao.text = num
