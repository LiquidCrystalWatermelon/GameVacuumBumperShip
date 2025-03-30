# AudioManager.gd (Autoload单例)
extends Node

enum SoundType {
    ENGINE_LOOP,    # 飞船引擎循环声
    EXPLOSION,      # 爆炸
    SCORE,          # 得分
    COLLISION       # 碰撞
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
    }
}

var _engine_player: AudioStreamPlayer2D
var _active_players := []
#var _engine_params := {
    #"base_pitch": 1.0,
    #"current_pitch": 1.0,
    #"fade_speed": 5.0,
    #"is_active": false
#}

func _ready():
    # 初始化引擎播放器
    #_engine_player = _create_player(SoundType.ENGINE_LOOP)
    #add_child(_engine_player)
    
    # 预创建实例池
    for type in [SoundType.EXPLOSION, SoundType.SCORE, SoundType.COLLISION]:
        for i in CONFIG[type].max_instances:
            var player = _create_player(type)
            add_child(player)
            CONFIG[type].players = [player]

func _process(delta):
    # 引擎声处理
    #_handle_engine(delta)
    
    # 清理完成实例
    _cleanup_players()

func play_sound(type: SoundType, position: Vector2 = Vector2.ZERO):
    #if type == SoundType.ENGINE_LOOP:
        #_engine_params.is_active = true
        #return
    
    var pool = CONFIG[type].players
    var player = pool.filter(func(p): return not p.playing).front()
    
    if player:
        _setup_player(player, type, position)
        player.play()

#func start_engine():
    #_engine_params.is_active = true
    #if not _engine_player.playing:
        #_engine_player.play()
#
#func stop_engine():
    #_engine_params.is_active = false

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

#func _handle_engine(delta: float):
    #if _engine_params.is_active:
        ## 启动/继续引擎声
        #if not _engine_player.playing:
            #_engine_player.play()
        #
        ## 动态变调
        #_engine_params.current_pitch = clamp(
            #_engine_params.current_pitch * randf_range(0.98, 1.02),
            #_engine_params.base_pitch * (1 - CONFIG[SoundType.ENGINE_LOOP].pitch_variation),
            #_engine_params.base_pitch * (1 + CONFIG[SoundType.ENGINE_LOOP].pitch_variation)
        #)
        #_engine_player.pitch_scale = _engine_params.current_pitch
        #
        ## 淡入
        ##_engine_player.volume_db = lerp(
            ##_engine_player.volume_db,
            ##CONFIG[SoundType.ENGINE_LOOP].volume,
            ##_engine_params.fade_speed * delta
        ##)
        #_engine_player.volume_db = CONFIG[SoundType.ENGINE_LOOP].volume
    #else:
        ## 淡出
        #_engine_player.volume_db = lerp(
            #_engine_player.volume_db,
            #-80.0,
            #_engine_params.fade_speed * delta
        #)
        #if _engine_player.volume_db < -60:
            #_engine_player.stop()

func _cleanup_players():
    for player in _active_players:
        if not player.playing:
            _active_players.erase(player)
