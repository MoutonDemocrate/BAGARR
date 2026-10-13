@tool
class_name BoneStretch2D
extends SkeletonModification2D

## Stretches a Bone2D and cancels the scale on its direct children, so only the
## bone's own length changes. Children keep their original size and simply get
## pushed outwards, which is what a stretched limb should do.
##
## Put this modification BEFORE the TwoBoneIK one in the stack: the solver reads
## bone lengths as length * MIN(abs(global_scale.x), abs(global_scale.y)), so it
## will solve with the stretched length if the scale is already written.

## Path to the bone to stretch, relative to the Skeleton2D.
@export var bone_path : NodePath :
	set(value):
		bone_path = value
		_cache()

## Stretch factor. 1.0 is the rest length.
@export_range(0.05, 4.0, 0.01, "or_greater") var stretch : float = 1.0

## Optional. Name of a float property on the Skeleton2D node to read the stretch
## from instead of the value above. Keyframing a plain node property in the
## animation editor is far easier than reaching into a nested resource.
@export var driver_property : StringName = &""

var _skeleton : Skeleton2D
var _bone : Bone2D
var _base_scales : Dictionary = {}

func _setup_modification(modification_stack : SkeletonModificationStack2D) -> void:
	_skeleton = modification_stack.get_skeleton()
	_cache()
	set_is_setup(true)

func _execute(_delta : float) -> void:
	if _bone == null :
		_cache()
		if _bone == null :
			return

	var s := maxf(0.01, _read_stretch())
	var inv := 1.0 / s

	# Uniform scale on purpose: a non-uniform scale would be ignored by the
	# solver's MIN() and would shear any rotated child.
	_bone.scale = _base_scales[_bone] * s

	for child in _bone.get_children() :
		if child is Node2D and _base_scales.has(child) :
			(child as Node2D).scale = _base_scales[child] * inv

func _read_stretch() -> float:
	if driver_property == &"" or _skeleton == null :
		return stretch

	var value : Variant = _skeleton.get(driver_property)
	if value is float or value is int :
		return float(value)

	return stretch

# Scales are written absolutely from these bases every frame, so nothing
# accumulates and stretch = 1.0 restores the rest pose exactly.
func _cache() -> void:
	_bone = null
	_base_scales.clear()

	if _skeleton == null or bone_path.is_empty() :
		return

	_bone = _skeleton.get_node_or_null(bone_path) as Bone2D
	if _bone == null :
		return

	_base_scales[_bone] = _bone.rest.get_scale()
	for child in _bone.get_children() :
		if child is Bone2D :
			_base_scales[child] = (child as Bone2D).rest.get_scale()
		elif child is Node2D :
			_base_scales[child] = (child as Node2D).scale
