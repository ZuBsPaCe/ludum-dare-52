extends Node2D

var cooldowns := []
var areas := []

var active := false
var revealed := false
export var _reveal_viewport_path : NodePath
var reveal_viewport: Viewport

var _check_cooldown := Cooldown.new()

func _ready():
	assert(!_reveal_viewport_path.is_empty())
	reveal_viewport = get_node(_reveal_viewport_path)
	
	for area in get_children():
		var cooldown := Cooldown.new()
		cooldown.setup(self, Globals.AREA_REVEAL_TIME, true)
		area.set_meta("cooldown", cooldown)
		cooldowns.append(cooldown)
		
		areas.append(area)
		area.monitoring = false
		area.monitorable = false
		
	_check_cooldown.setup(self, 1.0, true)
	
	set_process(false)
	

func activate():
	active = true
	_check_cooldown.restart()
	
	for area in areas:
		area.monitoring = true
		area.monitorable = true
	
	set_process(true)
	
	
func _process(delta):
	if _check_cooldown.done:
		_check_cooldown.restart()
		
		var done_count := 0
		for cooldown in cooldowns:
			if !cooldown.done:
				done_count += 1
			
		var done_percent := float(done_count) / float(cooldowns.size()) * 100.0
		print("Done %s: %s" % [name, done_percent])
		
		if done_percent >= 100.0:
			reveal_viewport.reveal()
			revealed = true
			active = false
			
			for area in areas:
				area.monitoring = false
				area.monitorable = false
			
			print("Revealed %s" % name)
			set_process(false)
