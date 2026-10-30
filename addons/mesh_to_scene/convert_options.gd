@tool
class_name MeshToSceneOptions
extends RefCounted

## Plain data object holding every setting for one batch conversion run.
##
## The dock UI fills this in from its controls and passes it to
## [MeshToSceneConverter.convert]. Keeping the settings in one object keeps the
## converter free of any UI dependencies, so it can be unit-tested on its own.

enum CollisionType {
	TRIMESH, ## Exact concave shape following the mesh geometry. Best for static level pieces.
	CONVEX, ## Simplified convex hull. Cheaper, but ignores holes and concave detail.
}

enum SceneRoot {
	MESH_INSTANCE, ## Root is a MeshInstance3D; collision (if any) is a nested StaticBody3D.
	STATIC_BODY, ## Root is a StaticBody3D; the mesh and collision are its children.
}

enum OutputLayout {
	MIRROR, ## Recreate the source sub-folder structure under the output folder.
	FLATTEN, ## Save every generated scene directly in the output folder.
}

## Folder (res:// path) to scan for mesh files. Required.
var source_folder: String = ""

## Scan sub-folders of [member source_folder] as well.
var recursive: bool = true

## File extensions (lower-case, no dot) to include while scanning.
var extensions: PackedStringArray = ["fbx", "glb", "gltf"]

## Whether to generate collision for each mesh.
var add_collision: bool = false

## Which kind of collision shape to build when [member add_collision] is true.
var collision_type: CollisionType = CollisionType.TRIMESH

## Node layout of each generated scene.
var scene_root: SceneRoot = SceneRoot.MESH_INSTANCE

## Folder (res:// path) where generated scenes are saved. Required.
var output_folder: String = ""

## How generated scenes are laid out under [member output_folder].
var output_layout: OutputLayout = OutputLayout.MIRROR

## Whether to build a MeshLibrary from every converted mesh.
var generate_mesh_library: bool = false

## Folder (res:// path) where the MeshLibrary is saved.
var library_path: String = ""

## File name (including the .tres extension) of the MeshLibrary.
var library_file_name: String = "mesh_library.tres"


## Returns a non-empty error string if the options are not usable, or "" if valid.
func validate() -> String:
	if source_folder.is_empty():
		return "Source folder is required."
	if not DirAccess.dir_exists_absolute(source_folder):
		return "Source folder does not exist: %s" % source_folder
	if output_folder.is_empty():
		return "Output folder is required."
	if extensions.is_empty():
		return "Select at least one file type to scan."
	if generate_mesh_library:
		if library_path.is_empty():
			return "MeshLibrary path is required when 'Generate MeshLibrary' is on."
		if library_file_name.is_empty():
			return "MeshLibrary file name is required."
	return ""
