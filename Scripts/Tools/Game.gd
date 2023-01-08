extends Node2D


const GameState := preload("res://Scripts/Tools/Examples/ExampleGameState.gd").GameState

enum FarmLevelState {
	RESET,
	FARM,
	FARM_FIELD,
	FARM_CLOUDS,
	FARM_CORN,
	FARM_SUN,
	FARM_TRACTOR,
	FARM_DONE
}



enum FlowerLevelState {
	RESET,
	FLOWER_HILLS,
	FLOWER_TREE,
	FLOWER_STREAM,
	FLOWER_BEEHIVE_SUN_FIELD,
	FLOWER_DONE
}


export(GameState) var _initial_game_state := GameState.MAIN_MENU

export(PackedScene) var _splotch1_scene


onready var _game_state := $GameStateMachine
onready var _farm_level_state := $FarmLevelStateMachine
onready var _flower_level_state := $FlowerLevelStateMachine
onready var _reveal_viewport1 := $RevealViewport1
onready var _reveal_viewport2 := $RevealViewport2
onready var _reveal_viewport3 := $RevealViewport3
onready var _reveal_viewport4 := $RevealViewport4
onready var _reveal_viewport5 := $RevealViewport5
onready var _reveal_viewport6 := $RevealViewport6
onready var _reveal_viewport7 := $RevealViewport7

onready var _farm_level_rain_particles := $Levels/BackgroundContainer/Viewport/World/Farm/FarmRain
onready var _farm_level_done_player := $Levels/BackgroundContainer/Viewport/World/Farm/FarmLevelDonePlayer
onready var _flower_level_done_player := $Levels/BackgroundContainer/Viewport/World/Flower/FlowerLevelDonePlayer


var _splotch_countdown := Cooldown.new()

var _area_groups := {}

func _ready():
	Globals.setup()
	State.setup()
	Effects.setup($Camera2D)
	
	set_fullscreen(Globals.get_setting(Globals.SETTING_FULLSCREEN))
	
	$MainMenu.setup(
		Globals.get_setting(Globals.SETTING_MUSIC_VOLUME),
		Globals.get_setting(Globals.SETTING_SOUND_VOLUME))
	
	$MainMenu.visible = false
	$GameOverlay.visible = false
	
	$MainMenu.connect("switch_game_state", self, "switch_game_state")
	$MainMenu.connect("change_volume", self, "change_volume")
	$GameOverlay.connect("switch_game_state", self, "switch_game_state")
	
	get_tree().connect("screen_resized", self, "on_screen_resized")
	
	_game_state.setup(
		_initial_game_state,
		funcref(self, "_on_GameStateMachine_enter_state"),
		FuncRef.new(),
		funcref(self, "_on_GameStateMachine_exit_state"))
		
	_farm_level_state.setup(
		FarmLevelState.RESET,
		funcref(self, "_on_FarmLevel_enter_state"),
		funcref(self, "_on_FarmLevel_process_state"),
		funcref(self, "_on_FarmLevel_exit_state"))
		
	_flower_level_state.setup(
		FlowerLevelState.RESET,
		funcref(self, "_on_FlowerLevel_enter_state"),
		funcref(self, "_on_FlowerLevel_process_state"),
		funcref(self, "_on_FlowerLevel_exit_state"))
		
	_farm_level_state.set_process(false)
	_flower_level_state.set_process(false)
	
	
	_splotch_countdown.setup(self, 0.05, true)
	
	for area_group in $RevealAreas.get_children():
		_area_groups[area_group.name] = area_group
		

	for node in Tools.get_children_recursive($Levels/BackgroundContainer/Viewport/World):
		if not node is Sprite3D:
			continue
			
		var reveal1: bool = node.is_in_group("Reveal1")
		var reveal2: bool = node.is_in_group("Reveal2")
		var reveal3: bool = node.is_in_group("Reveal3")
		var reveal4: bool = node.is_in_group("Reveal4")
		var reveal5: bool = node.is_in_group("Reveal5")
		var reveal6: bool = node.is_in_group("Reveal6")
		var reveal7: bool = node.is_in_group("Reveal7")
		
		var hide1: bool = node.is_in_group("Hide1")
		var hide2: bool = node.is_in_group("Hide2")
		var hide3: bool = node.is_in_group("Hide3")
		var hide4: bool = node.is_in_group("Hide4")
		var hide5: bool = node.is_in_group("Hide5")
		var hide6: bool = node.is_in_group("Hide6")
		var hide7: bool = node.is_in_group("Hide7")
		
		var reveal := false
		var hide := false
		var reveal_viewport
		
		if reveal1 || reveal2 || reveal3 || reveal4 || reveal5 || reveal6 || reveal7:
			reveal = true
		if hide1 || hide2 || hide3 || hide4 || hide5 || hide6 || hide7:
			hide = true
		if reveal1 || hide1:
			reveal_viewport = _reveal_viewport1
		if reveal2 || hide2:
			reveal_viewport = _reveal_viewport2
		if reveal3 || hide3:
			reveal_viewport = _reveal_viewport3
		if reveal4 || hide4:
			reveal_viewport = _reveal_viewport4
		if reveal5 || hide5:
			reveal_viewport = _reveal_viewport5
		if reveal6 || hide6:
			reveal_viewport = _reveal_viewport6
		if reveal7 || hide7:
			reveal_viewport = _reveal_viewport7
		
		if reveal or hide:
			var mat = ShaderMaterial.new()
			mat.shader = load("res://Materials/RevealShader.tres")
			mat.set_shader_param("tex", node.texture)
			mat.set_shader_param("modulate", node.modulate)
			
			mat.set_shader_param("reveal_tex", reveal_viewport.get_texture())
			
			if hide:
				mat.set_shader_param("hide", 1.0)
				
			node.material_override = mat
			
			if node.has_method("setup"):
				node.setup()


