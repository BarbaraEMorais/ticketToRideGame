class_name CartaDestino extends Carta


#to do: como vai ser feito a lógica de cidade inicial e final do destino 
var pontos: int
var completado: bool
var cidade_origem: String
var cidade_destino: String

@onready var LabelOrigem = $"Area2D/Sprite2D/Origem"
@onready var LabelDestino = $"Area2D/Sprite2D/Destino"
@onready var LabelPontos = $"Area2D/Sprite2D/Pontuação"

func initialize(origem : String, destino: String, _pontos: int=0, ) -> void:
	pontos= _pontos
	cidade_origem = origem
	cidade_destino = cidade_destino
	
	completado = false
	
	
func _ready() -> void:
	LabelOrigem.text = cidade_origem.capitalize()
	LabelDestino.text = cidade_destino.capitalize()
	LabelPontos.text = str(pontos)
