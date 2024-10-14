extends CharacterBody2D

@export var speed = 300
@export var acceleration = 800
@export var deceleration = 600
@export var gravity = 200
@export var jump_force = 200

const FADE_DURATION = 0.2
const LAG_FACTOR = 0.3

@onready var fade_container = $"../FadeContainer"
@onready var tween: Tween
@onready var fade_sprite: AnimatedSprite2D = $"../FadeContainer/FadeSprite"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var walk_sound: AudioStreamPlayer2D = $WalkSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var step_timer: Timer = $StepTimer

var max_opacity = 1
var last_floor_position: Vector2
var is_walking = false

func _ready():
	fade_sprite.modulate.a = 0  
	last_floor_position = global_position
	fade_container.global_position = last_floor_position
	if animated_sprite == null:
		print("Error: AnimatedSprite2D not found!")
	
	walk_sound.stream = preload("res://Assets/Sounds/explosion.wav")
	walk_sound.volume_db = -20  
	
	jump_sound.stream = preload("res://Assets/Sounds/jump.wav")
	jump_sound.volume_db = -20 

	step_timer.connect("timeout", Callable(self, "_on_step_timer_timeout"))
	step_timer.set_wait_time(0.75) 
	step_timer.set_one_shot(false)

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		"""jump_sound.play()"""
		velocity.y = -jump_force
	
	handle_horizontal_movement(delta)
	
	move_and_slide()
	
func _on_cloud_platform_body_entered(body: Node2D) -> void:
	if is_on_floor():
		var target_x = global_position.x
		fade_container.global_position.x = lerp(fade_container.global_position.x, target_x, LAG_FACTOR)
		last_floor_position = fade_container.global_position
		fade_spritei(true)
	else:
		fade_container.global_position = last_floor_position
		fade_spritei(false)
	
	if is_on_floor():
		fade_container.global_position.y = global_position.y
	
	update_walking_sound()

func handle_horizontal_movement(delta):
	var input_direction = 0
	if Input.is_action_pressed("ui_right"):
		input_direction += 1
		animated_sprite.play("GhostRight")
	elif Input.is_action_pressed("ui_left"):
		input_direction -= 1
		animated_sprite.play("GhostLeft")
	else:
		animated_sprite.play("GhostIdle")
	
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
		is_walking = true
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		is_walking = false
	
	velocity.x = clamp(velocity.x, -speed, speed)

func move_toward(current, target, max_delta):
	if abs(target - current) <= max_delta:
		return target
	return current + sign(target - current) * max_delta

func fade_spritei(fade_in: bool):
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	if fade_in:
		tween.tween_property(fade_sprite, "modulate:a", max_opacity, FADE_DURATION)
	else:
		tween.tween_property(fade_sprite, "modulate:a", 0, FADE_DURATION)

func update_walking_sound():
	if is_walking and is_on_floor():
		if step_timer.is_stopped():
			play_step_sound()
			step_timer.start()
	else:
		walk_sound.stop()
		step_timer.stop()

func play_step_sound():
	walk_sound.pitch_scale = randf_range(0.8, 1.5)  
	walk_sound.play()

func _on_step_timer_timeout():
	step_timer.start()
	play_step_sound()
	step_timer.stop()
