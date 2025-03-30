extends Node2D

signal on_game_failed
signal on_game_success

## 当前关数
@export var level_id := 0
## 目标收集进度
@export var collection_target := 0

## 当前收集数
var collection_current := 0

## 当前用时（秒）
var current_time_s := 0

func _ready():
    $Timer.start(1)
    update_ui_info()
    regist_ship_collect()
    enter_anim()
    
func enter_anim():
    var index = 0
    for rb in $Starships.get_children() + $Planets.get_children():
        var sprites = rb.find_children("*", "Sprite2D") + rb.find_children("*", "AnimatedSprite2D")
        for sprite in sprites:
            animate_sprite_enter(sprite, index)
            index += 1
        
func animate_sprite_enter(sprite: Node2D, index: int):
    var animation_duration := 0.8    # 动画总时长
    var start_delay := 0.2          # 起始延迟
    var per_item_delay := 0.1      # 每个物体间的间隔延迟
    var ease_type := Tween.EASE_OUT  # 缓动类型
    
    var target_scale = sprite.scale;
    sprite.scale = Vector2.ZERO;

    var tween = create_tween().set_parallel(true)  # 并行动画
    var delay = start_delay + index * per_item_delay
    
    # 缩放动画
    tween.tween_property(sprite, "scale", target_scale, animation_duration)\
        .set_trans(Tween.TRANS_BACK)\
        .set_ease(ease_type)\
        .set_delay(delay)
    

func exit_anim():
    var delay = 0;
    var index = 0
    for rb in $Starships.get_children() + $Planets.get_children():
        if not is_instance_valid(rb):
            continue
        var sprites = rb.find_children("*", "Sprite2D") + rb.find_children("*", "AnimatedSprite2D")
        for sprite in sprites:
            delay = animate_sprite_exit(sprite, index)
            index += 1
    await get_tree().create_timer(delay).timeout


func animate_sprite_exit(sprite: Node2D, index: int) -> float:
    var animation_duration := 0.5    # 动画总时长
    var start_delay := 0.2          # 起始延迟
    var per_item_delay := 0.15      # 每个物体间的间隔延迟
    var ease_type := Tween.EASE_OUT  # 缓动类型

    var tween = create_tween().set_parallel(true)  # 并行动画
    var delay = start_delay + index * per_item_delay
    
    # 缩放动画
    tween.tween_property(sprite, "scale", Vector2.ZERO, animation_duration)\
        .set_trans(Tween.TRANS_CUBIC)\
        .set_ease(ease_type)\
        .set_delay(delay)
    return delay + animation_duration


## 注册所有飞船的事件监听
func regist_ship_collect():
    for ship: PlayerStarShip1 in $Starships.get_children():
        ship.on_crashed.connect(on_ship_crashed)
        ship.on_collected.connect(on_ship_collect)

func on_ship_crashed():
    # 游戏失败
    await exit_anim()
    on_game_failed.emit()
    queue_free()

func on_ship_collect():
    collection_current += 1;
    update_ui_info()
    if collection_current >= collection_target:
        # 进入下一关
        on_game_success.emit()
        await exit_anim()
        AudioManager.play_sound(AudioManager.SoundType.LEVEL_CLEAR, get_viewport_rect().size / 2)
        queue_free()

## 更新 ui
func update_ui_info():
    $UI/LabelLevel.text = "第{0}关".format([level_id])
    $UI/LabelCollection.text = "已收集 {0}/{1}".format([collection_current, collection_target])
    $UI/LabelTimer.text = "用时 %s" % format_time(current_time_s)

func format_time(seconds: int) -> String:
    var minutes = (seconds) / 60
    var seconds_remainder = (seconds) % 60
    return "%02d:%02d" % [minutes, seconds_remainder]


func _on_timer_timeout() -> void:
    current_time_s += 1
    update_ui_info()
