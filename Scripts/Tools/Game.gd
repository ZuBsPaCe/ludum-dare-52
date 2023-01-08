extends Node2D


const GameState := preload("res://Scripts/GameState.gd").GameState

enum Level {
	FARM = 1,
	FLOWER,
	APPLE,
	TIMBER
}

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

enum AppleLevelState {
	RESET,
	APPLE_SMALL_TREE,
	APPLE_MEDIUM_TREE,
	APPLE_LARGE_TREE,
	APPLE_FRUITS,
	APPLE_PATH,
	APPLE_NEWTON_WALK1,
	APPLE_NEWTON_WALK2,
	APPLE_NEWTON_WALK3,
	APPLE_NEWTON_WALK4,
	APPLE_NEWTON_SIT,
	APPLE_NEWTON_HEUREKA,
	APPLE_DONE
}

enum TimberLevelState {
	RESET,
	TIMBER_SNOW,
	TIMBER_BRIDGE,
	TIMBER_WOODCUT,
	TIMBER_FIRE,
	TIMBER_DONE
}


export(GameState) var _initial_game_state := GameState.MAIN_MENU

export(PackedScene) var _splotch1_scene


onready var _game_state := $GameStateMachine
onready var _farm_level_state := $FarmLevelStateMachine
onready var _flower_level_state := $FlowerLevelStateMachine
onready var _apple_level_state := $AppleLevelStateMachine
onready var _timber_level_state := $TimberLevelStateMachine
onready var _reveal_viewport1 := $RevealViewport1
onready var _reveal_viewport2 := $RevealViewport2
onready var _reveal_viewport3 := $RevealViewport3
onready var _reveal_viewport4 := $RevealViewport4
onready var _reveal_viewport5 := $RevealViewport5
onready var _reveal_viewport6 := $RevealViewport6
onready var _reveal_viewport7 := $RevealViewport7
onready var _reveal_viewport8 := $RevealViewport8
onready var _reveal_viewport9 := $RevealViewport9
onready var _reveal_viewport10 := $RevealViewport10

onready var _farm_level_rain_particles := $Levels/BackgroundContainer/Viewport/World/Farm/FarmRain
onready var _farm_level_done_player := $Levels/BackgroundContainer/Viewport/World/Farm/FarmLevelDonePlayer
onready var _flower_level_done_player := $Levels/BackgroundContainer/Viewport/World/Flower/FlowerLevelDonePlayer
onready var _apple_level_done_player := $Levels/BackgroundContainer/Viewport/World/Apple/AppleLevelDonePlayer
onready var _timber_level_woodcut_player := $Levels/BackgroundContainer/Viewport/World/Timber/TimberLevelWoodcutPlayer
onready var _timber_level_done_player := $Levels/BackgroundContainer/Viewport/World/Timber/TimberLevelDonePlayer

onready var _farm_intro_player := $Levels/BackgroundContainer/Viewport/World/Farm/FarmIntroPlayer
onready var _flower_intro_player := $Levels/BackgroundContainer/Viewport/World/Flower/FlowerIntroPlayer
onready var _apple_intro_player := $Levels/BackgroundContainer/Viewport/World/Apple/AppleIntroPlayer
onready var _timber_intro_player := $Levels/BackgroundContainer/Viewport/World/Timber/TimberIntroPlayer


onready var _flower_node := $Levels/BackgroundContainer/Viewport/World/Flower
onready var _farm_node := $Levels/BackgroundContainer/Viewport/World/Farm
onready var _apple_node := $Levels/BackgroundContainer/Viewport/World/Apple
onready var _timber_node := $Levels/BackgroundContainer/Viewport/World/Timber


var _splotch_countdown := Cooldown.new()

