extends Node2D


@onready var levels := [
    preload("res://scenes/levels/level_010.tscn"),
    preload("res://scenes/levels/level_020.tscn"),
    preload("res://scenes/levels/level_030.tscn"),
    preload("res://scenes/levels/level_040.tscn"),
    preload("res://scenes/levels/level_050.tscn"),
    preload("res://scenes/levels/level_060.tscn"),
    preload("res://scenes/levels/level_070.tscn"),
    preload("res://scenes/levels/level_080.tscn"),
    preload("res://scenes/levels/level_090.tscn"),
    preload("res://scenes/levels/level_100.tscn"),
    preload("res://scenes/levels/level_910.tscn"),
]

var current_level_index = 0

func _ready() -> void:
    await load_welcome()
    load_level(current_level_index, levels)
    
func load_welcome():
    var welcome_res = preload("res://scenes/welcome.tscn")
    var welcome = welcome_res.instantiate()
    add_child(welcome)
    await get_tree().create_timer(2).timeout
    welcome.queue_free()

func load_level(level_index: int, level_list: Array):
    if level_list == null or level_list.is_empty():
        return
    if level_index >= level_list.size():
        return
    
    # 载入关卡节点
    var level_res: Resource = level_list[level_index];
    var level_node:Node = level_res.instantiate()
    
    # 配置关卡属性
    var level_node_impl :BaseLevel = level_node.get_child(0)
    level_node_impl.level_id = level_index + 1
    
    if level_node_impl.level_id == 10:
        level_node_impl.need_play_full_song = true
    
    # 连接关卡监听
    level_node_impl.on_game_failed.connect(_on_level_failed)
    level_node_impl.on_game_success.connect(_on_level_success)
    
    add_child(level_node)
    
    
func _on_level_failed():
    load_level(current_level_index, levels)


func _on_level_success():
    current_level_index += 1
    load_level(current_level_index, levels)
    
    
    
    
    
