# player.gd
extends Area2D

signal hit
signal bean_launched(pos: Vector2, dir: Vector2)

@export var speed = 400
@export var bean_cooldown = 0.1
var can_fire = true

var screen_size

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var bean_launcher = $BeanLauncher
@onready var bean_spawn_point = $BeanLauncher/Sprite2D/BeanSpawnPoint
@onready var shooting_cooldown = $FireTimer

func start(pos):
	position = pos
	show()
	collision.disabled = false
	can_fire = true

func _ready() -> void:
	can_fire = false
	hide()
	screen_size = get_viewport_rect().size
	shooting_cooldown.timeout.connect(_on_fire_timer_timeout)
	
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	var move_right_strength = Input.get_action_strength("move_right")
	var move_left_strength = Input.get_action_strength("move_left")
	velocity.x = move_right_strength - move_left_strength
	
	var move_down_strength = Input.get_action_strength("move_down")
	var move_up_strength = Input.get_action_strength("move_up")
	velocity.y = move_down_strength - move_up_strength


	if velocity.length() > 0:
		velocity = velocity.normalized() * speed * velocity.length()
		sprite.play()
	else:
		sprite.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		sprite.animation = "walk"
		sprite.flip_v = false
		sprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		sprite.animation = "up"
		sprite.flip_v = velocity.y > 0

	# --- Aiming Logic ---
	var aim_direction = Vector2.ZERO
	
	if Input.get_last_mouse_velocity().length() > 0:
		aim_direction = get_global_mouse_position() - global_position
	else:
		aim_direction.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
		aim_direction.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
		if aim_direction == Vector2.ZERO and velocity != Vector2.ZERO:
			aim_direction = velocity
	
	if aim_direction.length() > 0:
		bean_launcher.rotation = aim_direction.angle()
		
	# --- Firing Logic ---
	if Input.is_action_pressed("fire") and can_fire and aim_direction.length() > 0:
		launch_bean(aim_direction)

func launch_bean(direction: Vector2):
	can_fire = false
	var launch_pos = bean_spawn_point.global_position
	bean_launched.emit(launch_pos, direction)
	shooting_cooldown.start(bean_cooldown)

func _on_fire_timer_timeout():
	can_fire = true
	shooting_cooldown.stop()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		hide()
		hit.emit()
		collision.set_deferred("disabled", true)
