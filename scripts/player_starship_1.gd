class_name PlayerStarShip1
extends RigidBody2D

signal on_crashed
signal on_collected

# 可调节参数
@export var score_id := 0
@export var enable_wall_crash := true
@export var engine_thrust := 400.0       # 主引擎推力（牛顿）
@export var reverse_thrust := 200.0     # 反向引擎推力
@export var rotation_torque := 600.0    # 旋转扭矩（牛米）
@export var max_speed := 500.0         # 最大速度（像素/秒）
@export var drag_factor := 0.01       # 速度阻尼系数

var thrust_input := 0.0
var rotation_input := 0.0

var is_active = true

@onready var sprite: AnimatedSprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
    if not is_active:
        $JetAudioPlayer.stop_engine()
        return
        
    process_input()
    apply_forces(delta)
    apply_speed_limits()
    jet_audio_play()
    jet_particle_genarate()

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


func jet_audio_play():
    if not is_active:
        $JetAudioPlayer.stop_engine()
    elif thrust_input != 0 or rotation_input != 0:
        $JetAudioPlayer.play_engine()
    else:
        $JetAudioPlayer.stop_engine()

func jet_particle_genarate():
    if not is_active:
        $JetPartical.emitting = false
    elif thrust_input != 0 or rotation_input != 0:
        $JetPartical.emitting = true
    else:
        $JetPartical.emitting = false
        

func _on_body_entered(body: Node) -> void:
    if not is_active:
        return
        
    print("碰撞开始")
    if body is PlayerStarShip1:
        print("飞船碰撞！")
        if score_id == body.score_id:
            disable_rigid()
            AudioManager.play_sound(AudioManager.SoundType.SCORE, global_position)
            emit_signal("on_collected")
            sprite.play("complete")
            await sprite.animation_finished
            queue_free()
        else:
            AudioManager.play_sound(AudioManager.SoundType.COLLISION, global_position)
    elif is_in_collision_layer(body, 3):
        print("碰撞墙体！")
        if enable_wall_crash:
            #disable_rigid()
            AudioManager.play_sound(AudioManager.SoundType.EXPLOSION, global_position)
            emit_signal("on_crashed")
            sprite.play("die")
            await sprite.animation_finished
            queue_free()
        else:
            AudioManager.play_sound(AudioManager.SoundType.COLLISION, global_position)

func disable_rigid():
    is_active = false
    linear_velocity = Vector2(0,0)
    collision_mask = 0
    collision_layer = 0
    #set_contact_monitor(false)
    

# 判断节点是否在指定碰撞层（层号从1开始）
func is_in_collision_layer(node: Node, layer_number: int) -> bool:
    # 验证节点类型
    if not (node is PhysicsBody2D or node is Area2D):
        push_warning("非物理体节点: %s" % node.name)
        return false
    
    # 验证层号有效性
    if layer_number < 1 or layer_number > 32:
        push_error("无效的层号: %d (有效范围1-32)" % layer_number)
        return false
    
    # 位掩码计算（层号转二进制位）
    var bit_mask = 1 << (layer_number - 1)
    return (node.collision_layer & bit_mask) != 0
