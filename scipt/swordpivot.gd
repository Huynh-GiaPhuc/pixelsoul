extends Node2D

@export_group("Cấu hình Kiếm")
@export var max_distance: float = 40.0   # Tầm cách xa tối đa so với nhân vật (pixels)
@export var follow_speed: float = 25.0   # Tốc độ xoay mượt theo chuột
@export var distance : float
@export var max_radius : float
@export_range(0.1, 5.0, 0.1) var sensitivity: float 
@export var rotation_speed: float = 50.0
@onready var sword = $sword2

func _ready() -> void:
	max_radius = 100
	sensitivity = 1

func _process(delta: float) -> void:
	# 1. Lấy vị trí con trỏ chuột thực tế trong game world
	var mouse_pos = get_global_mouse_position()
	
	# 2. Tính Vector khoảng cách từ tâm nhân vật (SwordPivot) tới vị trí chuột
	var raw_offset = (mouse_pos - global_position) * sensitivity
	
	# 3. Giới hạn độ dài Vector offset không vượt quá bán kính max_radius
	var clamped_offset = raw_offset.limit_length(max_radius)
	
	# 4. Đặt vị trí của Node Kiếm theo offset cục bộ (Local Position)
	# Việc này giúp vị trí kiếm luôn trùng/bám chính xác theo hướng chuột
	sword.position = clamped_offset
	
	# 5. Xoay kiếm hướng mũi về phía chuột
	if raw_offset.length() > 0.001:
		var target_angle = raw_offset.angle() + deg_to_rad(90)
		sword.rotation = lerp_angle(sword.rotation, target_angle, rotation_speed * delta)
