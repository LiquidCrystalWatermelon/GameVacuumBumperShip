# AudioEngine2D.gd
class_name JetAudioPlayer
extends AudioStreamPlayer2D

@export var base_volume := -20.0
@export var pitch_variation := 0.15
@export var fade_speed := 5.0

var _is_playing := false
var _base_pitch := 1.0

func _ready():
    #stream.loop = false
    volume_db = base_volume
    finished.connect(_on_finished)
    
    # 配置空间音频参数
    max_distance = 2000.0
    attenuation = 1.0  # 对数衰减曲线

func play_engine():
    await get_tree().create_timer(randf()).timeout
    if !_is_playing:
        _is_playing = true
        _base_pitch = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
        pitch_scale = _base_pitch
        play()

func stop_engine():
    _is_playing = false

func _process(delta):
    # 自动淡出处理
    if !_is_playing && playing:
        volume_db = lerp(volume_db, -80.0, fade_speed * delta)
        if volume_db < -60:
            stop()
    elif _is_playing:
        volume_db = base_volume
        #volume_db = lerp(volume_db, base_volume, fade_speed * delta)

func _on_finished():
    if _is_playing:
        pitch_scale = clamp(
            _base_pitch * randf_range(0.95, 1.05), 
            1.0 - pitch_variation, 
            1.0 + pitch_variation
        )
        play()
