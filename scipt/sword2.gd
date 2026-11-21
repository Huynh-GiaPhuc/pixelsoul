extends Area2D

@export_group("Cấu hình Sát thương Kiếm")
@export var base_damage: float = 20.0          
@export var min_swing_distance: float = 30.0   
@export var min_speed_threshold: float = 200.0 
@export var hit_cooldown: float = 0.4          

@export_group("Hiệu ứng Kiếm Phóng (Crit & Store)")
@export var projectile_scene: PackedScene      

var last_position: Vector2 = Vector2.ZERO
var accumulated_distance: float = 0.0
var current_speed: float = 0.0
var enemy_cooldowns: Dictionary = {}

# Biến trạng thái lưu trữ đạn kiếm
var has_stored_projectile: bool = false        

func _ready() -> void:
	last_position = global_position

func _process(delta: float) -> void:
	if delta <= 0:
		return
		
	# 1. Tính quãng đường và vận tốc trong frame
	var frame_distance = global_position.distance_to(last_position)
	accumulated_distance += frame_distance
	current_speed = frame_distance / delta
	last_position = global_position
	
	# 2. Giảm thời gian Cooldown quái
	for enemy in enemy_cooldowns.keys():
		enemy_cooldowns[enemy] -= delta
		if enemy_cooldowns[enemy] <= 0:
			enemy_cooldowns.erase(enemy)

	# 3. KIỂM TRA ĐIỀU KIỆN CRIT ĐỂ LƯU TRỮ ĐẠN (Thay vì phóng ngay lập tức)
	var satisfied_distance = accumulated_distance >= min_swing_distance
	var satisfied_speed = current_speed >= min_speed_threshold
	
	if satisfied_distance and satisfied_speed and not has_stored_projectile:
		has_stored_projectile = true
		accumulated_distance = 0.0
		print("🔥 Đã chém Crit thành công! Đã LƯU TRỮ 1 viên đạn kiếm. Nhấn Chuột Trái để phóng!")

	# 4. Quét va chạm gây sát thương chuẩn/crit lên quái
	var overlapping_targets = get_overlapping_bodies() + get_overlapping_areas()
	for target in overlapping_targets:
		_try_deal_damage(target, satisfied_distance and satisfied_speed)

# Bắt sự kiện nhấn phím/chuột độc lập với _process
func _unhandled_input(event: InputEvent) -> void:
	# Kiểm tra nếu người chơi nhấn Chuột Trái (MOUSE_BUTTON_LEFT)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if has_stored_projectile:
			_release_stored_projectile()
			has_stored_projectile = false # Xóa trạng thái đã lưu sau khi phóng

func _try_deal_damage(target: Node, is_crit: bool) -> void:
	if not target.has_method("take_damage") or target in enemy_cooldowns:
		return
		
	var satisfied_distance = accumulated_distance >= min_swing_distance
	var satisfied_speed = current_speed >= min_speed_threshold
	
	if satisfied_distance or satisfied_speed:
		var damage_multiplier = 1.5 if is_crit else 1.0
		var final_damage = int(base_damage * damage_multiplier)
		
		target.take_damage(final_damage)
		enemy_cooldowns[target] = hit_cooldown
		accumulated_distance = 0.0

# Hàm thực hiện phóng viên đạn kiếm đã được lưu trữ ra ngoài
func _release_stored_projectile() -> void:
	if not projectile_scene:
		print("Chưa gán PackedScene cho projectile_scene trong Inspector!")
		return
		
	var proj = projectile_scene.instantiate()
	proj.global_position = global_position
	
	# Hướng phóng bay theo hướng mũi kiếm hiện tại
	var shoot_dir = Vector2.UP.rotated(global_rotation)
	proj.setup(shoot_dir, global_rotation)
	
	get_tree().current_scene.add_child(proj)
	print("🚀 Đã phóng đạn kiếm đã lưu đi!")
