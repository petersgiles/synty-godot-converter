@tool
extends EditorPlugin

const Presets := preload("res://addons/synty_import_helper/synty_import_presets.gd")

const MENU_APPLY_CHARACTER_PRESET := "Synty/Apply SF_Characters humanoid import preset"


func _enter_tree() -> void:
	add_tool_menu_item(MENU_APPLY_CHARACTER_PRESET, _apply_sf_characters_preset)


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_APPLY_CHARACTER_PRESET)


func _apply_sf_characters_preset() -> void:
	var selected_paths := get_editor_interface().get_selected_paths()
	var reimport_paths := PackedStringArray()

	for path in selected_paths:
		if not path.to_lower().ends_with(".fbx"):
			continue
		if path.get_file() != Presets.SF_CHARACTERS_SOURCE_NAME:
			continue
		Presets.apply_sf_characters_import_preset(path)
		reimport_paths.append(path)

	if reimport_paths.is_empty():
		push_warning("Select one or more SF_Characters.fbx files in the FileSystem dock.")
		return

	get_editor_interface().get_resource_filesystem().reimport_files(reimport_paths)
	print("Applied Synty humanoid import preset to %d file(s)." % reimport_paths.size())
