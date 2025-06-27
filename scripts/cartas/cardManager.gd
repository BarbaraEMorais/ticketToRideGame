class_name CardManager extends Node

var current_carta: Carta
var current_parent: CardContainer
var new_parent: CardContainer

var left_curr_container : bool
var just_moved: bool


func reset_state() -> void:
	current_carta = null
	current_parent = null
	new_parent = null
	left_curr_container = false
	just_moved = false


func on_holding_card(carta: Carta, container: CardContainer) -> void:
	print("CARD MANAGER - on_holding_card", self.name)

	current_carta = carta
	current_parent = container
	left_curr_container = false
	just_moved = false

	carta.fim_do_arrasto.connect(on_grab_ended)


func on_grab_ended(carta: Carta) -> void:
	print("CARD MANAGER - on_grab_ended ", self.name)
	just_moved = true

	if new_parent == null:
		if left_curr_container:
			current_parent.canceled_card_move(carta)
		else:
			current_parent.received_own_card(carta)
	else:
		if new_parent == current_parent:
			current_parent.received_own_card(carta)
		else:
			if new_parent.accepts_card(carta):
				current_parent.remove_carta(carta)
				new_parent.add_carta(carta)
			else:
				current_parent.canceled_card_move(carta)

	carta.fim_do_arrasto.disconnect(on_grab_ended)
	reset_state()


func on_mouse_over_container(container: CardContainer) -> void:
	print("CARD MANAGER - on_carta_over_container ", self.name)
	if not container.can_receive_cards:
		return

	if new_parent:
		new_parent.disable_highlight()

	if container.accepts_card(current_carta):
		container.highlight()

	new_parent = container


func on_mouse_leaving_container(container: CardContainer) -> void:
	if just_moved:
		return 

	if container:
		container.disable_highlight()

	print("CARD MANAGER - on_carta_leaving_container ", self.name)
	left_curr_container = true


	if container == current_parent:
		return
	
	if container == new_parent:
		new_parent = null


func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	pass
