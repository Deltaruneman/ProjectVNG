extends SceneTree
## Two isolated processes: local debugger server and rendered suspended client.
var server_mode := false
var server := TCPServer.new()
var packet := PacketPeerStream.new()
var connected := false
var thread_id := 0
var pending_phase := ""
var pending_at := 0
var started := 0
var checks := 0
var failures := 0
var manager: Node
const MARKER := "user://suspend-ready.txt"
func _initialize() -> void:
	if not "ArcanaSuspend-20261128" in OS.get_user_data_dir(): quit(2); return
	started = Time.get_ticks_msec()
	server_mode = OS.get_cmdline_user_args().has("--suspend-server")
	if server_mode:
		if server.listen(6179,"127.0.0.1")!=OK: quit(2); return
		print("SUSPEND_SERVER_READY")
	else:
		client.call_deferred()
func _process(_delta: float) -> bool:
	if not server_mode: return false
	if not connected and server.is_connection_available():
		packet.stream_peer = server.take_connection()
		connected = true
	if connected:
		while packet.get_available_packet_count()>0:
			var message: Variant = packet.get_var()
			if not message is Array or message.is_empty(): continue
			var name: String = str(message[0])
			var args: Array = message[2] if message.size()==3 else message[1]
			if name=="fixture:suspend":
				thread_id = int(args[0])
				pending_phase = str(args[1])
				pending_at = Time.get_ticks_msec()+300
				packet.put_var(["scene:suspend_changed",thread_id,[true]])
				print("NATIVE_SUSPEND ",pending_phase)
			elif name=="fixture:resume":
				packet.put_var(["scene:suspend_changed",thread_id,[false]])
				print("NATIVE_RESUME ",args)
			elif name=="fixture:done": quit(); return false
	if pending_at>0 and Time.get_ticks_msec()>=pending_at:
		var file := FileAccess.open(MARKER,FileAccess.WRITE)
		file.store_string(pending_phase)
		pending_at = 0
	if Time.get_ticks_msec()-started>80000: quit(2)
	return false
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int = 3) -> void:
	for i in n: await RenderingServer.frame_post_draw
func suspend(phase: String) -> void:
	if FileAccess.file_exists(MARKER): DirAccess.remove_absolute(ProjectSettings.globalize_path(MARKER))
	EngineDebugger.send_message("fixture:suspend",[OS.get_main_thread_id(),phase])
	var deadline := Time.get_ticks_msec()+6000
	while Time.get_ticks_msec()<deadline:
		await frames(1)
		if FileAccess.file_exists(MARKER) and FileAccess.get_file_as_string(MARKER)==phase: return
	check(false,"native suspension handshake "+phase)
func resume(phase: String) -> void:
	EngineDebugger.send_message("fixture:resume",[phase])
	await frames(8)
func idle_transition() -> void:
	var deadline := Time.get_ticks_msec()+18000
	while manager.is_changing() and Time.get_ticks_msec()<deadline: await frames(1)
	check(not manager.is_changing(),"transition completes after native resume")
func client() -> void:
	check(EngineDebugger.is_active(),"real remote debugger active")
	manager = root.get_node("GameManager")
	root.get_node("SaveSystem").save_path = "user://suspend-fixture.json"
	manager.reset()
	manager.flags["story_possession"] = true
	manager.stage_changed.connect(func(stage: Node3D):
		stage.player.invincible = true
		for enemy: Node in get_nodes_in_group("enemies"): enemy.process_mode = Node.PROCESS_MODE_DISABLED)
	var menu: Control = load("res://ui/main_menu.tscn").instantiate()
	root.add_child(menu)
	current_scene = menu
	await frames(4)
	await suspend("load-start")
	manager.change_stage(manager.FIRST_STAGE,"",false)
	var loader: Node = manager._scene_loading
	await frames(12)
	check(loader.busy and loader._elapsed==0.0,"render continuations run while Node processing is natively suspended")
	check(current_scene==menu,"scene is retained while editor suspension owns the game")
	await resume("load-start")
	await idle_transition()
	await frames(12)
	check(current_scene.has_node("Player") and not paused,"new stage resumes without stuck gameplay pause")
	if OS.get_cmdline_user_args().has("--load-start-only"):
		print("SUSPEND_BEFORE_PROBES ",checks-failures,"/",checks)
		EngineDebugger.send_message("fixture:done",[])
		await frames(3)
		quit(1 if failures else 0)
		return
	var inventory: Node = root.get_node("InventoryMenu")
	for overlay: Node in [root.get_node("PauseMenu"),inventory,inventory._cheat_menu]:
		if overlay == inventory._cheat_menu: await overlay._open_menu()
		else: await overlay.open_menu()
		await frames(6)
		check(overlay.is_open and paused,str(overlay.name)+" opens before suspension")
		await suspend(str(overlay.name))
		overlay.close_menu()
		await frames(8)
		check(paused,str(overlay.name)+" does not change pause while suspended")
		await resume(str(overlay.name))
		await frames(8)
		check(not overlay.is_open and not paused,str(overlay.name)+" resumes correctly after editor returns")
	manager.change_stage("res://icon.svg","",false)
	var deadline := Time.get_ticks_msec()+10000
	while not loader._error and Time.get_ticks_msec()<deadline: await frames(1)
	check(loader._error,"error-return suspension case reached")
	await suspend("error-return")
	loader._cancel_failed_load()
	await frames(8)
	check(loader.busy and paused,"error return defers pause restoration while suspended")
	await resume("error-return")
	await frames(8)
	check(not loader.busy and not paused and not manager.is_changing(),"error return restores input/pause after native resume")
	print("SUSPEND_RESULT ",checks-failures,"/",checks)
	EngineDebugger.send_message("fixture:done",[])
	await frames(3)
	quit(1 if failures else 0)
