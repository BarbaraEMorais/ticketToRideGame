class_name CartaDestino extends Carta


#to do: como vai ser feito a lógica de cidade inicial e final do destino 
var pontos: int
var completado: bool
var cidade_origem: String
var cidade_destino: String

func _init(_pontos: int=0, _img_path: String = "res://assets/exodia.jpeg") -> void:
	pontos= _pontos
	completado = false
	
