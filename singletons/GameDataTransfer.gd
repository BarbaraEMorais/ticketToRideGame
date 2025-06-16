extends Node

var players_array: Array = []
var qtd_jogadores: int

func set_match_data(players_arr: Array, _qtd_jogadores):
	players_array = players_arr
	qtd_jogadores = _qtd_jogadores


func get_match_data() -> Dictionary:
	var data = {
		"players_array": players_array,
		"qtd_jogadores": qtd_jogadores
	}

	players_array = []
	return data
