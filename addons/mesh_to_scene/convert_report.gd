@tool
class_name MeshToSceneReport
extends RefCounted

## Result of one conversion run: what was created, skipped, and anything worth
## telling the user about. The dock renders this into its log panel.

## res:// paths of scenes that were saved.
var created_scenes: PackedStringArray = []

## res:// paths of scenes that replaced an already existing file.
var overwritten: PackedStringArray = []

## res:// paths of source files that had no usable mesh and were skipped.
var skipped_files: PackedStringArray = []

## Non-fatal notes (e.g. animated meshes exported as static geometry).
var warnings: PackedStringArray = []

## Fatal problems that stopped or broke the run.
var errors: PackedStringArray = []

## res:// path of the saved MeshLibrary, or "" if none was generated.
var library_path: String = ""


## Human-readable multi-line summary for the log panel.
func summary() -> String:
	var lines: Array[String] = []
	lines.append("Created scenes: %d" % created_scenes.size())
	if overwritten.size() > 0:
		lines.append("Overwritten: %d" % overwritten.size())
	if skipped_files.size() > 0:
		lines.append("Skipped files (no mesh): %d" % skipped_files.size())
	if not library_path.is_empty():
		lines.append("MeshLibrary: %s" % library_path)

	for w in warnings:
		lines.append("[warning] %s" % w)
	for e in errors:
		lines.append("[error] %s" % e)

	return "\n".join(lines)
