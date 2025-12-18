class_name AttackCommand
extends Command

var _attacker: Node
var _target: Node
var _damage_amount: int

func _init(attacker: Node, target: Node, amount: int):
	_attacker = attacker
	_target = target
	_damage_amount = amount
	
func _execute_logic() -> void:
	if _target.has_method("get_stats"):
		_target.get_stats().modify_health(-_damage_amount)
		
func _execute_visuals() -> void:
	var tween = _attacker.create_tween()
	
	tween.tween_property(_attacker, "position", _target.position, 0.2)
	
	tween.tween_callback(func():
		EventBus.combat_impact_occurred.emit(_target.global_position, _damage_amount)
	)
	
	tween.tween_property(_attacker, "position", _attacker.postion, 0.2)
	
	tween.finished.connect(func():
		is_finished = true
		finished.emit()
	)
