extends Spatial

export(float) var TITS = 1.0 setget set_tits
export(float) var TAIL = 1.0 setget set_tail
export(float) var EARS = 1.0 setget set_ears

var tit_l_bone: int
var tit_r_bone: int
var tail_bone: int
var ear_l_bone: int
var ear_r_bone: int

var original_tfs: Dictionary

var is_ready = false

func _ready():
	tit_l_bone = $girlArm/Skeleton.find_bone("tit1.L")
	tit_r_bone = $girlArm/Skeleton.find_bone("tit1.R")
	tail_bone = $girlArm/Skeleton.find_bone("tail1")
	ear_l_bone = $girlArm/Skeleton.find_bone("ear1.L")
	ear_r_bone = $girlArm/Skeleton.find_bone("ear1.R")
	for bone in [tit_l_bone, tit_r_bone, tail_bone, ear_l_bone, ear_r_bone]:
		original_tfs[bone] = get_bone(bone).basis
		print("Bone index: ", bone, ", Bone transform: ", get_bone(bone))
	is_ready = true

func set_tits(value):
	TITS = value
	scale_bone(tit_l_bone, TITS)
	scale_bone(tit_r_bone, TITS)

func set_tail(value):
	TAIL = value
	scale_bone(tail_bone, TAIL)

func set_ears(value):
	EARS = value
	scale_bone(ear_l_bone, EARS)
	scale_bone(ear_r_bone, EARS)

func scale_bone(index, factor):
	if not is_ready:
		return
	var scaling = factor*Vector3.ONE
	var bone = get_bone(index)
	var basis: Basis = original_tfs[index]
	bone.basis = basis.scaled(scaling)
	set_bone(index, bone)

func get_bone(index: int) -> Transform:
	return $girlArm/Skeleton.get_bone_pose(index)

func set_bone(index: int, tf: Transform):
	$girlArm/Skeleton.set_bone_pose(index, tf)
