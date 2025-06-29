# jogadorCellLabel.gd
extends Label

func set_text_data(data_text: String):
	self.text = data_text
	# Opcional: configurar Size Flags aqui se quiser que ele expanda em sua célula
	# self.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# self.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# self.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT # Ou CENTER, RIGHT
