# Synty Unity-to-Godot Converter

Convert Synty Studios Unity asset packs (`.unitypackage` files) to Godot 4.6 with full shader support, automatic material conversion, and mixed FBX/GLB model processing.

**Version 2.4** - Output subfolder organization, retain source directory structure.

## Features

- **Full material conversion** - Parses Unity `.mat` files and generates Godot `ShaderMaterial` `.tres` files
- **3-tier shader detection** - GUID lookup (56 known shaders), name pattern matching, property-based analysis
- **7 Godot shaders** - Polygon, Foliage, Crystal, Water, Clouds, Particles, Skydome
- **FBX/GLB mesh conversion** - Imports prepared models via Godot CLI with materials pre-assigned
- **Texture handling** - Extracts textures from `.unitypackage` with fallback to SourceFiles
- **Modern GUI** - CustomTkinter interface with real-time logging, progress display, and settings persistence
- **Global shader uniforms** - Generates `project.godot` with wind, sky, and water parameters
- **Recursive folder discovery** - Finds FBX files in nested pack structures automatically
- **Project merging** - Merges `project.godot` settings for multi-pack workflows
- **LOD inheritance** - Consistent shader detection across LOD levels
- **Smart filtering** - When using `--filter`, only copies textures and materials needed by filtered FBX files
- **High quality texture compression** - Optional BPTC compression for improved texture quality
- **Per-pack isolation** - Each pack gets its own folder with `mesh_material_mapping.json` for targeted processing
- **Dynamic shader discovery** - Finds existing shaders in your project before copying duplicates
- **Clean FBX paths** - Strips `SourceFiles/FBX/Models` prefixes for cleaner output structure
- **Comprehensive fallback matching** - Name variations, prefix swaps, and fuzzy matching (Levenshtein) for materials
- **Output subfolder organization** - Organize converted packs into custom subfolders with `--output-subfolder`
- **Retain source structure** - Preserve `Source_Files/FBX/` subdirectory structure in mesh output with `--retain-subfolders`
- **Optional Blender GLB path** - Convert character and animation FBX files to GLB first with `--animated-to-glb`
- **Godot humanoid retarget workflow** - Standardize characters and animation sources to `SkeletonProfileHumanoid` on import so animations can be shared

## Quick Start

```bash
# CLI (no dependencies required)
# Note: --source-files supports recursive discovery, so you can point to
# the top-level SourceFiles folder even if FBX files are in subdirectories.
python converter.py \
    --unity-package "C:\SyntyComplete\POLYGON_Fantasy\Fantasy.unitypackage" \
    --source-files "C:\SyntyComplete\POLYGON_Fantasy\SourceFiles" \
    --output "C:\Godot\Projects\fantasy-assets" \
    --godot "C:\Godot\Godot_v4.6-stable_mono_win64\Godot_v4.6-stable_mono_win64.exe"

# GUI (requires additional dependencies)
pip install -r requirements-gui.txt
python gui.py

# Godot humanoid retarget workflow

```

## Installation

**Requirements:**
- Python 3.10+
- Godot 4.6 (mono or standard)
- Blender (optional, only for `--animated-to-glb`)

**GUI dependencies** (optional):
```bash
pip install -r requirements-gui.txt
```

This installs CustomTkinter for the graphical interface.

## CLI Options

| Flag | Required | Description |
|------|----------|-------------|
| `--unity-package` | Yes | Path to `.unitypackage` file |
| `--source-files` | Yes | Path to SourceFiles folder containing FBX/ (recursive search, Textures/ optional) |
| `--output` | Yes | Output directory for Godot project |
| `--godot` | Yes | Path to Godot 4.6 executable |
| `--dry-run` | No | Preview without writing files |
| `--verbose` | No | Enable debug logging |
| `--skip-fbx-copy` | No | Skip copying FBX files |
| `--skip-godot-cli` | No | Skip Godot CLI (materials only) |
| `--skip-godot-import` | No | Skip Godot import phase (converter script still runs) |
| `--godot-timeout` | No | Godot CLI timeout in seconds (default: 600) |
| `--keep-meshes-together` | No | Keep all meshes from one FBX in a single scene |
| `--mesh-format` | No | Output format: `tscn` (default) or `res` |
| `--filter` | No | Filter pattern for FBX filenames (also filters textures and materials) |
| `--high-quality-textures` | No | Use BPTC compression for higher quality textures |
| `--mesh-scale` | No | Scale factor for mesh output (e.g., `100` for undersized packs) |
| `--output-subfolder` | No | Subfolder path prepended to pack folder names |
| `--retain-subfolders` | No | Preserve Source_Files/FBX/ subdirectory structure in mesh output |
| `--blender` | No | Path to Blender executable for headless FBX-to-GLB export |
| `--animated-to-glb` | No | Convert character/animation FBX files to GLB before Godot import |

