extends Node2D


@onready var levels := [
    preload("res://scenes/levels/level_010.tscn"),
    preload("res://scenes/test/test_level_1.tscn"),
]

var current_level_index = 0

func _ready() -> void:
    load_level(current_level_index, levels)
    

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
    
    # 连接关卡监听
    level_node_impl.on_game_failed.connect(_on_level_failed)
    level_node_impl.on_game_success.connect(_on_level_success)
    
    add_child(level_node)
    
    
func _on_level_failed():
    load_level(current_level_index, levels)


func _on_level_success():
    current_level_index += 1
    load_level(current_level_index, levels)
    
    
    
    
    
