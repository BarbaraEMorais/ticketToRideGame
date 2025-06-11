extends Node

const SAVE_PATH = "user://usuario.save"

func salvar_usuario(nome: String):
	var dados = {
		"nome": nome
	}
	
	var json_string = JSON.stringify(dados)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()

func carrega_usuario():
	if not FileAccess.file_exists(SAVE_PATH):
		return null
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err = json.parse(json_string)
	
	if err == OK and typeof(json.result) == TYPE_DICTIONARY:
		return json.result.get("nome", null)
	else:
		return null
