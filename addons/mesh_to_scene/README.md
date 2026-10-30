# Mesh to Scene Batch Converter

A Godot 4 editor plugin that batch-converts imported mesh files
(`.fbx`, `.glb`, `.gltf`) into individual `.tscn` scenes — one per mesh — with
optional collision generation and MeshLibrary building.

Handy for turning a modular asset kit into ready-to-use scenes and a GridMap
MeshLibrary in one pass.

## Features

- Scans a folder (optionally recursively) for `.fbx`, `.glb` and `.gltf` files.
- Creates one scene per mesh — a file with several meshes yields several scenes.
- Optional collision: `Trimesh` (exact concave) or `Convex` (hull).
- Choose the scene root: `MeshInstance3D` or `StaticBody3D`.
- Mirror the source folder structure in the output, or flatten it.
- Optionally builds a `MeshLibrary` from the generated scenes, for GridMap.
- Live file count, progress bar, and a color-coded result log. Settings are
  remembered between sessions.

## Requirements

- Godot **4.3 or later** (developed and tested on 4.7).

## Installation

1. Copy the `addons/mesh_to_scene` folder into your project.
2. Enable **Mesh to Scene Batch Converter** in
   *Project → Project Settings → Plugins*.
3. A **Mesh to Scene** dock appears, docked next to the FileSystem tab.

## Usage

Fill in the dock and press **Convert**:

- **Source folder** — folder to scan for meshes (required).
- **Scan recursively** — also scan sub-folders. The count below shows how many
  files will be converted.
- **File types** — which extensions to include (`.fbx`, `.glb`, `.gltf`).
- **Scene root** — `MeshInstance3D` (collision nested in a `StaticBody3D`) or
  `StaticBody3D` (mesh and collision as children).
- **Add collision** — generate collision for each mesh.
  - **Collision type** — `Trimesh` (exact concave) or `Convex` (hull).
- **Output folder** — where scenes are saved (required).
- **Output layout** — `Mirror source folders` or `Flatten into one folder`.
- **Generate MeshLibrary** — also build a `MeshLibrary` from the generated
  scenes, saved to the given folder and file name (overwrites an existing file).

Each `MeshInstance3D` found in a file becomes its own scene, named after the
mesh node. Existing scenes with the same name are overwritten. Files with a
skeleton/skin are exported as static geometry (a warning is logged); files with
no mesh are skipped.

## Using the MeshLibrary with a GridMap

1. Add a **GridMap** node and assign the generated `.tres` to its **Mesh Library**.
2. Set **Cell → Size** to match your kit's module size (e.g. `2, 2, 2` for a
   2&nbsp;m grid). Pieces keep their real-world size, so if the cells are larger
   than a piece it will look small — this is a GridMap setting, not the mesh.
3. To lay floors on the ground plane, turn **Cell → Center Y** off.

## Notes

- Meshes must already be imported by Godot before conversion.
- Each mesh's import transform (the FBX/glTF axis and unit conversion) is baked
  into the geometry, so generated scenes and MeshLibrary items use identity
  transforms and appear upright and correctly sized — including inside a GridMap.
  Level-of-detail (LOD) meshes are not carried through the bake.
- MeshLibrary items are created without preview thumbnails; open the library in
  the editor to generate previews if you need them.

## License

MIT — see [LICENSE](LICENSE).
