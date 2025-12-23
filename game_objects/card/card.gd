class_name Card
extends Control

#@onready var card_image: TextureRect = %CardImage
@onready var card_name: Label = %CardName
@onready var card_cost: Label = %CardCost
@onready var card_flavor_text: Label = %CardFlavorText

@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var drop_area: Area2D = null

@onready var viewport: SubViewport = %CardViewport
@onready var model_holder: Node3D = %ModelHolder
@onready var camera_3d: Camera3D = %Camera3D # Make sure to access your camera
@export var debug_card_data: CardStats # Assign a resource here in Inspector to test!

@export_group("3D Visuals")
@export var tilt_intensity: float = 45.0 # Max rotation angle in degrees
@export var lerp_speed: float = 15.0 # How "snappy" the card feels
var _tween: Tween

@export var card_data: CardStats

signal reparent_requested(which_card_ui: Card)


func _ready():
	#card_image.texture = card_data.card_texture
	card_name.text = card_data.card_name
	card_cost.text = str(card_data.card_cost)
	card_flavor_text.text = card_data.card_flavor_text
	card_state_machine.init(self)
	viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
	set_process(false) # Disable _process to save CPU when not hovering
	
	if debug_card_data:
		print("Found debug card data")
		set_card_visuals(debug_card_data)
	
func _process(delta: float) -> void:
	_process_tilt(delta)
	
func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()
	print("I am hovering the card")
	if _tween:
		_tween.kill()
	_start_tilt_effect()
	
func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()
	_reset_tilt()
	print("I am done hovering the card")

func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	drop_area = area

func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	drop_area = null

func _start_tilt_effect():
# Wake up the GPU: Start rendering this card every frame
	viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ALWAYS
	set_process(true)	
	
func _reset_tilt():
	set_process(false)
	viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ALWAYS
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(model_holder, "rotation_degrees", Vector3.ZERO, 0.4)
	_tween.finished.connect(_on_reset_finished)
	
func _on_reset_finished() -> void:
	viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
		
func _process_tilt(delta: float) -> void:
	# 1. Get mouse position relative to the card's center
	# (0,0) is top-left, so we offset by size/2 to get center-relative coords
	var mouse_pos: Vector2 = get_local_mouse_position()
	var center: Vector2 = size / 2.0
	
	# 2. Normalize values to -1.0 (Left/Top) to +1.0 (Right/Bottom)
	var x_offset: float = (mouse_pos.x - center.x) / center.x
	var y_offset: float = (mouse_pos.y - center.y) / center.y
	
	# 3. Calculate target rotation
	# Note: Mouse X movement rotates around Y axis (Yaw)
	# Note: Mouse Y movement rotates around X axis (Pitch)
	# We negate y_offset because moving mouse DOWN (positive Y) should tilt card UP (negative X rot)
	var target_rot := Vector3(y_offset * tilt_intensity, x_offset * tilt_intensity, 0.0)
	
	# 4. Apply smooth interpolation
	model_holder.rotation_degrees = model_holder.rotation_degrees.lerp(target_rot, lerp_speed * delta)

# Data Injection
func set_card_visuals(card_visual_data: CardStats):
	for child in model_holder.get_children():
		child.queue_free()
	# 1. Load the specific 3D scene for this card
	if card_visual_data.model_path:
		print("Found model path")
		var model_scene = load(card_visual_data.model_path) # You need to add this field to CardStats
		var model_instance = model_scene.instantiate()
		model_holder.add_child(model_instance)
	
	# 3. Render ONCE to generate the static image, then freeze
	viewport.render_target_update_mode = SubViewport.UpdateMode.UPDATE_ONCE
