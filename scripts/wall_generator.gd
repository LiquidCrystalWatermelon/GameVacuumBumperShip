extends Node2D

func _ready():
    _create_boundaries()
    
    
# 在场景中添加名为Boundary的Node2D节点，包含四个边缘碰撞体
# 主场景脚本添加边界创建方法
func _create_boundaries():
    var view_size = get_viewport_rect().size
    var edge_offset = 0.0  # 边界偏移量
    
    # 配置四个边界的方向和位置
    var boundaries = {
        "Top": {
            "normal": Vector2.DOWN,
            "point": Vector2(0, -edge_offset)
        },
        "Bottom": {
            "normal": Vector2.UP,
            "point": Vector2(0, view_size.y + edge_offset)
        },
        "Left": {
            "normal": Vector2.RIGHT,
            "point": Vector2(-edge_offset, 0)
        },
        "Right": {
            "normal": Vector2.LEFT,
            "point": Vector2(view_size.x + edge_offset, 0)
        }
    }
    
    for name in boundaries:
        var static_body := StaticBody2D.new()
        var collision = CollisionShape2D.new()
        var shape = WorldBoundaryShape2D.new()
        
        # 设置边界形状参数
        shape.normal = boundaries[name]["normal"]
        collision.position = boundaries[name]["point"]
        collision.shape = shape
        
        # 配置碰撞层（二进制位掩码）
        static_body.collision_layer = 0b101  # 对应第1层(2^0)和第3层(2^2)
    
        static_body.add_child(collision)
        add_child(static_body)
        
        # 调试显示边界位置
        print("%s 边界已创建，法线方向：%s" % [name, str(shape.normal)])
