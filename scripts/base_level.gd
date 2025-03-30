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

## 注册所有飞船的事件监听
func regist_ship_collect():
    for ship: PlayerStarShip1 in $Starships.get_children():
        ship.on_crashed.connect(on_ship_crashed)
        ship.on_collected.connect(on_ship_collect)

func on_ship_crashed():
    # 游戏失败
    on_game_failed.emit()
    pass

func on_ship_collect():
    collection_current += 1;
    update_ui_info()
    if collection_current >= collection_target:
        # 进入下一关
        on_game_success.emit()
        pass

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
