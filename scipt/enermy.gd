extends CharacterBody2D

@export var max_health: int = 1000
var current_health: int

func _ready() -> void:
	current_health = max_health
	print("Dummy đã xuất hiện! Máu tối đa: ", max_health)


# Hàm này bắt buộc phải trùng tên với hàm gọi từ kiếm: target.take_damage(final_damage)
func take_damage(amount: int) -> void:
	current_health -= amount
	print("💥 Quái nhận: ", amount, " sát thương! | Máu còn lại: ", current_health)
	
	# Hiệu ứng đổi màu đỏ chớp nhoáng khi trúng đòn (Tùy chọn cho sinh động)
	modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func die() -> void:
	print("💀 Quái đã bị tiêu diệt!")
	queue_free() # Xóa quái khỏi game khi hết máu
