extends Node2D

@onready var pause_menu = $PauseMenu
@onready var hud = $Hud
@onready var paused_game = false


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("PauseButton"):
		button.connect('pressed', func():
			match button.name:
				'Continue':
					pause_menu.set_visible(false)
					hud.set_visible(true)
					get_tree().paused = false
			)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for hud_label in get_tree().get_nodes_in_group("HudLabel"):
		match hud_label.name:
			'Life':
				hud_label.set_text(str("Life: ", global.player_life))
			'Coins':
				hud_label.set_text(str("Coins: ", global.coins))

func _input(event):
	if Input.is_action_just_pressed("ui_cancel") and not paused_game:
		pause_menu.set_visible(true)
		hud.set_visible(false)
		get_tree().paused = true