var _area_groups := {}
var _world_nodes := {}
var _reveal_viewports := []

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
		FuncRef.new())
		
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
		
	_apple_level_state.setup(
		AppleLevelState.RESET,
		funcref(self, "_on_AppleLevel_enter_state"),
		funcref(self, "_on_AppleLevel_process_state"),
		funcref(self, "_on_AppleLevel_exit_state"))
		
	_timber_level_state.setup(
		AppleLevelState.RESET,
		funcref(self, "_on_TimberLevel_enter_state"),
		funcref(self, "_on_TimberLevel_process_state"),
		funcref(self, "_on_TimberLevel_exit_state"))
		
	_farm_level_state.set_process(false)
	_flower_level_state.set_process(false)
	_apple_level_state.set_process(false)
	_timber_level_state.set_process(false)
	
	
	_splotch_countdown.setup(self, 0.05, true)
	
	for area_group in $RevealAreas.get_children():
		_area_groups[area_group.name] = area_group
		
		
	_reveal_viewports.append(_reveal_viewport1)
	_reveal_viewports.append(_reveal_viewport2)
	_reveal_viewports.append(_reveal_viewport3)
	_reveal_viewports.append(_reveal_viewport4)
	_reveal_viewports.append(_reveal_viewport5)
	_reveal_viewports.append(_reveal_viewport6)
	_reveal_viewports.append(_reveal_viewport7)
	_reveal_viewports.append(_reveal_viewport8)
	_reveal_viewports.append(_reveal_viewport9)
	_reveal_viewports.append(_reveal_viewport10)
	

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
		var reveal8: bool = node.is_in_group("Reveal8")
		var reveal9: bool = node.is_in_group("Reveal9")
		var reveal10: bool = node.is_in_group("Reveal10")
		
		var hide1: bool = node.is_in_group("Hide1")
		var hide2: bool = node.is_in_group("Hide2")
		var hide3: bool = node.is_in_group("Hide3")
		var hide4: bool = node.is_in_group("Hide4")
		var hide5: bool = node.is_in_group("Hide5")
		var hide6: bool = node.is_in_group("Hide6")
		var hide7: bool = node.is_in_group("Hide7")
		var hide8: bool = node.is_in_group("Hide8")
		var hide9: bool = node.is_in_group("Hide9")
		var hide10: bool = node.is_in_group("Hide10")
		
		var reveal := false
		var hide := false
		var reveal_viewport
		
		if reveal1 || reveal2 || reveal3 || reveal4 || reveal5 || reveal6 || reveal7 || reveal8 || reveal9 || reveal10:
			reveal = true
		if hide1 || hide2 || hide3 || hide4 || hide5 || hide6 || hide7 || hide8 || hide9 || hide10:
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
		if reveal8 || hide8:
			reveal_viewport = _reveal_viewport8
		if reveal9 || hide9:
			reveal_viewport = _reveal_viewport9
		if reveal10 || hide10:
			reveal_viewport = _reveal_viewport10
		
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
				
			_world_nodes[node.name] = node
			
	_farm_node.visible = true
	_flower_node.visible = false
	_apple_node.visible = false
	_timber_node.visible = false



func _process(_delta):
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
			if area_group.active && area_group.reveal_viewport != null:
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
			_stop_level()
			
			_farm_node.visible = true
			
			get_tree().paused = true
			
			$MainMenu.visible = true
			$GameOverlay.visible = false
			
			$MainMenu.get_node("%StartButton").visible = true
			$MainMenu.get_node("%RestartButton").visible = false
			$MainMenu.get_node("%ContinueButton").visible = false
			#Effects.shake(Vector2.RIGHT)
			
		GameState.START:
			$MainMenu.visible = false
			
			_start_level(Level.FLOWER)
			
			switch_game_state(GameState.GAME)

		GameState.GAME:
			$GameOverlay.visible = true
			
			get_tree().paused = false
			#Effects.shake(Vector2.RIGHT)
			
			
		GameState.PAUSE:
			get_tree().paused = true
			
			$GameOverlay.visible = false
			$MainMenu.visible = true
			$MainMenu.get_node("%StartButton").visible = false
			$MainMenu.get_node("%RestartButton").visible = true
			$MainMenu.get_node("%ContinueButton").visible = true

			
		GameState.CONTINUE:
			$MainMenu.visible = false
			$GameOverlay.visible = true
			
			switch_game_state(GameState.GAME)

		_:
			assert(false, "Unknown game state")


