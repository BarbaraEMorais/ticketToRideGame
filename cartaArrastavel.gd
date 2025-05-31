class_name CartaArrastavel extends Node2D

signal inicia_arrasto(carta: Carta)
signal fim_do_arrasto(carta: Carta)
signal carta_clicada(carta: Carta)

var pos_inicial_arrasto = Vector2.ZERO
var mouse_offset = Vector2.ZERO 
var posicao_original = Vector2.ZERO
var arrastando = false
var hover = true
var animacao_hover: Tween

@export var drag_enabled = true
@export var cancela_arrasto = false

@onready var click_area: Area2D = $Area2D

func _ready() -> void:
	posicao_original = position

	click_area.input_event.connect(_on_click_area_input_event)
	click_area.mouse_entered.connect(_mouse_na_carta)
	click_area.mouse_exited.connect(_mouse_saiu_da_carta)


func _mouse_na_carta() -> void:
	if arrastando or not hover:
		return
		
	if animacao_hover:
		animacao_hover.kill()
	
	animacao_hover = create_tween()
	animacao_hover.tween_property(self, "scale", Vector2.ONE * 1.2, 0.1)


func _mouse_saiu_da_carta() -> void:
	if arrastando:
		return
	
	if animacao_hover:
		animacao_hover.kill()
	
	animacao_hover = create_tween()
	animacao_hover.tween_property(self, "scale", Vector2.ONE, 0.1  )


func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return 
	if event.pressed:
		pos_inicial_arrasto = get_global_mouse_position()
		mouse_offset = position - pos_inicial_arrasto

		if drag_enabled:
			arrastando = true
			print("CARTA ('%s') - Drag_enabled: true. Emitindo inicia_arrasto." % name) # DEBUG
			inicia_arrasto.emit(self)
			z_index = 1

			if animacao_hover:
				animacao_hover.kill()
			scale = Vector2.ONE
		else:
			print("CARTA ('%s') - Drag_enabled: false. Clique pressionado." % name) # DEBUG
			pass

	else: 
		var was_click = (pos_inicial_arrasto - get_global_mouse_position()).length() < 5.0

		if arrastando: 
			print("CARTA ('%s') - Estava arrastando. Finalizando arrasto." % name) # DEBUG
			_finaliza_arrastar() 
		
	
		if was_click:
			print("CARTA ('%s') - Foi um clique curto. Emitindo carta_clicada." % name) # DEBUG
			print("AAAAAAAAAAAAAAAAAAAA")
			carta_clicada.emit(self)
		else:
			print("CARTA ('%s') - Não foi um clique curto (foi um arrasto ou nada)." % name) # DEBUG

func _process(_delta: float) -> void:
	if arrastando and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_finaliza_arrastar()
	
	if arrastando:
		position = get_global_mouse_position() + mouse_offset


func _finaliza_arrastar() -> void:
	arrastando = false
	print("CARTA - emit fim_do_arrasto")
	fim_do_arrasto.emit(self)
	z_index = 0
	
	if cancela_arrasto:
		position = posicao_original


func enable_drag() -> void:
	drag_enabled = true


func disable_drag() -> void:
	drag_enabled = false


func habilita_hover_anim() -> void:
	hover = true


func desabilita_hover_anim() -> void:
	hover = false


func set_cancela_arrasto(cancelar: bool) -> void:
	cancela_arrasto = cancelar
