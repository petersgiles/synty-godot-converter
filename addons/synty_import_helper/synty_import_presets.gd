@tool
extends RefCounted

const SF_CHARACTERS_IMPORT_SCRIPT_PATH := "res://addons/synty_import_helper/sf_characters_post_import.gd"
const SF_CHARACTERS_LIBRARY_SCRIPT_PATH := "res://addons/synty_import_helper/sf_character_library.gd"
const SF_CHARACTERS_SKELETON_NODE_PATH := "PATH:SF_Character/Skeleton3D"
const SF_CHARACTERS_SKELETON_NAME := "Skeleton"
const SF_CHARACTERS_SOURCE_NAME := "SF_Characters.fbx"

const SF_CHARACTERS_BONE_MAP := {
	"Hips": "Hips_jnt",
	"Spine": "Spine_jnt",
	"Chest": "Spine_jnt_2",
	"UpperChest": "Chest_jnt",
	"Neck": "Neck_jnt",
	"Head": "Head_jnt",
	"LeftShoulder": "Shoulder_Left_jnt",
	"LeftUpperArm": "Arm_Left_jnt",
	"LeftLowerArm": "Forearm_Left_jnt",
	"LeftHand": "Hand_Left_jnt",
	"RightShoulder": "Shoulder_Right_jnt",
	"RightUpperArm": "Arm_Right_jnt",
	"RightLowerArm": "Forearm_Right_jnt",
	"RightHand": "Hand_Right_jnt",
	"LeftUpperLeg": "UpperLeg_Left_jnt",
	"LeftLowerLeg": "LowerLeg_Left_jnt",
	"LeftFoot": "Foot_Left_jnt",
	"LeftToes": "Toe_Left_jnt",
	"RightUpperLeg": "UpperLeg_Right_jnt",
	"RightLowerLeg": "LowerLeg_Right_jnt",
	"RightFoot": "Foot_Right_jnt",
	"RightToes": "Toe_Right_jnt",
}

const SF_CHARACTER_MESH_NAMES := [
	"SF_Character_Bard",
	"SF_Character_Bartender",
	"SF_Character_Doctor",
	"SF_Character_Elf",
	"SF_Character_Elf_Assassin",
	"SF_Character_Elf_Female",
	"SF_Character_Elf_King",
	"SF_Character_Elf_Knight",
	"SF_Character_Executioner",
	"SF_Character_GoblinFemale",
	"SF_Character_GoblinKing",
	"SF_Character_GoblinWarrior",
	"SF_Character_GoblinWitchDoctor",
	"SF_Character_Goblin_01",
	"SF_Character_Jester",
	"SF_Character_King",
	"SF_Character_Knight_01",
	"SF_Character_Knight_02",
	"SF_Character_Knight_03",
	"SF_Character_Knight_Dark",
	"SF_Character_Knight_Gladiator_Closed",
	"SF_Character_Knight_Gladiator_Open",
	"SF_Character_Knight_Heavy_01",
	"SF_Character_Knight_Heavy_02",
	"SF_Character_Knight_Hood",
	"SF_Character_Knight_ShieldMaiden",
	"SF_Character_Knight_Templar",
	"SF_Character_Knight_TinMan",
	"SF_Character_PeasantMan_01",
	"SF_Character_PeasantWoman_01",
	"SF_Character_Princess",
	"SF_Character_Undead_Footman_01",
	"SF_Character_Undead_Footman_02",
	"SF_Character_Undead_Heavy",
	"SF_Character_Undead_King",
	"SF_Character_Undead_Rogue",
	"SF_Character_Undead_Skeleton",
	"SF_Character_Wizard",
	"SF_Characters_GoblinHunter",
]


static func create_sf_characters_bone_map() -> BoneMap:
	var bone_map := BoneMap.new()
	bone_map.profile = SkeletonProfileHumanoid.new()
	for profile_bone_name in SF_CHARACTERS_BONE_MAP.keys():
		bone_map.set_skeleton_bone_name(
			StringName(profile_bone_name),
			StringName(SF_CHARACTERS_BONE_MAP[profile_bone_name])
		)
	return bone_map


static func apply_sf_characters_import_preset(resource_path: String) -> void:
	var import_path := resource_path + ".import"
	var config := ConfigFile.new()
	var load_result := config.load(import_path)
	if load_result != OK:
		push_error("Failed to load import config: %s" % import_path)
		return

	config.set_value("params", "import_script/path", SF_CHARACTERS_IMPORT_SCRIPT_PATH)
	config.set_value("params", "skins/use_named_skins", true)
	config.set_value("params", "nodes/import_as_skeleton_bones", false)

	var subresources: Dictionary = config.get_value("params", "_subresources", {})
	var nodes: Dictionary = subresources.get("nodes", {})
	var skeleton_config: Dictionary = nodes.get(SF_CHARACTERS_SKELETON_NODE_PATH, {})
	skeleton_config["retarget/bone_map"] = create_sf_characters_bone_map()
	skeleton_config["retarget/bone_renamer/unique_node/skeleton_name"] = SF_CHARACTERS_SKELETON_NAME
	nodes[SF_CHARACTERS_SKELETON_NODE_PATH] = skeleton_config
	subresources["nodes"] = nodes
	config.set_value("params", "_subresources", subresources)

	var save_result := config.save(import_path)
	if save_result != OK:
		push_error("Failed to save import config: %s" % import_path)
