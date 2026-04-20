import json
import sys
from pathlib import Path

import bpy


def load_manifest(path: Path | None) -> dict:
    if path is None or not path.exists():
        return {"mesh_materials": {}, "materials": {}}
    return json.loads(path.read_text(encoding="utf-8"))


def get_or_create_image_material(
    material_name: str,
    texture_path: str | None,
    material_cache: dict[str, bpy.types.Material],
) -> bpy.types.Material:
    cached = material_cache.get(material_name)
    if cached is not None:
        return cached

    material = bpy.data.materials.get(material_name)
    if material is None:
        material = bpy.data.materials.new(name=material_name)
    material.use_nodes = True
    material.use_backface_culling = False

    nodes = material.node_tree.nodes
    links = material.node_tree.links
    nodes.clear()

    output = nodes.new(type="ShaderNodeOutputMaterial")
    output.location = (300, 0)
    bsdf = nodes.new(type="ShaderNodeBsdfPrincipled")
    bsdf.location = (0, 0)
    bsdf.inputs["Roughness"].default_value = 1.0
    links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])

    if texture_path:
        image_path = Path(texture_path)
        if image_path.exists():
            tex_node = nodes.new(type="ShaderNodeTexImage")
            tex_node.location = (-300, 0)
            tex_node.image = bpy.data.images.load(str(image_path), check_existing=True)
            links.new(tex_node.outputs["Color"], bsdf.inputs["Base Color"])
            if "Alpha" in tex_node.outputs and "Alpha" in bsdf.inputs:
                links.new(tex_node.outputs["Alpha"], bsdf.inputs["Alpha"])
                material.blend_method = "HASHED"
                material.shadow_method = "HASHED"

    material_cache[material_name] = material
    return material


def resolve_mesh_materials(obj: bpy.types.Object, manifest: dict) -> list[str]:
    mesh_materials = manifest.get("mesh_materials", {})
    return (
        mesh_materials.get(obj.name)
        or mesh_materials.get(obj.data.name)
        or []
    )


def apply_material_manifest(manifest: dict) -> None:
    material_defs = manifest.get("materials", {})
    material_cache: dict[str, bpy.types.Material] = {}

    for obj in bpy.data.objects:
        if obj.type != "MESH" or obj.data is None:
            continue

        material_names = resolve_mesh_materials(obj, manifest)
        if not material_names:
            continue

        mesh_materials = obj.data.materials
        while len(mesh_materials) < len(material_names):
            mesh_materials.append(None)

        for index, material_name in enumerate(material_names):
            material_def = material_defs.get(material_name, {})
            material = get_or_create_image_material(
                material_name,
                material_def.get("texture_path"),
                material_cache,
            )
            mesh_materials[index] = material


def main() -> None:
    argv = sys.argv
    if "--" not in argv:
        raise SystemExit("Expected Blender arguments after --")

    args = argv[argv.index("--") + 1 :]
    if len(args) not in {2, 3}:
        raise SystemExit("Usage: blender --background --python blender_fbx_to_glb.py -- input.fbx output.glb [materials.json]")

    source_fbx = Path(args[0])
    output_glb = Path(args[1])
    manifest_path = Path(args[2]) if len(args) == 3 else None

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=str(source_fbx), automatic_bone_orientation=False)
    apply_material_manifest(load_manifest(manifest_path))

    output_glb.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=str(output_glb),
        export_format="GLB",
        use_visible=True,
        export_apply=False,
        export_yup=True,
        export_animations=True,
        export_animation_mode="ACTIONS",
        export_skins=True,
        export_morph=False,
    )


if __name__ == "__main__":
    main()