func _process(delta):
	if _game_state.current != GameState.GAME:
		return
		
	#	$Dummy.position += $Dummy.position.direction_to(Globals.get_global_mouse_position()) * 100.0 * delta
	#	$Dummy.rotation = -PI * 0.5 + $Dummy.position.angle_to_point(Globals.get_global_mouse_position())
	
	$RevealCursor.position = Globals.get_global_mouse_position()
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && _splotch_countdown.done:
		_splotch_countdown.restart()
		
		var pos := Globals.get_global_mouse_position()
		var rot := randf() * TAU
		
		for area_group in _area_groups.values():
			if area_group.active:
				var splotch: Node2D = _splotch1_scene.instance()
				splotch.position = pos
				splotch.rotation = rot
				area_group.reveal_viewport.add_child(splotch)
		
		for area in $RevealCursor/RevealCursorArea.get_overlapping_areas():
			var cooldown = area.get_meta("cooldown")
			cooldown.restart()


func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo and event.alt and event.scancode == KEY_ENTER:
			set_fullscreen(!OS.window_fullscreen)


func on_screen_resized():
	if !OS.window_fullscreen:
		Globals.set_setting(Globals.SETTING_WINDOW_WIDTH, OS.window_size.x)
		Globals.set_setting(Globals.SETTING_WINDOW_HEIGHT, OS.window_size.y)
		Globals.save_settings()
		

func switch_game_state(new_state):
	_game_state.set_state(new_state)


func set_fullscreen(enabled: bool):		
	if OS.window_fullscreen == enabled:
		return
	
	OS.window_fullscreen = enabled
	
	if !OS.window_fullscreen:
		OS.window_size = Vector2(
			Globals.get_setting(Globals.SETTING_WINDOW_WIDTH),
			Globals.get_setting(Globals.SETTING_WINDOW_HEIGHT))
	
	Globals.set_setting(Globals.SETTING_FULLSCREEN, OS.window_fullscreen)
	Globals.save_settings()


func change_volume(music_factor: float, sound_factor: float):
	AudioServer.set_bus_volume_db(1, linear2db(music_factor))
	AudioServer.set_bus_volume_db(2, linear2db(sound_factor))
	
	Globals.set_setting(Globals.SETTING_MUSIC_VOLUME, music_factor)
	Globals.set_setting(Globals.SETTING_SOUND_VOLUME, sound_factor)
	Globals.save_settings()


func _on_GameStateMachine_enter_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			$MainMenu.visible = true
			#Effects.shake(Vector2.RIGHT)

		GameState.GAME:
			State.on_game_start()
			$GameOverlay.visible = true
			#Effects.shake(Vector2.RIGHT)
			
			_farm_level_state.set_state_immediate(FarmLevelState.FARM)
			_farm_level_state.set_process(true)
			
			#_farm_level_state.set_state(FarmLevelState.FARM_TRACTOR)
			
#			_flower_level_state.set_state_immediate(FlowerLevelState.FLOWER_HILLS)
#			_flower_level_state.set_process(true)

		_:
			assert(false, "Unknown game state")


func _on_GameStateMachine_exit_state():
	match _game_state.current:
		GameState.MAIN_MENU:
			$MainMenu.visible = false

		GameState.GAME:
			State.on_game_stopped()
			$GameOverlay.visible = false

		_:
			assert(false, "Unknown game state")

func _on_FarmLevel_enter_state():
	match _farm_level_state.current:
		FarmLevelState.RESET:
			_farm_level_state.set_state(FarmLevelState.FARM)
		
		FarmLevelState.FARM:
			_area_groups[Globals.AREAS_FARM].activate()

		FarmLevelState.FARM_FIELD:
			_area_groups[Globals.AREAS_FARM_FIELD].activate()
			
		FarmLevelState.FARM_CLOUDS:
			_area_groups[Globals.AREAS_FARM_CLOUDS].activate()
			
		FarmLevelState.FARM_CORN:
			_farm_level_rain_particles.emitting = true
			_area_groups[Globals.AREAS_FARM_CORN].activate()
			
		FarmLevelState.FARM_SUN:
			_area_groups[Globals.AREAS_FARM_SUN].activate()
			
		FarmLevelState.FARM_TRACTOR:
			_area_groups[Globals.AREAS_FARM_TRACTOR].activate()
			
		FarmLevelState.FARM_DONE:
			pass

		_:
			assert(false, "Unknown game state")


