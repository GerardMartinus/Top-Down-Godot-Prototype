extends CharacterBody2D


const SPEED = 100.0
var hurt = false
@onready var _animated_sprite = $AnimatedSprite2D
@onready var player_hitbox_pivot = $"../Player/Pivot"
@onready var enemy_hp = $HP

@export_category("Enemy Settings")
@export var enemy_life = global.enemy_life

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	_animated_sprite.play("IddleDown")

func _physics_process(delta):
	enemy_hp.set_text(str(enemy_life))
	if enemy_life <= 0:
		queue_free()
