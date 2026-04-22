@tool
extends Node3D

const Presets := preload("res://addons/synty_import_helper/synty_import_presets.gd")

@export var default_character: String = ""


func _ready() -> void:
	if Engine.is_editor_hint():
		hide_all_characters()
		if not default_character.is_empty():
			show_character(default_character)


func get_character_mesh_names() -> PackedStringArray:
	return PackedStringArray(Presets.SF_CHARACTER_MESH_NAMES)


func get_skeleton() -> Skeleton3D:
	return find_child(Presets.SF_CHARACTERS_SKELETON_NAME, true, false) as Skeleton3D


func get_character_mesh(mesh_name: String) -> MeshInstance3D:
	var skeleton := get_skeleton()
	if skeleton == null:
		return null
	return skeleton.get_node_or_null(mesh_name) as MeshInstance3D


func hide_all_characters() -> void:
	var skeleton := get_skeleton()
	if skeleton == null:
		return
	for child in skeleton.get_children():
		var mesh := child as MeshInstance3D
		if mesh != null:
			mesh.visible = false


func show_character(mesh_name: String) -> bool:
	var mesh := get_character_mesh(mesh_name)
	if mesh == null:
		push_warning("Character mesh not found: %s" % mesh_name)
		return false
	hide_all_characters()
	mesh.visible = true
	return true
