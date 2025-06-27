extends "res://addons/gut/test.gd"

var jogador = load("res://scripts/jogadores/jogador.gd")

var cena_partida = load("res://cenas/partida.tscn")

func test_set_partida():
	var instancia = partial_double(cena_partida).instantiate()
	add_child(instancia)
	var nomes: Array[String] = ["Humano", "Bot1", "Bot2"]
	var cor_humano = "vermelho"

	instancia.set_partida(nomes, cor_humano)

	assert_eq(instancia.listaJogadores.size(), 3, "listaJogadores deveria ter 3 jogadores")

	var jogador_humano = instancia.listaJogadores[0]

	assert_is(jogador_humano, Jogador, "Humano deveria ser do tipo Jogador")
	assert_eq(jogador_humano.get_nome(), "Humano", "O nome do jogador_humano deveria ser 'Humano'")
	assert_eq(jogador_humano.get_status().get_node("Bilhete").texture, load("res://assets/Bilhete_vermelho.png"), "A cor do jogador_humano deveria ser 'vermelho'")
	assert_eq(jogador_humano.get_mao().position, Vector2(980, 1015), "Mão do jogador humano deveria estar na posição (980, 1015)")
	assert_eq(jogador_humano.get_status().position, Vector2(192, 990), "Card de status do jogador humano deveria estar na posição (192, 990)")
	
	assert_not_null(instancia.mesa)