func _stop_level():
	for area_group in _area_groups.values():
		area_group.deactivate()
	
	for reveal_viewport in _reveal_viewports:
		reveal_viewport.hide_fast()

	for node in Tools.get_children_recursive($Levels/BackgroundContainer/Viewport/World):
		if not node is Sprite3D:
			continue
			
		if node.has_method("setup"):
			node.setup()	
	
	_farm_node.visible = false
	_flower_node.visible = false
	_apple_node.visible = false
	_timber_node.visible = false
	
	_farm_level_state.set_process(false)
	_flower_level_state.set_process(false)
	_apple_level_state.set_process(false)
	_timber_level_state.set_process(false)
	
	_farm_level_done_player.stop()
	_flower_level_done_player.stop()
	_apple_level_done_player.stop()
	_timber_level_done_player.stop()
	_timber_level_woodcut_player.stop()
	
	_farm_intro_player.stop()
	_flower_intro_player.stop()
	_apple_intro_player.stop()
	_timber_intro_player.stop()
	

func _start_level(level):
	_stop_level()
	
	match level:
		Level.FARM:
			_farm_intro_player.play("Intro")
			yield(get_tree().create_timer(0.2), "timeout")
			
			_farm_node.visible = true
			_farm_level_state.set_state_immediate(FarmLevelState.RESET)
			_farm_level_state.set_process(true)
			
			
		
		Level.FLOWER:
			_flower_intro_player.play("Intro")
			yield(get_tree().create_timer(0.2), "timeout")
			
			_flower_node.visible = true
			_flower_level_state.set_state_immediate(FlowerLevelState.RESET)
			_flower_level_state.set_process(true)
			

			
		Level.APPLE:
			_apple_intro_player.play("Intro")
			yield(get_tree().create_timer(0.2), "timeout")
			
			_apple_node.visible = true
			_apple_level_state.set_state_immediate(AppleLevelState.RESET)
			_apple_level_state.set_process(true)
			

			
		Level.TIMBER:
			_timber_intro_player.play("Intro")
			yield(get_tree().create_timer(0.2), "timeout")
			
			_timber_node.visible = true
			_timber_level_state.set_state_immediate(TimberLevelState.RESET)
			_timber_level_state.set_process(true)
			
			
		_:
			pass
			

func _on_FarmLevel_enter_state():
	match _farm_level_state.current:
		FarmLevelState.RESET:
			_farm_level_rain_particles.emitting = false
			_farm_level_state.set_state_immediate(FarmLevelState.FARM)
		
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
			_farm_level_done_player.play("LevelDone")

		_:
			assert(false, "Unknown game state")


func _on_FarmLevel_process_state():	
	match _farm_level_state.current:
		FarmLevelState.RESET:
			pass
			
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
			if _farm_level_done_player.current_animation.empty():
				_start_level(Level.FLOWER)

		_:
			assert(false, "Unknown game state")

func _on_FarmLevel_exit_state():
	pass



			
func _on_FlowerLevel_enter_state():
	match _flower_level_state.current:
		FlowerLevelState.RESET:
			_flower_level_state.set_state_immediate(FlowerLevelState.FLOWER_HILLS)
		
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
		FlowerLevelState.RESET:
			pass
				
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
			if _flower_level_done_player.current_animation.empty():
				_start_level(Level.APPLE)

		_:
			assert(false, "Unknown game state")

func _on_FlowerLevel_exit_state():
	pass



