class_name CartaTrem extends Carta

var cor: String


func _init(_cor= "", _img_path: String = "res://assets/exodia.jpeg") -> void:
	cor=_cor
func configurar_dados(dados: Dictionary) -> void:
	cor = dados.get("cor")
