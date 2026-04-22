# Animations

This documents the animation workflow that actually worked for the Simple Fantasy characters in Godot.

## Working source

The better animation match was not the earlier mannequin exports. The working source library was:

```text
/home/pete/code/synty/animations/Universal Animation Library[Pro]/Unreal-Godot
```

## Working target assets

- Character scene:

```text
/home/pete/code/synty/simple-fantasy/output/retargeted/character.tscn
```

- Imported animation output folder:

```text
/home/pete/code/synty/simple-fantasy/output/retargeted/animations
```

## Goal

Standardize both the character and animation imports to Godot's `SkeletonProfileHumanoid` so the imported animation libraries can be loaded directly onto the character scene.

## Workflow

### Automation available in this repo

There is now a Godot addon in:

```text
addons/synty_import_helper
```

It currently automates the `SF_Characters.fbx` character import side:

1. applies the known-good humanoid `BoneMap`,
2. sets the import post-process script,
3. standardizes the skeleton node name to `Skeleton`,
4. reparents imported character meshes under the main skeleton if needed,
5. hides all character meshes by default,
6. validates that the expected character mesh roster is present.

This addon does **not** yet fully automate the animation-library import settings. Those still use the manual Godot workflow below.

### 1. Import the character scene

Use the character scene:

```text
/home/pete/code/synty/simple-fantasy/output/retargeted/character.tscn
```

If rebuilding or reimporting the character source, keep the skeleton standardized to `SkeletonProfileHumanoid`.

#### Using the addon for `SF_Characters.fbx`

1. Copy:

```text
/home/pete/code/synty/synty-godot-converter/addons/synty_import_helper
```

into your Godot project's `addons/` folder.
2. Enable **Synty Import Helper** in **Project Settings -> Plugins**.
3. Select `SF_Characters.fbx` in the FileSystem dock.
4. Run:

```text
Synty -> Apply SF_Characters humanoid import preset
```

5. The plugin updates the `.import` file and reimports the FBX.
6. After reimport, the imported root gets a helper script that exposes `show_character()` / `hide_all_characters()` behavior on the imported character library scene.

### 2. Copy the animation library into the Godot project

Copy the animation files you want from:

```text
/home/pete/code/synty/animations/Universal Animation Library[Pro]/Unreal-Godot
```

into:

```text
/home/pete/code/synty/simple-fantasy/output/retargeted/animations
```

### 3. Import animation files as Animation Library

For each animation file in `retargeted/animations`:

1. Select the file in Godot.
2. In the **Import** tab, set **Import As** to **Animation Library**.
3. Click **Advanced...**.
4. Select the imported `Skeleton3D`.
5. In **Retarget**:
   1. Create or assign a `BoneMap`.
   2. Set **Skeleton Profile** to `SkeletonProfileHumanoid`.
   3. Click **Auto Mapping**.
   4. Manually fix any important unmapped bones.
6. In **Bone Renamer**:
   1. Enable **Rename Bones**.
   2. Enable **Unique Node**.
7. In **Remove Tracks**:
   1. Enable **Except Bone Transform**.
   2. Enable **Unimportant Positions**.
   3. Enable **Unmapped Bones**.
8. In **Rest Fixer**:
   1. Enable **Overwrite Axis**.
   2. Enable **Normalize Position Tracks**.
   3. Enable **Apply Node Transform** if the source came in rotated or offset.
   4. Enable **Fix Silhouette** only if the animation source pose clearly needs it.
9. Click **Reimport**.

This produces animation library resources that work with the retargeted character.

### 4. Load the imported animation library onto the character

1. Open:

```text
/home/pete/code/synty/simple-fantasy/output/retargeted/character.tscn
```

2. Make sure the scene has an `AnimationPlayer`.
3. In the Animation panel, use **Manage Animations -> Load Library**.
4. Select the animation library resource imported from `retargeted/animations`.
5. Test a few clips.

## Result

This workflow worked well with:

- animations imported from:

```text
/home/pete/code/synty/animations/Universal Animation Library[Pro]/Unreal-Godot
```

- character scene:

```text
/home/pete/code/synty/simple-fantasy/output/retargeted/character.tscn
```

- animation library output folder:

```text
/home/pete/code/synty/simple-fantasy/output/retargeted/animations
```

## Notes

1. This is the preferred workflow over the earlier Blender rebinding attempt.
2. The key is using the same `SkeletonProfileHumanoid` setup on both sides.
3. Start with one animation file first, confirm it plays correctly on `character.tscn`, then batch the rest.