## Godot Skeleton Retargeting

Use Godot's importer to standardize both the character and the mannequin animation sources to the same `SkeletonProfileHumanoid`. This is the correct workflow for Godot 4.4/4.6.

For `SF_Characters.fbx`, this repo now also includes a Godot addon at `addons/synty_import_helper` that can apply the known-good character import preset and attach a post-import fixer script automatically.

### 1. Import the character as a scene

1. Copy `SF_Characters.fbx` into your Godot project.
2. Select it in the FileSystem dock.
3. In the Import tab, set **Import As** to **Scene**.
4. Click **Advanced...**.
5. In the scene tree on the left, select the imported `Skeleton3D`.
6. In the **Retarget** section on the right:
   1. Create or assign a `BoneMap`.
   2. Set **Skeleton Profile** to `SkeletonProfileHumanoid`.
   3. Click **Auto Mapping**.
   4. Manually fix any red or magenta mappings before continuing.
7. In **Bone Renamer**:
   1. Enable **Rename Bones**.
   2. Enable **Unique Node** so the imported skeleton path is standardized.
8. In **Rest Fixer**:
   1. Enable **Overwrite Axis**.
   2. Enable **Apply Node Transform** if the imported skeleton has a non-identity node transform.
   3. Enable **Fix Silhouette** only if the model is clearly in A-pose or otherwise off from the humanoid reference pose.
9. Leave **Remove Tracks** options off for the character scene import.
10. Click **Reimport**.

### 2. Import each animation file as an animation library

1. Copy one animation file into the project, for example `*.glb`.
2. Select it in the FileSystem dock.
3. In the Import tab, set **Import As** to **Animation Library**.
4. Click **Advanced...**.
5. Select the imported `Skeleton3D`.
6. In the **Retarget** section:
   1. Assign a `BoneMap`.
   2. Set **Skeleton Profile** to `SkeletonProfileHumanoid`.
   3. Click **Auto Mapping**.
   4. Manually fix any bad mappings.
7. In **Bone Renamer**:
   1. Enable **Rename Bones**.
   2. Enable **Unique Node**.
8. In **Remove Tracks**:
   1. Enable **Except Bone Transform**.
   2. Enable **Unimportant Positions**.
   3. Enable **Unmapped Bones**.
9. In **Rest Fixer**:
   1. Enable **Overwrite Axis**.
   2. Enable **Normalize Position Tracks**.
   3. Enable **Apply Node Transform** if needed.
   4. Enable **Fix Silhouette** only when the source is not already close to the humanoid reference pose.
10. Click **Reimport**. Godot will generate an animation library resource for that file.

### 3. Load the animation library onto the character

1. Open the imported character scene.
2. Make sure it has an `AnimationPlayer`.
3. In the Animation panel, use **Manage Animations -> Load Library**.
4. Choose the imported mannequin animation library resource.
5. Play a few clips and confirm the pose, feet, and root motion look sane.

### Recommended first test

1. Import `SF_Characters.fbx` as a scene.
2. Import one file such as `Rig_Medium_General.glb` as an animation library.
3. Get one clip working before importing the rest of the mannequin packs.

### Troubleshooting

1. If limbs twist or point the wrong way, check **Overwrite Axis** first.
2. If the whole skeleton is offset or rotated, try **Apply Node Transform**.
3. If the model is in A-pose and the animation expects T-pose, try **Fix Silhouette**.
4. If the animation changes body shape strangely, make sure **Unimportant Positions** is enabled on the animation library import.
5. If sharing still fails, check the `BoneMap` warnings and fix every unmapped critical humanoid bone before reimporting.

## Output Structure

