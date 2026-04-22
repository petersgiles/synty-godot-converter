@tool
extends EditorScenePostImport

const Presets := preload("res://addons/synty_import_helper/synty_import_presets.gd")
const CharacterLibraryScript := preload("res://addons/synty_import_helper/sf_character_library.gd")


func _post_import(scene: Node) -> Object:
	var root := scene as Node3D
	if root == null:
		push_warning("SF_Characters post-import expected a Node3D root.")
		return scene

	root.name = "SF_Characters"
	root.set_script(CharacterLibraryScript)

	var skeleton := _find_main_skeleton(root)
	if skeleton == null:
		push_warning("No Skeleton3D found while importing %s" % get_source_file())
		return scene

	skeleton.name = Presets.SF_CHARACTERS_SKELETON_NAME
	_normalize_meshes(root, skeleton)
	_validate_character_meshes(skeleton)
	root.set_meta("synty_character_mesh_names", Presets.SF_CHARACTER_MESH_NAMES)

	return scene


func _find_main_skeleton(root: Node) -> Skeleton3D:
	var expected := root.get_node_or_null("SF_Character/Skeleton3D") as Skeleton3D
	if expected != null:
		return expected
	return root.find_child("Skeleton3D", true, false) as Skeleton3D


func _normalize_meshes(root: Node, skeleton: Skeleton3D) -> void:
	var meshes := _collect_meshes(root)
	for mesh in meshes:
		if not _is_under_skeleton(mesh, skeleton):
			mesh.reparent(skeleton, true)
		mesh.skeleton = NodePath("..")
		mesh.visible = false


func _collect_meshes(node: Node) -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		meshes.append(node as MeshInstance3D)
	for child in node.get_children():
		meshes.append_array(_collect_meshes(child))
	return meshes


func _is_under_skeleton(node: Node, skeleton: Skeleton3D) -> bool:
	var current := node.get_parent()
	while current != null:
		if current == skeleton:
			return true
		current = current.get_parent()
	return false


func _validate_character_meshes(skeleton: Skeleton3D) -> void:
	var found_names: Dictionary = {}
	for child in skeleton.get_children():
		var mesh := child as MeshInstance3D
		if mesh != null:
			found_names[mesh.name] = true

	for mesh_name in Presets.SF_CHARACTER_MESH_NAMES:
		if not found_names.has(mesh_name):
			push_warning("Expected character mesh missing after import: %s" % mesh_name)

