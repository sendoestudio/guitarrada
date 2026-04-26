extends Control
class_name LevelEditorComplexTimelineInterval

@onready var bpm_lineedit : LineEdit = $BpmLineEdit
@onready var start_lineedit : LineEdit = $IntervalStartLineEdit
@onready var end_lineedit : LineEdit = $IntervalEndLineEdit
@onready var numerator_lineedit : LineEdit = $NumLineEdit
@onready var denominator_lineedit : LineEdit = $DenLineEdit

@onready var up_order_button : Button = $UpButton
@onready var down_order_button : Button = $DownButton

@onready var delete_button : Button = $DeleteButton
@onready var add_button : Button = $AddButton

var _order_index : int = -1

var _complex_handler : LevelEditorComplexTimeline

var internal_errors : String = ""

func set_complex_handler(handler : LevelEditorComplexTimeline):
	_complex_handler = handler
#reorder
#create another
#delete this
#get data
#validade data

func set_index(index : int):
	_order_index = index


func _on_up_button_pressed() -> void:
	#_complex_handler.update_order(_order_index, true)
	_complex_handler.update_box_position(self, true)


func _on_down_button_pressed() -> void:
	#_complex_handler.update_order(_order_index, false)
	_complex_handler.update_box_position(self, false)

func _on_add_button_pressed() -> void:
	_complex_handler.create_internal_box(self)


func _on_delete_button_pressed() -> void:
	_complex_handler.delete_internal_box(self)

func validade_fields() -> bool:
	var errors : int = 0
	
	var end : float = -1
	var start : float = -1
	
	if bpm_lineedit.text == "":
		errors += 1
		internal_errors += "BPM value is empty\n"
	elif !bpm_lineedit.text.is_valid_float():
		errors += 1
		internal_errors += "BPM value is invalid\n"
	elif float(bpm_lineedit.text) <= 0:
		errors += 1
		internal_errors += "BPM value is negative\n"
		
	
	if start_lineedit.text == "":
		errors += 1
		internal_errors += "Start value is empty\n"
	elif !start_lineedit.text.is_valid_float():
		errors += 1
		internal_errors += "Start value is invalid\n"
	elif float(start_lineedit.text) < 0:
		errors += 1
		internal_errors += "Start value is negative\n"
	else:
		start = float(start_lineedit.text)
		
	
	if end_lineedit.text == "":
		errors += 1
		internal_errors += "End value is empty\n"
	elif !end_lineedit.text.is_valid_float():
		errors += 1
		internal_errors += "End value is invalid\n"
	elif float(end_lineedit.text) < 0:
		errors += 1
		internal_errors += "End value is negative\n"
	else:
		end = float(end_lineedit.text)
	
	if numerator_lineedit.text == "":
		errors += 1
		internal_errors += "Numerator value is empty\n"
	elif !numerator_lineedit.text.is_valid_int():
		errors += 1
		internal_errors += "Numerator value is invalid\n"
	elif float(numerator_lineedit.text) <= 0:
		internal_errors += "Numerator value is negative or zero\n"
		errors += 1
		
	
	if denominator_lineedit.text == "":
		errors += 1
		internal_errors += "Denominator value is empty\n"
	elif !denominator_lineedit.text.is_valid_int():
		errors += 1
		internal_errors += "Denominator value is invalid\n"
	elif float(denominator_lineedit.text) <= 0:
		internal_errors += "Denominator value is empty\n"
		errors += 1
	
	if end <= start:
		errors += 1
		internal_errors += "End value is lower or equal to Start value\n"
		
	
	return errors == 0

func get_errors() -> String:
	return internal_errors

func get_pos_index() -> int:
	return _order_index

func get_interval() -> LevelEditorBpmInterval:
	if !validade_fields():
		return null
	
	var response : LevelEditorBpmInterval = LevelEditorBpmInterval.new()
	
	response.bpm = float(bpm_lineedit.text)
	response.start = float(start_lineedit.text)
	response.end = float(end_lineedit.text)
	response.numerator = int(numerator_lineedit.text)
	response.denominator = int(denominator_lineedit.text)
	
	return response

func set_up_button(is_enabled):
	up_order_button.disabled = !is_enabled

func set_down_button(is_enabled):
	down_order_button.disabled = !is_enabled
	
func set_delete_button(is_enabled):
	delete_button.disabled = !is_enabled
