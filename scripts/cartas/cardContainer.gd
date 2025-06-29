class_name CardContainer extends Container

signal holding_card(carta: Carta, container: CardContainer)
signal mouse_left_container(container: CardContainer)
signal mouse_over_container(container: CardContainer)

var can_receive_cards := true
var show_highlight = false

var can_player_interact := true

func set_signals_to_manager(manager: CardManager) -> void:
	mouse_left_container.connect(manager.on_mouse_leaving_container)
	mouse_over_container.connect(manager.on_mouse_over_container)
	holding_card.connect(manager.on_holding_card)


func connect_carta(carta: Carta) -> void:
	carta.inicia_arrasto.connect(on_card_grab_started)
	carta.fim_do_arrasto.connect(on_card_grab_ended)


func disconnect_carta(carta: Carta) -> void:
	carta.inicia_arrasto.disconnect(on_card_grab_started)
	carta.fim_do_arrasto.disconnect(on_card_grab_ended)


func on_card_grab_started(carta: Carta) -> void:
	holding_card.emit(carta, self)


func on_card_grab_ended(_carta: Carta) -> void:
	pass


func _on_mouse_entered() -> void:
	mouse_over_container.emit(self)
	

func _on_mouse_exited() -> void:
	mouse_left_container.emit(self)


func received_own_card(_carta: Carta) -> void:
	pass


func canceled_card_move(_carta: Carta) -> void:
	pass


func add_carta(_carta: Carta) -> void:
	pass


func remove_carta(_carta: Carta) -> void:
	pass


func _ready() -> void:
	pass


func accepts_card(_carta: Carta) -> bool:
	return can_receive_cards


func disable_container() -> void:
	can_receive_cards = false


func enable_container() -> void:
	can_receive_cards = true


func _process(_delta: float) -> void:
	pass


func highlight() -> void:
	pass


func disable_highlight() -> void:
	pass
