extends SceneTree

## T004/T009: read-only serialized-scene checks, not a gameplay/factory/physics test.
## Never invoke in the original project: autoloads run before this script's guard.
## Use only a disposable project copy with custom user data named ArcanaFoundation-<nonce>,
## then pass -- --isolated-copy. See the feature validation.md manual instructions.
## This script does not instantiate scenes, invoke generators, write saves, or import assets.

const SCENE := "res://levels/level_1/basement_full.tscn"
const SEPARATE_B3 := "res://levels/level_1/basement_b3.tscn"
const EXPECTED_RETAINED_HASH := "6b57013726fc713115e4760415cae5b9a8930cd41a2e935f74537ce776bec9f0"
const EXPECTED_ROOT_BODY_HASH := "a1e9361c0f1cd3c088f56735707c262e7279f771b899c0e6e112d67ec9d4c6fe"
const EXPECTED_B3_HASH := "ac02484cfd729c7680aecee5aef30401d6100e578726a65e04d5757ba8491f86"
const EXPECTED_RETAINED_COUNT := 57

var _failed := 0
var _passed := 0


func _initialize() -> void:
	# This guard is an additional check, not pre-autoload isolation.
	var custom: bool = ProjectSettings.get_setting("application/config/use_custom_user_dir", false)
	var directory: String = ProjectSettings.get_setting("application/config/custom_user_dir_name", "")
	if not custom or not directory.begins_with("ArcanaFoundation-") \
			or not OS.get_cmdline_user_args().has("--isolated-copy"):
		print("BLOCKED: launch only in the explicitly isolated disposable project copy.")
		quit(2)
		return
	if not FileAccess.file_exists(SCENE):
		_check(false, "combined scene exists")
		_finish()
		return
	var text := FileAccess.get_file_as_string(SCENE).replace("\r\n", "\n")
	var nodes := _nodes(text)
	_check(not nodes.is_empty(), "serialized nodes parsed")
	if nodes.is_empty():
		_finish()
		return
	var root: Dictionary = nodes[0]
	_check(root.name == "Stage" and root.parent == "", "root is named Stage")
	_check(str(root.body).sha256_text() == EXPECTED_ROOT_BODY_HASH,
		"root properties and Stage-subclass reference unchanged")
	var paths := {}
	var retained := PackedStringArray()
	for entry: Dictionary in nodes:
		_check(not paths.has(entry.path), "unique serialized path: " + entry.path)
		paths[entry.path] = true
		_check(not _excluded(entry.path), "no integrated B3/GroundExit: " + entry.path)
		if entry.path != "." and not _excluded(entry.path):
			var raw := _regex("(?m)^obstacle_maps = .*\n").sub(entry.raw, "", true)
			retained.append(entry.path + "\n" + raw)
	_check(retained.size() == EXPECTED_RETAINED_COUNT, "retained node count matches baseline")
	_check("\n".join(retained).sha256_text() == EXPECTED_RETAINED_HASH,
		"all retained blocks unchanged except authorized obstacle reference lines")
	for required in ["B1", "B1_5", "B2", "WorldEnvironment", "Player", "CameraRig",
			"Hud", "Bullets", "Spawn", "B1/HiddenGate_B1_5/B1_5Side", "B1_5/World"]:
		_check(paths.has(required), "required direct/floor/Hidden path: " + required)
	for singleton in ["Player", "CameraRig", "Hud"]:
		var count := 0
		for entry: Dictionary in nodes:
			if entry.name == singleton:
				count += 1
		_check(count == 1, "one serialized " + singleton + " (runtime count unverified)")
	for entry: Dictionary in nodes:
		if entry.parent != "":
			_check(paths.has(entry.parent), "serialized parent resolves: " + entry.path)
		for hit: RegExMatch in _regex("NodePath\\(\"([^\"]*)\"\\)").search_all(entry.body):
			var target := _resolve(entry.path, hit.get_string(1))
			_check(paths.has(target), "NodePath resolves: " + entry.path + " -> " + target)
		for line: String in str(entry.body).split("\n"):
			if line.begins_with("obstacle_maps ="):
				_check(not line.contains("null"), "no null obstacle maps: " + entry.path)
	var ext_ids := {}
	for hit: RegExMatch in _regex("(?m)^\\[ext_resource ([^\n]*)\\]").search_all(text):
		var header := hit.get_string(1)
		ext_ids[_attribute(header, "id")] = true
		var resource_path := _attribute(header, "path")
		_check(FileAccess.file_exists(resource_path), "external resource file exists: " + resource_path)
	for hit: RegExMatch in _regex("ExtResource\\(\"([^\"]*)\"\\)").search_all(text):
		_check(ext_ids.has(hit.get_string(1)), "ExtResource id declared: " + hit.get_string(1))
	_check(FileAccess.get_sha256(SEPARATE_B3) == EXPECTED_B3_HASH, "separate B3 bytes unchanged")
	var visibility := FileAccess.get_file_as_string("res://levels/level_1/basement_floor_visibility.gd")
	_check(visibility.begins_with("extends Stage"), "existing root script extends Stage")
	_finish()


func _nodes(text: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for hit: RegExMatch in _regex("(?m)^\\[node ([^\n]*)\\]\n([\\s\\S]*?)(?=^\\[|\\z)").search_all(text):
		var header := hit.get_string(1)
		var node_name := _attribute(header, "name")
		var parent := _attribute(header, "parent")
		var node_path := "." if parent == "" else node_name if parent == "." else parent + "/" + node_name
		result.append({"name": node_name, "parent": parent, "path": node_path,
			"body": hit.get_string(2), "raw": hit.get_string(0)})
	return result


func _attribute(header: String, key: String) -> String:
	var hit := _regex("\\b" + key + "=\"([^\"]*)\"").search(header)
	return hit.get_string(1) if hit != null else ""


func _resolve(from: String, relative: String) -> String:
	var parts: Array[String] = []
	for part: String in (from + "/" + relative).split("/"):
		if part == "." or part == "":
			continue
		if part == "..":
			if not parts.is_empty():
				parts.pop_back()
		else:
			parts.append(part)
	return "/".join(PackedStringArray(parts)) if not parts.is_empty() else "."


func _excluded(path: String) -> bool:
	return path == "B3" or path.begins_with("B3/") \
		or path == "GroundExit" or path.begins_with("GroundExit/")


func _regex(pattern: String) -> RegEx:
	var expression := RegEx.new()
	var error := expression.compile(pattern)
	assert(error == OK, "invalid structural-check expression")
	return expression


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
		print("PASSED: ", label)
	else:
		_failed += 1
		print("FAILED: ", label)


func _finish() -> void:
	print("STRUCTURAL RESULT: ", _passed, " passed, ", _failed, " failed")
	print("NOT RUN by this structural script: scene instantiation, physics, registration, camera,")
	print("factory/navigation gameplay, containment playtest, startup, recovery, checkpoints, waves.")
	quit(1 if _failed > 0 else 0)
