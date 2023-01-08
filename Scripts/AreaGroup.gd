extends Node2D

var cooldowns := []
var areas := []

var active := false
var revealed := false
var can_reveal := false


export var _reveal_viewport_path : NodePath
export var _auto_reveal := true
export var _no_viewport := false


var reveal_viewport: Viewport

var _check_cooldown := Cooldown.new()

func _ready():
	assert(_no_viewport || !_reveal_viewport_path.is_empty())
	
	if !_no_viewport:
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
	print("Activated %s" % name)
	
	active = true
	
	if areas.size() > 0:
		_check_cooldown.restart()
		
		for area in areas:
			area.monitoring = true
			area.monitorable = true
		
		set_process(true)
		
		
func deactivate():
	print("Deactivated %s" % name)
	
	active = false
	revealed = false
	can_reveal = false
	
	if areas.size() > 0:
		_check_cooldown.restart()
		
		for area in areas:
			area.monitoring = false
			area.monitorable = false
	
	for cooldown in cooldowns:
		cooldown.set_done()
		
	set_process(false)
	
	
func hide():
	print("Hide %s" % name)
	
	active = false
	revealed = false
	can_reveal = false
	
	for area in areas:
		area.monitoring = false
		area.monitorable = false
		
	reveal_viewport.hide()
	
	set_process(false)
	
	
func reveal():
	assert(!revealed)
	_finish()
	
func _process(_delta):
	assert(active)
	
	if _check_cooldown.done:
		_check_cooldown.restart()
		
		var done_count := 0
		for cooldown in cooldowns:
			if !cooldown.done:
				done_count += 1
		
		var done_percent := float(done_count) / float(cooldowns.size()) * 100.0
		#print("Done %s: %s" % [name, done_percent])
		
		if done_percent >= 100.0:
			if _auto_reveal:
				_finish()
			else:
				can_reveal = true
		else:
			can_reveal = false

func _finish():
	revealed = true
	can_reveal = false
	
	if !_no_viewport:
		reveal_viewport.reveal()
			
	for area in areas:
		area.monitoring = false
		area.monitorable = false
	
	print("Revealed %s" % name)
	set_process(false)
