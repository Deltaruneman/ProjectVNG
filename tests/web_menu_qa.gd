extends Node
const FX=preload("res://scenes/player/battle_vfx.gd")
var label:Label
var host:Node3D
var last_audio=""
func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	host=Node3D.new()
	add_child(host)
	var canvas=CanvasLayer.new()
	canvas.layer=180
	add_child(canvas)
	var button=Button.new()
	button.text="QA: Chiến đấu"
	button.position=Vector2(12,30)
	button.pressed.connect(play)
	canvas.add_child(button)
	var ui_button=Button.new()
	ui_button.text="QA: Giao diện"
	ui_button.position=Vector2(12,90)
	ui_button.pressed.connect(func(): PauseMenu._preview_sound("UI"))
	canvas.add_child(ui_button)
	label=Label.new()
	label.position=Vector2(12,150)
	label.add_theme_font_size_override("font_size",12)
	canvas.add_child(label)
func play():
	FX.play_skill_sound(host,"weapon_throw")
	
	last_audio="players="+str(host.get_child_count())
func _process(_delta):
	label.text="focus="+str(GameSettings._focused)+" masterMute="+str(AudioServer.is_bus_mute(0))+" sfxMute="+str(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")))+" "+last_audio
