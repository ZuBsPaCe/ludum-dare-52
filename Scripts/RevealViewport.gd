extends Viewport

onready var _white := $White
var _revealed := false

var _tween: SceneTreeTween


func reveal():
	if _revealed:
		return
	
	_revealed = true
	
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(_white, "modulate", Color.white, 3.0)


func hide():
#	if !_revealed:
#		return
	
	_revealed = false
	
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(_white, "modulate", Color.transparent, 3.0)
	
	for child in get_children():
		if child.is_in_group("Splotch"):
			child.hide()


func hide_fast():
#	if !_revealed:
#		return
	
	_revealed = false
	
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(_white, "modulate", Color.transparent, 1.0)
	
	for child in get_children():
		if child.is_in_group("Splotch"):
			child.hide_fast()
