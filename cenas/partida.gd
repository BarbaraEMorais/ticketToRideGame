class_name Partida extends Node2D

@export
var listaJogadores : Array[JogadorTemp]

@export_range(2, 6)
var maxJogadores : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_player(jogador : JogadorTemp) -> void:
	if(listaJogadores.size() + 1 > maxJogadores):
		printerr("Não é possível adicionar novo jogador: Partida Cheia")
		return
	
	listaJogadores.append(jogador)
