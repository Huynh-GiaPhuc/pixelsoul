extends Area2D

@export_group("Cấu hình Sát thương Kiếm")
@export var base_damage: float = 20.0          # Sát thương cơ bản
@export var min_swing_distance: float = 30.0   # Quãng đường tối thiểu (pixels)
@export var min_speed_threshold: float = 200.0 # Vận tốc tối thiểu (pixels/s)
@export var hit_cooldown: float = 0.4          # Thời gian hồi sát thương cho cùng một kẻ địch

var last_position: Vector2 = Vector2.ZERO
var accumulated_distance: float = 0.0
var current_speed: float = 0.0
var enemy_cooldowns: Dictionary = {}

func _ready() -> void:
	last_position = global_position

func _process(delta: float) -> void:
	if delta <= 0:
		return
		
	# 1. Tính quãng đường và vận tốc trong frame hiện tại
	var frame_distance = global_position.distance_to(last_position)
	accumulated_distance += frame_distance
	current_speed = frame_distance / delta
	last_position = global_position
	
	# 2. Giảm thời gian Cooldown của các kẻ địch
	for enemy in enemy_cooldowns.keys():
		enemy_cooldowns[enemy] -= delta
		if enemy_cooldowns[enemy] <= 0:
			enemy_cooldowns.erase(enemy)

	# 3. Quét kiểm tra va chạm liên tục với các mục tiêu xung quanh
	var overlapping_targets = get_overlapping_bodies() + get_overlapping_areas()
	for target in overlapping_targets:
		_try_deal_damage(target)

func _try_deal_damage(target: Node) -> void:
	if not target.has_method("take_damage") or target in enemy_cooldowns:
		return
		
	# Kiểm tra xem có thỏa mãn điều kiện khoảng cách hoặc vận tốc không
	var satisfied_distance = accumulated_distance >= min_swing_distance
	var satisfied_speed = current_speed >= min_speed_threshold
	
	if satisfied_distance or satisfied_speed:
		var damage_multiplier = 0.1 # Mặc định thỏa mãn 1 trong 2
		
		# THỎA MÃN CẢ HAI: Vừa vung đường dài, vừa vẩy nhanh -> Nhận hệ số 1.5x
		if satisfied_distance and satisfied_speed:
			damage_multiplier = 3.0
			print("CRITICAL SWING! Hệ số: 1.5x")
		else:
			print("Normal Swing. Hệ số: 1.0x")
			
		# Tính sát thương cuối cùng và gọi hàm nhận sát thương của quái
		var final_damage = int(base_damage * damage_multiplier)
		target.take_damage(final_damage)
		
		# Đưa kẻ địch vào trạng thái hồi chiêu và reset quãng đường tích lũy
		enemy_cooldowns[target] = hit_cooldown
		accumulated_distance = 0.0
