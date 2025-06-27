class_name CardContainer extends Node2D

signal holding_card(carta: Carta, container: CardContainer)
signal carta_left(carta: Carta, container: CardContainer)
signal carta_over(carta: Carta, container: CardContainer)

@onready var area: Area2D = $Area2D

var can_receive_cards := true
var show_highlight = false


func set_signals_to_manager(manager: CardManager) -> void:
	carta_left.connect(manager.on_carta_leaving_container)
	carta_over.connect(manager.on_carta_over_container)
	holding_card.connect(manager.on_holding_card)


func on_card_grab_started(carta: Carta) -> void:
	holding_card.emit(carta, self)


func on_card_grab_ended(_carta: Carta) -> void:
	pass


func _on_area_entered(other_area: Area2D) -> void:
	var carta = other_area.get_parent() as Carta
	if not carta:
		return
	
	carta_over.emit(carta, self)
	

func _on_area_exited(other_area: Area2D) -> void:
	print("CARD-CONTAINER : _on_area_exited ", self.name)
	var carta = other_area.get_parent() as Carta
	if not carta:
		return
	
	carta_left.emit(carta, self)


func received_own_card(_carta: Carta) -> void:
	pass


func canceled_card_move(_carta: Carta) -> void:
	pass


func connect_carta(carta: Carta) -> void:
	carta.inicia_arrasto.connect(on_card_grab_started)
	carta.fim_do_arrasto.connect(on_card_grab_ended)


func disconnect_carta(carta: Carta) -> void:
	carta.inicia_arrasto.disconnect(on_card_grab_started)
	carta.fim_do_arrasto.disconnect(on_card_grab_ended)


func add_carta(_carta: Carta) -> void:
	pass


func remove_carta(_carta: Carta) -> void:
	pass


func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)


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
