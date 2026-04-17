class_name Map

var title : String
var artist : String
var main_bpm : float
var bpm : float
var length : float
var audio : String
var audio_preview_start : float

var beats : Array[float]
var strong_beats : Array[float]

var charts : Dictionary[String, Chart] = {
	"easy" : null,
	"medium" : null,
	"hard" : null,
	"expert" : null
}
