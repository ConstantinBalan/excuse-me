extends Control

# Labels
@onready var severity_modifier: RichTextLabel = %StatusOfSeverityModifier
@onready var category_modifier: Label = %StatusOfCategoryModifier
@onready var keywords_matched: Label = %NumberOfMatchedKeyWords

# Containers
@onready var severity_container: VBoxContainer = %SeverityContainer
@onready var category_container: VBoxContainer = %CategoryContainer
@onready var keywords_container: VBoxContainer = %KeywordsContainer

func _ready() -> void:
	severity_container.hide()
	category_container.hide()
	keywords_container.hide()
	connect_signals()
	hide()
	

func connect_signals():
	GameSignals.severity_result.connect(severity_show)
	GameSignals.category_result.connect(category_show)
	GameSignals.keywords_result.connect(keywords_show)
	

func severity_show(val: float) -> void:
	show()
	severity_modifier.text = ""
	severity_container.show()
	await get_tree().create_timer(1.0).timeout
	if val > 0.0:
		severity_modifier.text = "[wave amp=50.0 freq=5.0 connected=1][color=green]+%.2f[/color][/wave]" % val
	if val == 0.0:
		severity_modifier.text = "[shake rate=20.0 level=5 connected=1]+%.2f[/shake]" % val
	if val < 0.0:
		severity_modifier.text = "[shake rate=50.0 evel=5 connected=1][color=red]+%.2f[/color][/shake]" % val

func category_show(val: float) -> void:
	category_modifier.text = ""
	category_container.show()
	await get_tree().create_timer(1.0).timeout
	category_modifier.text = "+%.2f" % val


func keywords_show(val: float) -> void:
	keywords_matched.text = ""
	keywords_container.show()
	await get_tree().create_timer(1.0).timeout
	keywords_matched.text = "+%d" % val


func show_success_check():
	show()
	
	
func hide_sucess_check():
	hide()
