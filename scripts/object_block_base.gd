extends RigidBody2D



func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
    var state := PhysicsServer2D.body_get_direct_state(get_rid())
    var contact_count := state.get_contact_count()
    
    if contact_count > 0:
        # 获取第一个接触点坐标
        var contact_point: Vector2 = to_global(state.get_contact_local_position(0))
        print("碰撞坐标：", contact_point)
        
        AudioManager.play_sound(AudioManager.SoundType.COLLISION, contact_point)
