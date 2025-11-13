extends Control

# Labels
@onready var severity_modifier: Label = %StatusOfSeverityModifier
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
	await get_tree().create_timer(1.0).timeout
	print("getting ready to show the columns")
	await get_tree().create_timer(1.0).timeout
	severity_container.show()
	await get_tree().create_timer(3.0).timeout
	category_container.show()
	await get_tree().create_timer(3.0).timeout
	keywords_container.show()
	connect_signals()
	

func connect_signals():
	pass
	

func show_success_check():
	show()
	
	
func hide_sucess_check():
	hide()
