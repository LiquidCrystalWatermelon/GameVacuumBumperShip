# 主场景脚本（MainScene.gd）
extends Node2D

@export var spawn_count = 20
@export var spawn_radius = 50.0
@export var initial_force = 500.0

func _ready():
    _create_boundaries()
    
    var safe_zone = get_viewport_rect().grow(-50)  # 生成时留出边界安全距离
    
    for i in spawn_count:
        var body = preload("res://scenes/physics_body.tscn").instantiate()
        # 在安全区域内随机生成位置
        body.position = Vector2(
            randf_range(safe_zone.position.x, safe_zone.end.x),
            randf_range(safe_zone.position.y, safe_zone.end.y)
        )
        # 后续冲量代码保持不变...
        body.position = position + $SpawnCenter.position
        body.apply_central_impulse(Vector2(randf_range(-1, 1), randf_range(-1, 1)) * initial_force)
        add_child(body)

# 在场景中添加名为Boundary的Node2D节点，包含四个边缘碰撞体
# 主场景脚本添加边界创建方法
func _create_boundaries():
    var view_size = get_viewport_rect().size
    var edge_thickness = 20.0  # 边界厚度
    
    # 创建四个边界条
    var edges = {
        "Top":    Rect2(0, -edge_thickness, view_size.x, edge_thickness),
        "Bottom": Rect2(0, view_size.y, view_size.x, edge_thickness),
        "Left":   Rect2(-edge_thickness, 0, edge_thickness, view_size.y),
        "Right":  Rect2(view_size.x, 0, edge_thickness, view_size.y)
    }
    
    for name in edges:
        var static_body = StaticBody2D.new()
        var collision = CollisionShape2D.new()
        var shape = RectangleShape2D.new()
        
        shape.extents = edges[name].size / 2
        collision.position = edges[name].position + edges[name].size / 2
        collision.shape = shape
        
        static_body.add_child(collision)
        add_child(static_body)
