# AudioManager.gd (Autoload单例)
extends Node

enum SoundType {
    ENGINE_LOOP,    # 飞船引擎循环声
    EXPLOSION,      # 爆炸
    SCORE,          # 得分
    COLLISION,      # 碰撞
    LEVEL_CLEAR,    # 过关
    GAME_COMPLETE,  # 通关
}

var CONFIG := {
    SoundType.ENGINE_LOOP: {
        "stream": preload("res://assets/audio/tractor one shot.wav"),
        "volume": -20.0,
        "pitch_variation": 0.15,
        "max_instances": 1
    },
    SoundType.EXPLOSION: {
        "stream": preload("res://assets/audio/explosion.wav"),
        "volume": -10.0,
        "pitch_range": [0.9, 1.1],
        "max_instances": 3
    },
    SoundType.SCORE: {
        "stream": preload("res://assets/audio/pick up.wav"),
        "volume": -5.0,
        "pitch_range": [1.0, 1.0],
        "max_instances": 2
    },
    SoundType.COLLISION: {
        "stream": preload("res://assets/audio/pump.wav"),
        "volume": -15.0,
        "pitch_range": [0.5, 1.5],
        "max_instances": 5
    },
    SoundType.LEVEL_CLEAR: {
        "stream": preload("res://assets/audio/chiptune short.wav"),
        "volume": -5.0,
        "pitch_range": [1.0, 1.0],
        "max_instances": 1
    },
    SoundType.GAME_COMPLETE: {
        "stream": preload("res://assets/audio/chiptune full.wav"),
        "volume": -5.0,
        "pitch_range": [1.0, 1.0],
        "max_instances": 1
    },
    
}

var _engine_player: AudioStreamPlayer2D
var _active_players := []

var can_play_sound := false

func _ready():
    # 预创建实例池
    for type in CONFIG.keys():
        for i in CONFIG[type].max_instances:
            var player = _create_player(type)
            add_child(player)
            CONFIG[type].players = [player]

func _process(delta):
    # 引擎声处理
    #_handle_engine(delta)
    can_play_sound = true
    # 清理完成实例
    _cleanup_players()

func play_sound(type: SoundType, position: Vector2 = Vector2.ZERO):
    if not can_play_sound:
        return
    can_play_sound = false
    #if type == SoundType.ENGINE_LOOP:
        #_engine_params.is_active = true
        #return
    
    var pool: Array = CONFIG[type].players
    var players := pool.filter(func(p): return not p.playing)
    var player = null;
    if pool.size() > 0:
        player = pool.front()
    
    if player:
        _setup_player(player, type, position)
        player.play()

func _create_player(type: SoundType) -> AudioStreamPlayer2D:
    var player = AudioStreamPlayer2D.new()
    player.stream = CONFIG[type].stream
    player.volume_db = CONFIG[type].volume
    player.bus = "SFX"
    return player

func _setup_player(player: AudioStreamPlayer2D, type: SoundType, position: Vector2):
    player.global_position = position
    var pitch_range = CONFIG[type].pitch_range
    player.pitch_scale = randf_range(pitch_range[0], pitch_range[1])

func _cleanup_players():
    for player in _active_players:
        if not player.playing:
            _active_players.erase(player)
