extends CharacterBody3D

const SPEED = 2

var player
var patrol_distance = 15
var patrol_point

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {
	IDLE,
	PATROL,
	RUN,
	ATTACK
}

var state = IDLE

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	player = get_parent().get_node('Player')

	setState(IDLE)

func _physics_process(delta):
	# Vertical Velocity
	# Must be here so the character falls even if its not moving horizontally
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y -= gravity * delta * 5
		move_and_slide()

	match state:
		IDLE:
			#$AnimationPlayer.play("idle")
			pass
		PATROL:
			process_movement(delta, patrol_point)
			#$AnimationPlayer.play("run")
			if check_patrol_distance() <= 2:
				setState(IDLE)
		RUN:
			process_movement(delta, player.position)
			#$AnimationPlayer.play("run")
		ATTACK:
			#$AnimationPlayer.play("attack")
			pass

func setState(new_state):
	# What to do when some state begin
	match new_state:
		IDLE:
			$IdleTimer.start()
		PATROL:
			patrol_point = choose_patrol_point()
		RUN:
			pass
		ATTACK:
			pass
	state = new_state

func is_in_state(current_state):
	return  state == current_state

func process_movement(delta, target_point):
	# Calculate direction
	var direction = Vector3()
	direction = (target_point - self.position).normalized()

	look_at(target_point, Vector3.UP)
	rotation.x = 0

	# Ground Velocity
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	move_and_slide()

func choose_patrol_point():
	var new_point = Vector3()
	new_point.y = 0
	new_point.x = self.position.x + rng.randi_range(-patrol_distance, patrol_distance)
	new_point.z = self.position.z + rng.randi_range(-patrol_distance, patrol_distance)
	return new_point

func check_patrol_distance():
	var pos = Vector3()
	pos.y = 0
	pos.x = self.position.x
	pos.z = self.position.z
	return pos.distance_to(patrol_point)

func _on_idle_timer_timeout():
	if is_in_state(IDLE):
		setState(PATROL)

func _on_sight_range_body_entered(body):
	if body.is_in_group('player'):
		setState(RUN)

func _on_sight_range_body_exited(body):
	if body.is_in_group('player'):
		setState(IDLE)
