extends Node

const AMBIENT_THEME: AudioStream = preload("res://assets/audio/ambient_theme.wav")
const SFX_UI_CLICK: AudioStream = preload("res://assets/audio/sfx_ui_click.wav")
const SFX_NOTEBOOK_TOGGLE: AudioStream = preload("res://assets/audio/sfx_notebook_toggle.wav")
const SFX_MEMORY_CHIME: AudioStream = preload("res://assets/audio/sfx_memory_chime.wav")
const SFX_STATION_BELL: AudioStream = preload("res://assets/audio/sfx_station_bell.wav")

const SFX_POOL_SIZE: int = 4

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_setup_music_player()
	_setup_sfx_pool()
	_connect_world_state_signals()


func _setup_music_player() -> void:
	var wav_stream: AudioStreamWAV = AMBIENT_THEME as AudioStreamWAV
	if wav_stream != null:
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	music_player = AudioStreamPlayer.new()
	music_player.bus = &"Music"
	music_player.stream = AMBIENT_THEME
	music_player.volume_db = -24.0
	music_player.finished.connect(music_player.play)
	add_child(music_player)
	music_player.play()

	var tween: Tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, 2.0)


func _setup_sfx_pool() -> void:
	for i: int in range(SFX_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		sfx_players.append(player)


func _connect_world_state_signals() -> void:
	WorldState.notebook_state_changed.connect(_on_notebook_state_changed)
	WorldState.wax_fragment_collected.connect(_on_wax_fragment_collected)
	WorldState.clue_registered.connect(_on_clue_registered)
	WorldState.memory_reconstructed.connect(_on_memory_reconstructed)


func _play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	for player: AudioStreamPlayer in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = pitch_scale
			player.play()
			return

	if not sfx_players.is_empty():
		var fallback: AudioStreamPlayer = sfx_players[0]
		fallback.stream = stream
		fallback.volume_db = volume_db
		fallback.pitch_scale = pitch_scale
		fallback.play()


func play_ui_click() -> void:
	_play_sfx(SFX_UI_CLICK, -2.0)


func play_notebook_toggle() -> void:
	_play_sfx(SFX_NOTEBOOK_TOGGLE, 0.0)


func play_memory_chime() -> void:
	_play_sfx(SFX_MEMORY_CHIME, 0.0)


func play_station_bell() -> void:
	_play_sfx(SFX_STATION_BELL, 1.0)


func _on_notebook_state_changed(_is_active: bool) -> void:
	play_notebook_toggle()


func _on_wax_fragment_collected(_total: int) -> void:
	play_memory_chime()


func _on_clue_registered(_clue_id: String, _total_clues: int) -> void:
	play_memory_chime()


func _on_memory_reconstructed(_memory_id: String) -> void:
	play_memory_chime()
