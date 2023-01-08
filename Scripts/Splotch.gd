extends Sprite

var _tween : SceneTreeTween

func _ready():
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	_tween.tween_property(self, "modulate", Color.transparent, Globals.REVEAL_TIME)
	_tween.tween_callback(self, "queue_free")
	

func hide():
	if _tween != null:
		_tween.kill()
		_tween = null
		
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "modulate", Color.transparent, 3.0)
	tween.tween_callback(self, "queue_free")
		
		
func hide_fast():
	if _tween != null:
		_tween.kill()
		_tween = null
		
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "modulate", Color.transparent, 1.0)
	tween.tween_callback(self, "queue_free")
	

