extends Node2D

# 新增参数：起点和终点的缩短距离
@export var start_shorten := 15.0  # 起点端缩短距离
@export var end_shorten := 15.0    # 终点端缩短距离

@export var start_node: Node2D    # 起始节点（拖拽到编辑器）
@export var end_node: Node2D      # 目标节点（拖拽到编辑器）
@export var line_color := Color.WHITE  # 线条颜色
@export var line_width := 2.0          # 线条宽度
@export var arrow_size := 10.0         # 箭头大小
@export var dash_length := 8.0         # 虚线实线部分长度
@export var gap_length := 4.0          # 虚线间隔部分长度
@export var jitter_amount := 1.0

var _dash_offset := 0.0  # 用于创建流动效果

func _process(delta):
    _dash_offset += delta * 60  # 流动速度
    queue_redraw()

func _draw():
    if !start_node || !end_node:
        return
                
    # 计算原始起点终点
    var raw_start = start_node.global_position
    var raw_end = end_node.global_position
    var dir = (raw_end - raw_start).normalized()
    var total_length = raw_start.distance_to(raw_end)
    
    # 计算实际使用的缩短距离（防止过度缩短）
    var actual_start_shorten = min(start_shorten, total_length/2)
    var actual_end_shorten = min(end_shorten, total_length/2)
    
    # 计算有效绘制起点终点
    var effective_start = raw_start + dir * actual_start_shorten
    var effective_end = raw_end - dir * actual_end_shorten
    var effective_length = effective_start.distance_to(effective_end)
    
    # 当有效长度不足时不绘制
    if effective_length < arrow_size:
        return
    
    # 绘制主虚线
    _draw_dashed_line(effective_start, effective_end)
    
    # 绘制箭头（使用有效终点）
    _draw_arrow(effective_end, dir)

func _draw_dashed_line(from: Vector2, to: Vector2):
    var direction = to - from
    var line_length = direction.length()
    var dir_normalized = direction.normalized()
    
    var pattern = [dash_length, gap_length]
    var current_pos = 0.0
    var draw_segment = true
    
    while current_pos < line_length:
        var segment_length = pattern[0] if draw_segment else pattern[1]
        var next_pos = min(current_pos + segment_length, line_length)
        
        if draw_segment:
            var start = from + dir_normalized * current_pos
            var end = from + dir_normalized * next_pos
            # 添加流动偏移效果
            start += dir_normalized.rotated(PI/2) * sin(_dash_offset + current_pos) * jitter_amount
            end += dir_normalized.rotated(PI/2) * sin(_dash_offset + next_pos) * jitter_amount
            
            draw_line(start, end, line_color, line_width)
            
        draw_segment = !draw_segment
        current_pos = next_pos

func _draw_arrow(pos: Vector2, direction: Vector2):
    var arrow_angle = PI/6  # 箭头角度
    var base_dir = direction.normalized() * arrow_size
    
    # 计算箭头两侧方向
    var left_dir = base_dir.rotated(arrow_angle)
    var right_dir = base_dir.rotated(-arrow_angle)
    
    # 绘制箭头线
    draw_line(pos, pos - left_dir, line_color, line_width)
    draw_line(pos, pos - right_dir, line_color, line_width)
    
    # 可选：填充箭头三角形
    var points = PackedVector2Array([pos, pos - left_dir, pos - right_dir])
    draw_colored_polygon(points, line_color)
