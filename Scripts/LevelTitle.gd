extends CanvasLayer


var done := false

var _tween: SceneTreeTween


func _ready():
	$White.visible = false
	$Level1.visible = false
	$Level2.visible = false
	$Level3.visible = false
	$Level4.visible = false	


func start_level(level: int):
	done = false
	
	if _tween != null:
		_tween.kill()
	
	$White.visible = true
	$White.modulate = Color.transparent
	
	$Level1.visible = false
	$Level1.modulate = Color.transparent
	
	$Level2.visible = false
	$Level2.modulate = Color.transparent
	
	$Level3.visible = false
	$Level3.modulate = Color.transparent
	
	$Level4.visible = false	
	$Level4.modulate = Color.transparent
	
	var node
	match level:
		1:
			$Level1.visible = true
			node = $Level1
		2:
			$Level2.visible = true
			node = $Level2
		3:
			$Level3.visible = true
			node = $Level3
		4:
			$Level4.visible = true
			node = $Level4
		5:
			assert(false)
	
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	_tween.tween_property($White, "modulate", Color.white, 0.5)
	_tween.tween_interval(1)
	_tween.tween_property(node, "modulate", Color.white, 2.0)
	_tween.tween_interval(2)
	_tween.tween_property($White, "modulate", Color.transparent, 2.0)
	_tween.tween_interval(2)
	_tween.tween_property(node, "modulate", Color.transparent, 2.0)

	_tween.tween_callback(self, "_set_done")

func _set_done():
	done = true
