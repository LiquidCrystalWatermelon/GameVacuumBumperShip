# PhysicsBody.tscn 脚本（附加到RigidBody2D节点）
extends RigidBody2D

func _ready():
    # 确保连续碰撞检测
    continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
    # 防止物体穿透边界
    contact_monitor = true
    max_contacts_reported = 1
    
    # 设置物理材质
    var mat = PhysicsMaterial.new()
    mat.bounce = 1.0  # 完全弹性碰撞
    mat.rough = 0.0   # 无摩擦
    
    # 随机形状（圆形或矩形）
    if randi() % 2 == 0:
        var shape = CircleShape2D.new()
        shape.radius = randf_range(5, 15)
        $CollisionShape2D.shape = shape
    else:
        var shape = RectangleShape2D.new()
        shape.size = Vector2(randf_range(10, 20), randf_range(10, 20))
        $CollisionShape2D.shape = shape
    
    physics_material_override = mat
