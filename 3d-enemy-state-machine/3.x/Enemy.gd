extends KinematicBody

const GRAVITY = -40
const WALK_SPEED = 5
const JUMP_SPEED = 15
const ACCEL = 10
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40
var vel = Vector3()
var dir = Vector3()
var dist2player
var player
var patrol_distance = 15
var patrol_point

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

func _physics_process(delta):
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		PATROL:
			find_direction(delta, patrol_point)
			process_movement(delta)
			$AnimationPlayer.play("run")
			if check_patrol_distance() <= 2:
				setState(IDLE)
		RUN:
			find_direction(delta, player.translation)
			process_movement(delta)
			$AnimationPlayer.play("run")
		ATTACK:
			$AnimationPlayer.play("attack")

func setState(new_state):
	#what to do when some state begin
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
	if state == current_state:
		return true
	return false

func find_direction(_delta, point):
	# Walking
	dir = Vector3()

	dir = point - self.translation

	look_at(point, Vector3.UP)
	rotation.x = 0

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= WALK_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z

	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func choose_patrol_point():
	var new_point = Vector3()
	new_point.y = 0
	new_point.x = self.translation.x + rng.randi_range(-patrol_distance, patrol_distance)
	new_point.z = self.translation.z + rng.randi_range(-patrol_distance, patrol_distance)
	return new_point

func check_patrol_distance():
	var pos = Vector3()
	pos.y = 0
	pos.x = self.translation.x
	pos.z = self.translation.z
	return pos.distance_to(patrol_point)

func _on_IdleTimer_timeout():
	if is_in_state(IDLE):
		setState(PATROL)

func _on_SightRange_body_entered(body):
	if body.is_in_group('player'):
		setState(RUN)

func _on_SightRange_body_exited(body):
	if body.is_in_group('player'):
		setState(IDLE)
