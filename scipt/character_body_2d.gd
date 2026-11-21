extends CharacterBody2D

@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D
@onready var dash_timer: Timer =$Timer
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var dash_speed: float = 600.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	pass
	

func _physics_process(delta: float) -> void:
	# 1. Lấy hướng di chuyển bằng hàm tối ưu của Godot
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var move_velocity = input_dir * SPEED
	# 2. Thay vì dùng `position += ...`, dùng `move_and_collide` để chặn va chạm
	# 3. Lật Sprite dựa theo hướng di chuyển
	if input_dir.x > 0:
		sprite.flip_h = true
	elif input_dir.x < 0:
		sprite.flip_h = false
	if Input.is_action_just_pressed("dash") and not is_dashing and input_dir != Vector2.ZERO:
		start_dash(input_dir)
	if is_dashing:
	# Lock velocity in the dash direction
		move_velocity = dash_direction * dash_speed
	elif dash_timer.timeout :
		pass
	if move_velocity != Vector2.ZERO:
		move_and_collide(move_velocity * delta)

func start_dash(dir: Vector2) -> void:
	is_dashing = true
	dash_direction = dir.normalized()
	dash_timer.start()

func _on_dash_timer_timeout() -> void:
	is_dashing = false
