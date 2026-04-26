extends Control
class_name  LevelEditorManualTimeline

@onready var length_lineedit : LineEdit = $LengthLineEdit
@onready var beat_list_textedit : TextEdit = $BeatListTextEdit
@onready var strong_beat_list_textedit : TextEdit = $StrongBeatListTextEdit

@onready var create_button : Button = $CreateButton

var _timeline_creation_handler : LevelEditorTimelineCreation
var _errors_desc : String

func set_timeline_creation_handler(handler : LevelEditorTimelineCreation) -> void:
	_timeline_creation_handler = handler
	
func clean_fields():
	beat_list_textedit.text = ""
	strong_beat_list_textedit.text = ""
	
func validate_fields() -> bool:
	var errors = 0
	_errors_desc = ""
	
	if length_lineedit.text == "":
		errors += 1
		_errors_desc += "length field is empty\n"
	elif !length_lineedit.text.is_valid_float() :
		_errors_desc += "length field is invalid\n"
		errors += 1
	elif float(length_lineedit.text) <= 0 :
		_errors_desc += "length is negative or zero\n"
		errors += 1
	
	var beat_list : Array[float] = []
	
	if beat_list_textedit.text == "":
		_errors_desc += "beat list is empty\n"
		errors += 1
	if strong_beat_list_textedit.text == "":
		_errors_desc += "strong beat list is empty\n"
		errors += 1
	
	if errors > 0:
		return false
	
	var beats : Array = beat_list_textedit.text.split(";")
	for value : String in beats:
		if !(value.is_valid_float()):
			errors += 1
			_errors_desc += "value " + value + " in beat list is invalid\n"
			break
		
		beat_list.append(float(value))
			
	var strong_beats : Array = strong_beat_list_textedit.text.split(";")
	for value in strong_beats:
		if !(value.is_valid_float()):
			errors += 1
			_errors_desc += "value " + value + " in strong beat list is invalid\n"
			break
		var converted_value = float(value)
			
		var found_beats = beat_list.filter(func(a) : return a >= (converted_value - 0.001) && a <= (converted_value + 0.001))
		if found_beats == [] || found_beats.size() != 1:
			_errors_desc += "no strong beat contained in beat list\n"
			errors += 1
			break
	
	if errors > 0:
		return false
	
	return errors == 0


func _on_cancel_button_pressed() -> void:
	_timeline_creation_handler.reset()


func _on_create_button_pressed() -> void:
	if !validate_fields():
		_timeline_creation_handler.display_error_list(_errors_desc)
		return
	
	var length : float = float(length_lineedit.text)
	var beats : String = beat_list_textedit.text
	var beats_string_list : Array = beats.split(";")
	var beats_list : Array[float] = []
	for i in beats_string_list:
		beats_list.append(float(i))
		
	var strong_beats : String = strong_beat_list_textedit.text
	var strong_beats_string_list : Array = strong_beats.split(";")
	var strong_beats_list : Array[float] = []
	for j in strong_beats_string_list:
		strong_beats_list.append(float(j))
	
	_timeline_creation_handler.set_length(length)
	_timeline_creation_handler.build_manual_timeline(length, beats_list, strong_beats_list)