func _on_FarmLevel_process_state():	
	match _farm_level_state.current:			
		FarmLevelState.FARM:
			if _area_groups[Globals.AREAS_FARM].revealed:
				_farm_level_state.set_state(FarmLevelState.FARM_FIELD)

		FarmLevelState.FARM_FIELD:
			if _area_groups[Globals.AREAS_FARM_FIELD].revealed:
				_farm_level_state.set_state(FarmLevelState.FARM_CLOUDS)
				
		FarmLevelState.FARM_CLOUDS:
			if _area_groups[Globals.AREAS_FARM_CLOUDS].revealed:
				_farm_level_state.set_state(FarmLevelState.FARM_CORN)
				_farm_level_state.wait(4.0)
				
		FarmLevelState.FARM_CORN:
			if _area_groups[Globals.AREAS_FARM_CORN].revealed:
				_farm_level_state.set_state(FarmLevelState.FARM_SUN)
				
		FarmLevelState.FARM_SUN:
			if _area_groups[Globals.AREAS_FARM_SUN].revealed:
				_area_groups[Globals.AREAS_FARM_CLOUDS].hide()
				_farm_level_rain_particles.emitting = false
				_farm_level_state.set_state(FarmLevelState.FARM_TRACTOR)
				
		FarmLevelState.FARM_TRACTOR:
			if _area_groups[Globals.AREAS_FARM_TRACTOR].revealed:
				_farm_level_state.set_state(FarmLevelState.FARM_DONE)
				
		FarmLevelState.FARM_DONE:
			_farm_level_done_player.play("LevelDone")

		_:
			assert(false, "Unknown game state")

func _on_FarmLevel_exit_state():
	pass



			
func _on_FlowerLevel_enter_state():
	match _flower_level_state.current:
		FlowerLevelState.RESET:
			_flower_level_state.set_state(FlowerLevelState.FLOWER_HILLS)
		
		FlowerLevelState.FLOWER_HILLS:
			_area_groups[Globals.AREAS_FLOWER_HILLS].activate()

		FlowerLevelState.FLOWER_TREE:
			_area_groups[Globals.AREAS_FLOWER_TREE].activate()
		
		FlowerLevelState.FLOWER_STREAM:
			_area_groups[Globals.AREAS_FLOWER_STREAM].activate()
		
		FlowerLevelState.FLOWER_BEEHIVE_SUN_FIELD:
			_area_groups[Globals.AREAS_FLOWER_BEEHIVE].activate()
			_area_groups[Globals.AREAS_FLOWER_SUN].activate()
			_area_groups[Globals.AREAS_FLOWER_FIELD].activate()
		
		FlowerLevelState.FLOWER_DONE:
			_flower_level_done_player.play("LevelDone")

		_:
			assert(false, "Unknown game state")


func _on_FlowerLevel_process_state():	
	match _flower_level_state.current:			
		FlowerLevelState.FLOWER_HILLS:
			if _area_groups[Globals.AREAS_FLOWER_HILLS].revealed:
				_flower_level_state.set_state(FlowerLevelState.FLOWER_TREE)

		FlowerLevelState.FLOWER_TREE:
			if _area_groups[Globals.AREAS_FLOWER_TREE].revealed:
				_flower_level_state.set_state(FlowerLevelState.FLOWER_STREAM)
		
		FlowerLevelState.FLOWER_STREAM:
			if _area_groups[Globals.AREAS_FLOWER_STREAM].revealed:
				_flower_level_state.set_state(FlowerLevelState.FLOWER_BEEHIVE_SUN_FIELD)
			
		FlowerLevelState.FLOWER_BEEHIVE_SUN_FIELD:
			if (!_area_groups[Globals.AREAS_FLOWER_BEES].active and
				_area_groups[Globals.AREAS_FLOWER_SUN].revealed):
				_area_groups[Globals.AREAS_FLOWER_BEES].activate()
			
			if (_area_groups[Globals.AREAS_FLOWER_FIELD].can_reveal and 
				_area_groups[Globals.AREAS_FLOWER_BEES].can_reveal):
				_area_groups[Globals.AREAS_FLOWER_FIELD].reveal()
				_area_groups[Globals.AREAS_FLOWER_BEES].reveal()
				_flower_level_state.set_state(FlowerLevelState.FLOWER_DONE)
		
		FlowerLevelState.FLOWER_DONE:
			pass

		_:
			assert(false, "Unknown game state")

func _on_FlowerLevel_exit_state():
	pass

