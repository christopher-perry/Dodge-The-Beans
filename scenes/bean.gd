extends Area2D

@export var speed = 1000
var velocity = Vector2.ZERO

# Set the initial direction and position
func start(position_2d: Vector2, direction_vector: Vector2):
	position = position_2d
	# Normalize the direction so speed is constant regardless of input vector length
	velocity = direction_vector.normalized() * speed
	rotation = direction_vector.angle() + PI / 2 # Rotate to face direction (assuming sprite is pointing up)

func _physics_process(delta):
	# Move the bean forward
	position += velocity * delta
	
	# Check if the bean is off-screen and queue it for deletion
	var screen_size = get_viewport_rect().size
	var off_screen_margin = 100
	if position.x < -off_screen_margin or position.x > screen_size.x + off_screen_margin or \
	   position.y < -off_screen_margin or position.y > screen_size.y + off_screen_margin:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		body.take_hit()
		queue_free()
		
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
