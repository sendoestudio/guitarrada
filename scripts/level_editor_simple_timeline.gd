extends Control
class_name LevelEditorTimelineCreationSimple

@onready var length_lineedit : LineEdit = $LengthLineEdit
@onready var bpm_lineedit : LineEdit = $BpmLineEdit
@onready var signature_num_lineedit : LineEdit = $NumLineEdit
@onready var signature_den_lineedit : LineEdit = $DenLineEdit
@onready var offset_lineedit : LineEdit = $OffsetLineEdit

@onready var create_button : Button = $CreateButton
var _timeline_creation_handler : LevelEditorTimelineCreation
var _errors_desc : String

func set_timeline_creation_handler(handler : LevelEditorTimelineCreation) -> void:
	_timeline_creation_handler = handler

func clean_fields() -> void:
	length_lineedit.text = ""
	bpm_lineedit.text = ""
	signature_num_lineedit.text = ""
	signature_den_lineedit.text = ""
	offset_lineedit.text = ""

func validade_fields() -> bool:
	var errors : int = 0
	_errors_desc = ""
	
	var length : float = -1
	var offset : float = -1
	
	if length_lineedit.text == "":
		errors += 1
		_errors_desc += "Length field is empty\n"
	elif !length_lineedit.text.is_valid_float():
		errors += 1
		_errors_desc += "Length field is invalid\n"
	elif float(length_lineedit.text) <= 0:
		errors += 1
		_errors_desc += "Length field is negative\n"
	else:
		length = float(length_lineedit.text)
	
	if bpm_lineedit.text == "":
		errors += 1
		_errors_desc += "BPM field is empty\n"
	elif !bpm_lineedit.text.is_valid_float():
		errors += 1
		_errors_desc += "BPM field is invalid\n"
		
	if signature_num_lineedit.text == "":
		errors += 1
		_errors_desc += "Signature Numerator field is empty\n"
	elif !signature_num_lineedit.text.is_valid_int():
		errors += 1
		_errors_desc += "Signature Numerator field is empty\n"
	elif int(signature_num_lineedit.text) <= 0:
		errors += 1
		_errors_desc += "Signature Numerator field is negative\n"
	if signature_den_lineedit.text == "":
		errors += 1
		_errors_desc += "Signature Denominator field is empty\n"
	elif !signature_den_lineedit.text.is_valid_int():
		errors += 1
		_errors_desc += "Signature Denominator field is empty\n"
	elif int(signature_den_lineedit.text) <= 0:
		errors += 1
		_errors_desc += "Signature Denominator field is negative\n"
		
	
	if offset_lineedit.text != "" && !offset_lineedit.text.is_valid_float():
		errors += 1
		_errors_desc += "Offset field is invalid\n"
	else:
		offset = 0 if (offset_lineedit.text == "") else float(offset_lineedit.text)
	
	if offset >= length:
		errors += 1
		_errors_desc += "Offset is bigger than length\n"
	
	return errors == 0

func _on_create_button_pressed() -> void:
	if !validade_fields():
		_timeline_creation_handler.display_error_list(_errors_desc)
		return
	
	var bpm_interval : LevelEditorBpmInterval = LevelEditorBpmInterval.new()
	bpm_interval.bpm = float(bpm_lineedit.text)
	bpm_interval.start = 0
	if offset_lineedit.text != "":
		bpm_interval.start = float(offset_lineedit.text)
	bpm_interval.end = float(length_lineedit.text)
	
	bpm_interval.numerator = int(signature_num_lineedit.text)
	bpm_interval.denominator = int(signature_den_lineedit.text)
	
	_timeline_creation_handler.set_length(bpm_interval.end)
	_timeline_creation_handler.build_simple_timeline(bpm_interval)


func _on_cancel_button_pressed() -> void:
	if _timeline_creation_handler == null:
		return
		
	_timeline_creation_handler.reset()
