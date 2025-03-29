class_name PlayerStarShip1
extends RigidBody2D

# 可调节参数
@export var engine_thrust := 400.0       # 主引擎推力（牛顿）
@export var reverse_thrust := 200.0     # 反向引擎推力
@export var rotation_torque := 600.0    # 旋转扭矩（牛米）
@export var max_speed := 500.0         # 最大速度（像素/秒）
@export var drag_factor := 0.01       # 速度阻尼系数

var thrust_input := 0.0
var rotation_input := 0.0

func _physics_process(delta: float) -> void:
    process_input()
    apply_forces(delta)
    apply_speed_limits()

func process_input():
    # 获取输入值（支持模拟输入）
    thrust_input = Input.get_axis("brake", "thrust")
    rotation_input = Input.get_axis("rotate_left", "rotate_right")

func apply_forces(delta):
    # 推进力应用（基于飞船朝向）
    if thrust_input != 0:
        var thrust_direction = Vector2.UP.rotated(rotation)
        var thrust_strength = engine_thrust if thrust_input > 0 else -reverse_thrust
        var effective_thrust = thrust_direction * thrust_strength * abs(thrust_input)
        apply_central_force(effective_thrust)
    
    # 扭矩应用（平滑旋转控制）
    if rotation_input != 0:
        var torque = rotation_torque * rotation_input
        apply_torque(torque)
    
    # 自动速度阻尼（模拟太空微量阻力）
    linear_velocity *= (1.0 - drag_factor)
    angular_velocity *= (1.0 - drag_factor)

func apply_speed_limits():
    # 速度限制（防止无限加速）
    if linear_velocity.length() > max_speed:
        linear_velocity = linear_velocity.normalized() * max_speed

# 可选：添加粒子效果控制
#func _process(delta):
    ## 控制引擎粒子效果
    #$ExhaustParticles.emitting = thrust_input > 0
    #$ReverseParticles.emitting = thrust_input < 0
    #$LeftThruster.emitting = rotation_input > 0
    #$RightThruster.emitting = rotation_input < 0


func _on_body_entered(body: Node) -> void:
    print("碰撞开始")
    if body is PlayerStarShip1:
        print("飞船碰撞！")
        queue_free()
