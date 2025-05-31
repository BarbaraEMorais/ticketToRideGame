class_name CartaDestino extends Carta


#to do: como vai ser feito a lógica de cidade inicial e final do destino 
var pontos: int
var completado: bool
var cidade_origem: String
var cidade_destino: String

func _init(origem : String, destido: String, _pontos: int=0, ) -> void:
	pontos= _pontos
	cidade_origem = origem
	cidade_destino = cidade_destino
	completado = false
	
