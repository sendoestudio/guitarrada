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

func set_complex_handler(handler : LevelEditorComplexTimeline):
	_complex_handler = handler
#reorder
#create another
#delete this
#get data
#validade data
