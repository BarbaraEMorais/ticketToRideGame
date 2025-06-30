extends Node 

func calcular_pontuacao_final(jogadores_array: Array):
	print("Mock Mesa (via script): Simulando cálculo de pontuação final para os jogadores...")
	for jogador_mock in jogadores_array:

		jogador_mock.set_pontos(jogador_mock.get_pontuacao_atual())
		print("Jogador ",jogador_mock.get_nome()," teve seus pontos finalizados para: ",jogador_mock.get_pontos())

# Se sua classe 'Mesa' real tiver outros métodos que 'calculaPontuacao.gd' ou outras partes do
# seu código possam chamar, você os adicionaria aqui também com a lógica mock.
# Exemplo:
# func resetar_partida():
#     print("Mock Mesa: Método 'resetar_partida' chamado.")
