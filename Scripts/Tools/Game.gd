extends Node2D


const GameState := preload("res://Scripts/Tools/Examples/ExampleGameState.gd").GameState

enum FlowerLevelState {
	RESET,
	FLOWER_HILLS,
	FLOWER_TREE,
	FLOWER_STREAM
}



export(GameState) var _initial_game_state := GameState.MAIN_MENU

export(PackedScene) var _splotch1_scene


onready var _game_state := $GameStateMachine
onready var _flower_level_state := $FlowerLevelStateMachine
onready var _reveal_viewport1 := $RevealViewport1
onready var _reveal_viewport2 := $RevealViewport2


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
		
	_flower_level_state.setup(
		FlowerLevelState.RESET,
		funcref(self, "_on_FlowerLevel_enter_state"),
		funcref(self, "_on_FlowerLevel_process_state"),
		funcref(self, "_on_FlowerLevel_exit_state"))
		
	_flower_level_state.set_process(false)
	
	
	_splotch_countdown.setup(self, 0.05, true)
	
	for area_group in $RevealAreas.get_children():
		_area_groups[area_group.name] = area_group
		

	for node in $Flowers/BackgroundContainer/Viewport/World.get_children():
		var reveal1: bool = node.is_in_group("Reveal1")
		var reveal2: bool = node.is_in_group("Reveal2")
		
		var hide1: bool = node.is_in_group("Hide1")
		var hide2: bool = node.is_in_group("Hide2")
		
		var set_reveal_shader := reveal1 || reveal2 || hide1 || hide2
		
		if set_reveal_shader:
			var mat = ShaderMaterial.new()
			mat.shader = load("res://Materials/RevealShader.tres")
			mat.set_shader_param("tex", node.texture)
			mat.set_shader_param("modulate", node.modulate)
			
			if reveal1 || hide1:
				mat.set_shader_param("reveal_tex", _reveal_viewport1.get_texture())
			elif reveal2 || hide2:
				mat.set_shader_param("reveal_tex", _reveal_viewport2.get_texture())
			
			if hide1 || hide2:
				mat.set_shader_param("hide", 1.0)
				
			node.material_override = mat
		
#		if node.is_in_group("Reveal1"):
#			var mat = ShaderMaterial.new()
#			mat.shader = load("res://Materials/RevealShader.tres")
#			mat.set_shader_param("tex", node.texture)
#			mat.set_shader_param("modulate", node.modulate)
#			mat.set_shader_param("reveal_tex", _reveal_viewport1.get_texture())
#			node.material_override = mat
#
#		if node.is_in_group("Hide1"):
#			var mat = ShaderMaterial.new()
#			mat.shader = load("res://Materials/RevealShader.tres")
#			mat.set_shader_param("tex", node.texture)
#			mat.set_shader_param("modulate", node.modulate)
#			mat.set_shader_param("reveal_tex", _reveal_viewport1.get_texture())
#			mat.set_shader_param("hide", 1.0)
#			node.material_override = mat



func _process(delta):
	if _game_state.current != GameState.GAME:
		return
	
#	$Dummy.position += $Dummy.position.direction_to(Globals.get_global_mouse_position()) * 100.0 * delta
#	$Dummy.rotation = -PI * 0.5 + $Dummy.position.angle_to_point(Globals.get_global_mouse_position())
	
	$RevealCursor.position = Globals.get_global_mouse_position()
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && _splotch_countdown.done:
		_splotch_countdown.restart()
		var splotch: Node2D = _splotch1_scene.instance()
		splotch.position = Globals.get_global_mouse_position()
		splotch.rotation = randf() * TAU
		
		for area_group in _area_groups.values():
			if area_group.active:
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
			Effects.shake(Vector2.RIGHT)

		GameState.GAME:
			State.on_game_start()
			$GameOverlay.visible = true
			Effects.shake(Vector2.RIGHT)
			
			_flower_level_state.set_state_immediate(FlowerLevelState.FLOWER_HILLS)
			_flower_level_state.set_process(true)

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
			
			
func _on_FlowerLevel_enter_state():
	match _flower_level_state.current:
		FlowerLevelState.RESET:
			_flower_level_state.set_state(FlowerLevelState.FLOWER_HILLS)
		
		FlowerLevelState.FLOWER_HILLS:
			_area_groups[Globals.AREAS_FLOWER_HILLS].activate()

		FlowerLevelState.FLOWER_TREE:
			_area_groups[Globals.AREAS_FLOWER_TREE].activate()
		
		FlowerLevelState.FLOWER_STREAM:
			pass

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
			pass

		_:
			assert(false, "Unknown game state")

func _on_FlowerLevel_exit_state():
	pass

