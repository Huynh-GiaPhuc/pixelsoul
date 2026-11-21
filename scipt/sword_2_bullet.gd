extends Area2D

@export var speed: float = 700.0      # Tốc độ bay của kiếm
@export var damage: float = 30.0      # Sát thương của kiếm phóng
@export var lifetime: float = 2.0     # Thời gian tối đa tồn tại trước khi tự biến mất

var direction: Vector2 = Vector2.ZERO

func setup(dir: Vector2, rot: float) -> void:
	direction = dir.normalized()
	rotation = rot # Đồng bộ góc xoay lúc phóng

func _ready() -> void:
	# Tự hủy sau khoảng thời gian `lifetime` để tránh tốn tài nguyên
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
	# Kết nối tín hiệu va chạm
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Di chuyển kiếm bay thẳng theo hướng đã định
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	# Nếu va chạm với quái, gây sát thương rồi tự hủy
	if body.has_method("take_damage"):
		body.take_damage(int(damage))
		queue_free()