```
output/
  project.godot              # Godot project with global shader uniforms
  shaders/                   # 7 community drop-in shaders
  conversion_log.txt         # Append-mode log for all pack conversions
  PackName/
    textures/                # Extracted textures
    materials/               # Generated .tres ShaderMaterials
    models/                  # Prepared FBX/GLB files (clean paths, structure preserved)
    meshes/                  # Mesh output organized by configuration
      tscn_separate/         # --mesh-format tscn (default, one file per mesh)
      tscn_combined/         # --keep-meshes-together or auto-saved rigged character scenes
      res_separate/          # --mesh-format res (one file per mesh)
      res_combined/          # --mesh-format res --keep-meshes-together
    mesh_material_mapping.json  # Per-pack mesh-to-material mappings
```

**Mesh subfolder naming**: Output goes to `meshes/{format}_{mode}/` based on your options. This allows multiple output configurations to coexist without overwriting each other.

**Rigged GLB scenes**: When `--animated-to-glb` produces a rigged character model with meshes, the converter also saves a combined scene with material overrides in `meshes/tscn_combined/` so skeleton-bearing character scenes are usable without relying on the raw imported GLB materials.

**Multi-pack workflow**: Each pack folder is self-contained with its own `mesh_material_mapping.json`. The `conversion_log.txt` at the project root appends entries from each conversion, making it easy to track multiple pack imports.

**Incremental conversion**: When re-running on a pack that already has `materials/`, `textures/`, `models/`, and `mesh_material_mapping.json`, the converter skips phases 3-10 and only regenerates meshes. This is useful for trying different mesh format/mode combinations without re-processing textures and materials.

## Pipeline Overview

The converter runs a 12-step pipeline:

| Step | Description |
|------|-------------|
| 1 | Validate inputs (package, source files, Godot exe) |
| 2 | Create output directory structure |
| 3 | Extract `.unitypackage` and build GUID maps |
| 4 | Parse Unity `.mat` files |
| 5 | Parse `MaterialList.txt` for mesh-material mappings |
| 6 | Detect shaders via 3-tier system (GUID, name patterns, property analysis) |
| 7 | Generate Godot `.tres` ShaderMaterial files |
| 8 | Copy community shader files (with dynamic path discovery) |
| 9 | Copy textures with smart filtering and fallback resolution |
| 10 | Prepare model files (copy FBX, optionally export character/animation assets to GLB) |
| 11 | Generate per-pack `mesh_material_mapping.json` |
| 12 | Run Godot CLI for mesh-to-scene conversion (with fallback matching) |

See [docs/steps/](docs/steps/README.md) for comprehensive step-by-step documentation.

## Supported Shaders

| Shader | Description |
|--------|-------------|
| Polygon | Standard Synty materials (characters, props, buildings) |
| Foliage | Trees, bushes, grass with wind animation |
| Crystal | Transparent/refractive materials |
| Water | Animated water surfaces |
| Clouds | Volumetric cloud rendering |
| Particles | Unlit particle effects |
| Skydome | Sky gradient and sun rendering |

These use community shaders from [GodotShaders.com](https://godotshaders.com) as drop-in replacements.

## Material Matching

The converter uses a comprehensive fallback system to match meshes to materials:

1. **Exact match** - Direct mesh name lookup in `mesh_material_mapping.json`
2. **SK_/SM_ prefix swap** - Tries both prefixes when one fails
3. **Suffix stripping** - Removes `_LOD0`, `_LOD1`, `_Low`, `_High`, etc.
4. **Prefix removal** - Strips `PolygonPack_Mat_` prefixes
5. **Name variations** - Generates all combinations of above transformations
6. **Fuzzy matching** - Levenshtein distance <= 2 as last resort

This handles naming inconsistencies between Unity prefabs and Godot mesh imports.

## GUI Features

The GUI (`gui.py`) provides:
- Real-time conversion progress with percentage and ETA
- Detailed logging with warning/error highlighting
- **Settings persistence** - Paths and options are saved between sessions
- Dry-run mode for previewing conversions

## Documentation

| Document | Description |
|----------|-------------|
| [Pipeline Steps](docs/steps/README.md) | Comprehensive 12-step pipeline documentation |
| [GUI Documentation](docs/steps/gui.md) | CustomTkinter GUI wrapper |
| [Architecture](docs/architecture.md) | Technical architecture |
| [Shader Reference](docs/shader-reference.md) | Godot shader parameters |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and solutions |
| [API Reference](docs/api/index.md) | Module API documentation |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

This converter tool is provided for use with legally purchased Synty Studios assets. The shaders are licensed under their respective GodotShaders.com licenses.
