class_name Carta extends CartaArrastavel

signal carta_morreu(carta: Carta)
signal hovered(carta: Carta)
signal hovered_off(carta: Carta)
#signal descartada_por(jogador : Jogador)


func _init(_img_path: String = "res://assets/exodia.jpeg") -> void:
	pass
