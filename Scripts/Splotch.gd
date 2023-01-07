extends Sprite


func _ready():
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "modulate", Color.transparent, Globals.REVEAL_TIME)



