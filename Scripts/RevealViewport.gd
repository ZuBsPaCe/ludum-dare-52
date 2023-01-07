extends Viewport

onready var _white := $White
var _revealed := false


func reveal():
	if _revealed:
		return
	
	_revealed = true
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_white, "modulate", Color.white, 3.0)
