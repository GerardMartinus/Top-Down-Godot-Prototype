extends CharacterBody2D

@export_category("Player Settings")
@export var player_life = 10

var SPEED = 100.0
var rolling_count = 0

var is_rolling = false
var is_attacking = false
var enemy_is_running = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var current_scene = get_tree().current_scene
@onready var player_hitbox = $Pivot
@onready var player_damage_hitbox = $Pivot/Hitbox
@onready var _animated_sprite = $AnimatedSprite2D
@onready var rain = $Rain/GPUParticles2D

func _ready():
	_animated_sprite.play("IdleDown")
	player_life = 10

func _physics_process(delta):	
	if Input.get_action_strength("ui_up") and not is_rolling and not is_attacking:
		_animated_sprite.play("WalkUp")
		player_hitbox.set_rotation_degrees(180)
	elif Input.get_action_strength("ui_down") and not is_rolling and not is_attacking:
		_animated_sprite.play("WalkDown")
		player_hitbox.set_rotation_degrees(0)
	elif Input.get_action_strength("ui_left") and not is_rolling and not is_attacking:
		_animated_sprite.play("WalkLeft")
		player_hitbox.set_rotation_degrees(90)
	elif Input.get_action_strength("ui_right") and not is_rolling and not is_attacking:
		_animated_sprite.play("WalkRight")
		player_hitbox.set_rotation_degrees(270)
	elif Input.is_action_just_released("ui_up"):
		_animated_sprite.play("IdleUp")
	elif Input.is_action_just_released("ui_down"):
		_animated_sprite.play("IdleDown")
	elif Input.is_action_just_released("ui_left"):
		_animated_sprite.play("IdleLeft")
	elif Input.is_action_just_released("ui_right"):
		_animated_sprite.play("IdleRight")
		
	if Input.is_action_pressed("ui_up") and is_rolling:
		_animated_sprite.play("DashUp")
	elif Input.is_action_pressed("ui_down") and is_rolling:
		_animated_sprite.play("DashDown")
	elif Input.is_action_pressed("ui_left") and is_rolling:
		_animated_sprite.play("DashLeft")
	elif Input.is_action_pressed("ui_right") and is_rolling:
		_animated_sprite.play("DashRight")
	
	if Input.is_action_pressed("ui_up") and is_attacking and not is_rolling:
		_animated_sprite.play("AttackUp")
	elif Input.is_action_pressed("ui_down") and is_attacking and not is_rolling:
		_animated_sprite.play("AttackDown")
	elif Input.is_action_pressed("ui_left") and is_attacking and not is_rolling:
		_animated_sprite.play("AttackLeft")
	elif Input.is_action_pressed("ui_right") and is_attacking and not is_rolling:
		_animated_sprite.play("AttackRight")
	
	if Input.is_action_just_pressed("ui_attack") and not is_rolling:
		_attack()
		match _animated_sprite.get_animation():
			'IdleUp':
				_animated_sprite.play("AttackUp")
				_animated_sprite.connect('animation_finished', func(): _animated_sprite.play("IdleUp"))
			'IdleDown':
				_animated_sprite.play("AttackDown")
				_animated_sprite.connect('animation_finished', func(): _animated_sprite.play("IdleDown"))
			'IdleLeft':
				_animated_sprite.play("AttackLeft")
				_animated_sprite.connect('animation_finished', func(): _animated_sprite.play("IdleLeft"))
			'IdleRight':
				_animated_sprite.play("AttackRight")
				_animated_sprite.connect('animation_finished', func(): _animated_sprite.play("IdleRight"))
		
		for enemy in get_tree().get_nodes_in_group("Enemy"):
			print(enemy.get)
			player_damage_hitbox.connect("body_exited", func(body): 
				if body == enemy:
					if is_attacking:
						body.enemy_life -= 10
						#body.queue_free()
			)
			player_damage_hitbox.connect("body_entered", func(body): 
				if body == enemy:
					if is_attacking:
						pass
						body.enemy_life -= 5
						#body.queue_free()
			)
		
	
	for enemy_trigger in get_tree().get_nodes_in_group("EnemyTrigger"):	
		var enemy = enemy_trigger.get_parent()
		enemy_trigger.connect("body_entered", func(body):
			enemy_is_running = true
		)
		enemy_trigger.connect("body_exited", func(body):
			enemy_is_running = false
		)
		if enemy_is_running:
			var player_position = self.position
			enemy.velocity = enemy.position.direction_to(player_position) * SPEED
			if enemy.position.distance_to(player_position) > 10:
				enemy.move_and_slide()
			
	
	if Input.is_action_just_pressed("ui_accept"):
		_dash()
	
	var direction = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
							Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	
	if direction.x < 0:
		rain.process_material.gravity.x = 500
	elif direction.x > 0:
		rain.process_material.gravity.x = -500
	elif direction.x > 0 and is_rolling:
		rain.process_material.gravity.x += 1000
	elif direction.x > 0 and is_rolling:
		rain.process_material.gravity.x -= 1000
	else:
		rain.process_material.gravity.x = 0
		

	if direction.length() > 0:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if player_life == 0:
		_animated_sprite.play("Death")
		_animated_sprite.connect("animation_finished", func(): _dead())
		SPEED = 0
		
	move_and_slide()

func _dead():
	$DeadDuration.start()
	
func _dash():
	rolling_count += 1
	if rolling_count == 1: 
		SPEED = SPEED * 2.8
		is_rolling = true
		$RollingDuration.start()
	
func _attack():
	player_hitbox.set_visible(true)
	is_attacking = true
	$AttackDuration.start()


func _on_timer_timeout():
	SPEED = 100.0
	is_rolling = false
	rolling_count = 0

func _on_attack_duration_timeout():
	is_attacking = false
	player_hitbox.set_visible(false)

func _on_dead_duration_timeout():
	get_tree().reload_current_scene()
