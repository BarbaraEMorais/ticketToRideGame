extends Node

@onready var buttonStart = $Start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonStart.pressed.connect(_on_start_pressed)
	

func _on_start_pressed():
	print("cliquei no botao")
	inicia_partida()

func inicia_partida():
	print(get_parent().get_nomeJogador())
	print(get_parent().get_nomeBots())

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
