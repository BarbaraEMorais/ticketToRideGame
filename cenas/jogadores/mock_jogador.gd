# testes/mocks/mock_jogador.gd
extends Jogador # <--- MUITO IMPORTANTE: Este mock herda do seu script Jogador!

# Vamos adicionar propriedades para que possamos definir os valores do mock
# durante o teste, sem precisar que o mock_jogador tenha uma "mão" ou "cartas" reais.
var _mock_nome: String
var _mock_pontuacao_atual: int
var _mock_qtd_rotas_reivindicadas: int
var _mock_qtd_rotas_nao_reivindicadas: int
var _mock_pontos_finais: int # Simula a pontuação final calculada pela Mesa

func _init(p_nome: String, p_pontuacao_atual: int, p_qtd_rotas_reivindicadas: int, p_qtd_rotas_nao_reivindicadas: int):
	# Inicializa as propriedades do mock
	_mock_nome = p_nome
	_mock_pontuacao_atual = p_pontuacao_atual
	_mock_qtd_rotas_reivindicadas = p_qtd_rotas_reivindicadas
	_mock_qtd_rotas_nao_reivindicadas = p_qtd_rotas_nao_reivindicadas
	_mock_pontos_finais = p_pontuacao_atual # Começa igual, a Mesa 'seta' o final

# --- Sobrescrita dos métodos de Jogador que calculaPontuacao.gd usa ---
# Agora você pode remover as verificações 'has_method' no calculaPontuacao.gd
# porque esses métodos existirão de fato!

func get_nome() -> String:
	return _mock_nome

func get_pontuacao_atual() -> int:
	return _mock_pontuacao_atual

func get_qtd_rotas_reivindicadas() -> int:
	return _mock_qtd_rotas_reivindicadas

func get_qtd_rotas_nao_reivindicadas() -> int:
	return _mock_qtd_rotas_nao_reivindicadas

func get_pontos() -> int:
	# Retorna a pontuação final que seria definida pela Mesa
	return _mock_pontos_finais

func set_pontos(new_points: int):
	# Permite que a Mesa (mock) defina a pontuação final no Jogador mock
	_mock_pontos_finais = new_points

# Para os métodos que não são importantes para este teste, mas que existem em 'Jogador',
# podemos retornar valores padrão ou nulos.
func get_mao() -> Mao: # Ou o tipo real de Mao
	# Retorna um Node vazio para simular a mão, se necessário
	var mock_mao = Node.new()
	mock_mao.call_deferred("add_method", "get_cartas_destino", Callable(func(): return []))
	return mock_mao

# Adicione outros métodos de Jogador aqui conforme necessário, com retornos padrões.
# Ex:
# func soma_pontos(valor: int):
# 	_mock_pontuacao_atual += valor
