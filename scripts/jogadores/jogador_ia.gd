class_name JogadorIA extends Jogador

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


static func create(nome : String, cor : String, pos_status: Vector2, pos_mao: Vector2) -> Jogador:
	var jogador_cena = load("res://cenas/JogadorIA.tscn")
	var novo = jogador_cena.instantiate()
	novo._nome = nome
	novo._trens = 45
	novo._pontos= 0
	novo.set_card_color(cor)
	return novo
