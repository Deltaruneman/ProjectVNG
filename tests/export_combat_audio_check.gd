extends Node3D
const FX = preload("res://scenes/player/battle_vfx.gd")
var checks := 0
var failures := 0
func check(ok: bool, label: String):
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func _ready():
	if not "ArcanaExportAudio-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run():
	SaveSystem.save_path="user://export-audio-fixture.json"
	GameSettings.values.background_mute=false
	GameSettings.values.mute=false
	GameSettings.values.master=1.0
	GameSettings.values.sfx=1.0
	GameSettings.apply_audio()
	var path := FX.SOUND_ROOT+"Attacks/Sword Attacks Hits and Blocks/Sword Attack 1.ogg"
	print("EXPORT_AUDIO_ENV exported=",OS.has_feature("standalone")," editor=",OS.has_feature("editor")," driver=",AudioServer.get_driver_name()," raw_exists=",FileAccess.file_exists(path)," resource_exists=",ResourceLoader.exists(path)," user_dir=",OS.get_user_data_dir())
	check(ResourceLoader.exists(path),"combat stream resolves through imported resource mapping")
	var bus := AudioServer.get_bus_index("SFX")
	var events := ["orb_white","weapon_throw","weapon_attack","player_hit","enemy_attack","enemy_hit","parry_success","","dagger","active_wind_1","active_wind_2","active_wind_3","ultimate_wind_1","ultimate_wind_2","active_fire_1","active_fire_2","active_fire_3","ultimate_fire_1","ultimate_fire_2","fire_impact","fire_hit","active_ice_1","active_ice_2","ultimate_ice_2","active_ice_3","ultimate_ice_1","ice_hit","active_lightning_1","active_lightning_2","active_lightning_3","active_lightning_4","ultimate_lightning_1","ultimate_lightning_2","lightning_hit","wind_hit"]
	for event: String in events:
		FX.play_skill_sound(self,event)
		var audio := get_child(get_child_count()-1) as AudioStreamPlayer if get_child_count()>0 else null
		check(audio!=null and audio.playing and audio.stream is AudioStream and audio.bus=="SFX","exported sound starts: "+event)
		if audio!=null:
			if event in ["weapon_throw","weapon_attack","player_hit","enemy_attack","enemy_hit","parry_success","active_fire_1","active_ice_1","active_lightning_1","active_wind_3"]:
				var peak := -1000.0
				var start := Time.get_ticks_msec()
				while Time.get_ticks_msec()-start<500:
					await get_tree().process_frame
					peak=maxf(peak,AudioServer.get_bus_peak_volume_left_db(bus,0))
				print("SFX_PEAK ",event," ",peak)
				check(peak > -60.0,"exported sound reaches SFX mixer: "+event)
			audio.queue_free()
			await get_tree().process_frame
	FX.play_skill_sound(self,"unknown_test_sound")
	check(get_child_count()==0,"unknown ID creates no audio node")
	FX.play_skill_sound(self,"weapon_attack")
	await get_tree().create_timer(3.0).timeout
	check(get_child_count()==0,"finished combat sound cleans itself up")
	print("EXPORT_AUDIO_RESULT ",checks-failures,"/",checks," failures=",failures)
	get_tree().quit(0 if failures==0 else 1)
