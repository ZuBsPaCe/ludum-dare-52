extends Sprite3D


export var initially_hidden := false

var _alpha: float = 1.0 setget _update_alpha

var _modulate: Color
var _tween: SceneTreeTween


func _ready():
	_modulate = modulate
	

		

func setup():
	if initially_hidden:
		_update_alpha(0.0)
		
	
func hide():
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "_alpha", 0.0, 1.0)
	
func reveal():
	if _tween != null:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "_alpha", 1.0, 1.0)
	
func _update_alpha(a):
	_modulate.a = a
	material_override.set_shader_param("modulate", _modulate)