func _on_AppleLevel_enter_state():
	match _apple_level_state.current:
		AppleLevelState.RESET:
			_apple_level_state.set_state_immediate(AppleLevelState.APPLE_SMALL_TREE)
		
		AppleLevelState.APPLE_SMALL_TREE:
			_area_groups[Globals.AREAS_APPLE_SMALL_TREE].activate()

		AppleLevelState.APPLE_MEDIUM_TREE:
			_world_nodes["AppleTreeSmall"].material_override.set_shader_param("reveal_tex", _reveal_viewport2.get_texture())
			_world_nodes["AppleTreeSmall"].material_override.set_shader_param("hide", 1.0)
			
			_world_nodes["AppleLeavesSmall"].material_override.set_shader_param("reveal_tex", _reveal_viewport2.get_texture())
			_world_nodes["AppleLeavesSmall"].material_override.set_shader_param("hide", 1.0)
			
			_area_groups[Globals.AREAS_APPLE_MEDIUM_TREE].activate()
		
		AppleLevelState.APPLE_LARGE_TREE:
			_world_nodes["AppleTreeMedium"].material_override.set_shader_param("reveal_tex", _reveal_viewport3.get_texture())
			_world_nodes["AppleTreeMedium"].material_override.set_shader_param("hide", 1.0)
			
			_world_nodes["AppleLeavesMedium"].material_override.set_shader_param("reveal_tex", _reveal_viewport3.get_texture())
			_world_nodes["AppleLeavesMedium"].material_override.set_shader_param("hide", 1.0)
			
			_area_groups[Globals.AREAS_APPLE_LARGE_TREE].activate()
		
		AppleLevelState.APPLE_FRUITS:
			_area_groups[Globals.AREAS_APPLE_FRUITS].activate()
		
		AppleLevelState.APPLE_PATH:
			_area_groups[Globals.AREAS_APPLE_PATH].activate()
			_area_groups[Globals.AREAS_APPLE_NEWTON_WALK1].activate()
		
		AppleLevelState.APPLE_NEWTON_SIT:
			_area_groups[Globals.AREAS_APPLE_NEWTON_SIT].activate()
			
		AppleLevelState.APPLE_NEWTON_HEUREKA:
			_area_groups[Globals.AREAS_APPLE_NEWTON_HEUREKA].activate()
		
		AppleLevelState.APPLE_DONE:
			_apple_level_done_player.play("LevelDone")

		_:
			assert(false, "Unknown game state")


func _on_AppleLevel_process_state():	
	match _apple_level_state.current:
		AppleLevelState.RESET:
			pass
						
		AppleLevelState.APPLE_SMALL_TREE:
			if _area_groups[Globals.AREAS_APPLE_SMALL_TREE].revealed:
				_apple_level_state.set_state(AppleLevelState.APPLE_MEDIUM_TREE)
				_apple_level_state.wait(3.0)

		AppleLevelState.APPLE_MEDIUM_TREE:
			if _area_groups[Globals.AREAS_APPLE_MEDIUM_TREE].revealed:
				_apple_level_state.set_state(AppleLevelState.APPLE_LARGE_TREE)
				_apple_level_state.wait(3.0)
		
		AppleLevelState.APPLE_LARGE_TREE:
			if _area_groups[Globals.AREAS_APPLE_LARGE_TREE].revealed:
				_apple_level_state.set_state(AppleLevelState.APPLE_FRUITS)
				_apple_level_state.wait(3.0)
				
		AppleLevelState.APPLE_FRUITS:
			if _area_groups[Globals.AREAS_APPLE_FRUITS].revealed:
				_apple_level_state.set_state(AppleLevelState.APPLE_PATH)
		
		AppleLevelState.APPLE_PATH:
			if _area_groups[Globals.AREAS_APPLE_NEWTON_WALK1].can_reveal:
				if !_area_groups[Globals.AREAS_APPLE_NEWTON_WALK2].active:
					_area_groups[Globals.AREAS_APPLE_NEWTON_WALK2].activate()
			else:
				if _area_groups[Globals.AREAS_APPLE_NEWTON_WALK2].active:
					_area_groups[Globals.AREAS_APPLE_NEWTON_WALK2].deactivate()
			
			if _area_groups[Globals.AREAS_APPLE_NEWTON_WALK2].can_reveal:
				if !_area_groups[Globals.AREAS_APPLE_NEWTON_WALK3].active:
					_area_groups[Globals.AREAS_APPLE_NEWTON_WALK3].activate()
			else:
				if _area_groups[Globals.AREAS_APPLE_NEWTON_WALK3].active:
					_area_groups[Globals.AREAS_APPLE_NEWTON_WALK3].deactivate()
			
			if _area_groups[Globals.AREAS_APPLE_NEWTON_WALK3].can_reveal:
				if !_area_groups[Globals.AREAS_APPLE_NEWTON_WALK4].active:
					_area_groups[Globals.AREAS_APPLE_NEWTON_WALK4].activate()
			else:
				if _area_groups[Globals.AREAS_APPLE_NEWTON_WALK4].active:
					_area_groups[Globals.AREAS_APPLE_NEWTON_WALK4].deactivate()
			
			if _area_groups[Globals.AREAS_APPLE_NEWTON_WALK4].can_reveal:
				_apple_level_state.set_state(AppleLevelState.APPLE_NEWTON_SIT)
				
		AppleLevelState.APPLE_NEWTON_SIT:
			if _area_groups[Globals.AREAS_APPLE_NEWTON_SIT].revealed:
				_apple_level_state.set_state(AppleLevelState.APPLE_NEWTON_HEUREKA)
				
		AppleLevelState.APPLE_NEWTON_HEUREKA:
			if _area_groups[Globals.AREAS_APPLE_NEWTON_HEUREKA].revealed:
				_apple_level_state.set_state(AppleLevelState.APPLE_DONE)
		
		AppleLevelState.APPLE_DONE:
			if _apple_level_done_player.current_animation.empty():
				_start_level(Level.TIMBER)

		_:
			assert(false, "Unknown game state")

