extends Spatial

export(PackedScene) var _bee_scene
export var _bee_count := 100

export var radius := 3.0
export var radius_scale := 1.0

onready var _target := $Target

var _bees := []
var _bee_velocity := []
var _bee_target_offset := []

const _max_speed := 10.0
const _rot_speed := 2.0 * TAU


func _ready():
	for i in _bee_count:
		var bee: Spatial = _bee_scene.instance()
		
		for group in get_groups():
			bee.add_to_group(group)
		
		bee.translation = Vector3(
			randf() * 4.0 - 2.0,
			randf() * 4.0 - 2.0,
			0.0)

		_bee_velocity.append(Vector2.RIGHT.rotated(randf() * TAU) * (randf() * 2.0 - 1.0))
		_bee_target_offset.append(Vector2.RIGHT.rotated(randf() * TAU) * radius * randf())
			
		add_child(bee)
		
		_bees.append(bee)

		
func _process(delta: float):
	var target_pos := Vector2(_target.translation.x, _target.translation.y)
	
	for i in _bee_count:
		var bee: Spatial = _bees[i]
		var velocity: Vector2 = _bee_velocity[i]
		var target_offset: Vector2 = _bee_target_offset[i]

		var pos := Vector2(bee.translation.x, bee.translation.y)
		var target_vec := target_pos + (target_offset * radius_scale) - pos
		
		if target_vec.length() < 2.0:
			_bee_target_offset[i] = Vector2.RIGHT.rotated(randf() * TAU) * radius * randf()
		
		velocity = velocity.move_toward(target_vec, delta * 4.0)
		velocity = velocity.clamped(_max_speed)
		
		_bee_velocity[i] = velocity
		
		bee.translate(Vector3(velocity.x * delta, velocity.y * delta, 0.0))
	
	
