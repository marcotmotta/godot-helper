extends CharacterBody3D

var SPEED = 10
var JUMP_SPEED = 20

var camera
var rotation_helper
var first_person = true

var MOUSE_SENSITIVITY = 0.05

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Camera
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

func _physics_process(delta):
	var camera_transform = camera.get_global_transform()

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y -= gravity * delta * 10
	elif Input.is_action_just_pressed("space"): # Jumping
			velocity.y = JUMP_SPEED

	var direction = Vector3.ZERO
	
	var input_dir = Input.get_vector("a", "d", "s", "w")
	direction += -camera_transform.basis.z.normalized() * input_dir.y
	direction += camera_transform.basis.x.normalized() * input_dir.x

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	# Ground Velocity
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	# Moving the Character
	move_and_slide()

func _input(event):
	# Mouse rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("esc"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Third person
	if Input.is_action_just_pressed("f5"):
		if first_person:
			camera.position.y = 3
			camera.position.z = 4
			camera.rotation_degrees.x = -35
			first_person = false
		else:
			camera.position.y = 0.6
			camera.position.z = -0.3
			camera.rotation_degrees.x = 0
			first_person = true