func _on_AppleLevel_exit_state():
	pass



func _on_TimberLevel_enter_state():
	match _timber_level_state.current:
		TimberLevelState.RESET:
			_timber_level_state.set_state_immediate(TimberLevelState.TIMBER_SNOW)
		
		TimberLevelState.TIMBER_SNOW:
			_area_groups[Globals.AREAS_TIMBER_SNOW_GROUND_LEFT].activate()
			_area_groups[Globals.AREAS_TIMBER_SNOW_GROUND_RIGHT].activate()
			_area_groups[Globals.AREAS_TIMBER_SNOW1_LEFT].activate()
			_area_groups[Globals.AREAS_TIMBER_SNOW1_RIGHT].activate()
			_area_groups[Globals.AREAS_TIMBER_SNOW2_LEFT].activate()
			_area_groups[Globals.AREAS_TIMBER_SNOW2_RIGHT].activate()
			_area_groups[Globals.AREAS_TIMBER_SNOW3].activate()
		
		TimberLevelState.TIMBER_BRIDGE:
			_area_groups[Globals.AREAS_TIMBER_RIVER].reveal()
			_area_groups[Globals.AREAS_TIMBER_BRIDGE].activate()
			
		TimberLevelState.TIMBER_WOODCUT:
			_area_groups[Globals.AREAS_TIMBER_WOODCUT].activate()
			
		TimberLevelState.TIMBER_FIRE:
			_area_groups[Globals.AREAS_TIMBER_FIRE].activate()

		TimberLevelState.TIMBER_DONE:
			_timber_level_done_player.play("LevelDone")

		_:
			assert(false, "Unknown game state")


func _on_TimberLevel_process_state():	
	match _timber_level_state.current:
		TimberLevelState.RESET:
			pass
				
		TimberLevelState.TIMBER_SNOW:
			if (_area_groups[Globals.AREAS_TIMBER_SNOW_GROUND_LEFT].revealed &&
				_area_groups[Globals.AREAS_TIMBER_SNOW_GROUND_RIGHT].revealed &&
				_area_groups[Globals.AREAS_TIMBER_SNOW1_LEFT].revealed &&
				_area_groups[Globals.AREAS_TIMBER_SNOW1_RIGHT].revealed &&
				_area_groups[Globals.AREAS_TIMBER_SNOW2_LEFT].revealed &&
				_area_groups[Globals.AREAS_TIMBER_SNOW2_RIGHT].revealed &&
				_area_groups[Globals.AREAS_TIMBER_SNOW3].revealed):
				_timber_level_state.set_state(TimberLevelState.TIMBER_BRIDGE)
				
		TimberLevelState.TIMBER_BRIDGE:
			if _area_groups[Globals.AREAS_TIMBER_BRIDGE].revealed:
				_timber_level_state.set_state(TimberLevelState.TIMBER_WOODCUT)
				
		TimberLevelState.TIMBER_WOODCUT:
			if _area_groups[Globals.AREAS_TIMBER_WOODCUT].revealed:
				_timber_level_woodcut_player.play("Woodcut")
				_timber_level_state.set_state(TimberLevelState.TIMBER_FIRE)
				_timber_level_state.wait(10.0)
				
		TimberLevelState.TIMBER_FIRE:
			if _area_groups[Globals.AREAS_TIMBER_FIRE].revealed:
				_timber_level_state.set_state(TimberLevelState.TIMBER_DONE)
		
		TimberLevelState.TIMBER_DONE:
			if _timber_level_done_player.current_animation.empty():
				switch_game_state(GameState.MAIN_MENU)

		_:
			assert(false, "Unknown game state")

func _on_TimberLevel_exit_state():
	pass
