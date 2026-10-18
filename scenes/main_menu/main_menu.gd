extends MarginContainer
class_name MainMenu

@export_group("Nodes")
@export var title_label: Label
@export var short_desc_label: Label
@export var long_desc_label: Label
@export_subgroup("Buttons")
@export var classic_button: Button
@export var custom_button: Button
@export var settings_button: Button
@export var quit_button: Button

func _ready() -> void:
	classic_button.grab_focus()

	classic_button.focus_entered.connect(update_descs.bind(classic_button))
	custom_button.focus_entered.connect(update_descs.bind(custom_button))
	settings_button.focus_entered.connect(update_descs.bind(settings_button))
	quit_button.focus_entered.connect(update_descs.bind(quit_button))

	quit_button.pressed.connect(get_tree().root.free)


func update_descs(button:Button) -> void:
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(short_desc_label, "visible_ratio", 0.0, 0.2)
	tween.tween_property(long_desc_label, "visible_ratio", 0.0, 0.2)
	await tween.finished

	match button :
		classic_button :
			short_desc_label.text = "Just the Classics™"
			long_desc_label.text = "Player with the regular character kits, and punch your way to victory.\n\nEasy, balanced, simple."

		custom_button :
			short_desc_label.text = "Mix and Match !"
			long_desc_label.text = "Assemble a character from parts, and prove your vision is the better one.\n\nMay not be balanced : : who cares ?"

		settings_button :
			short_desc_label.text = "The World is yours."
			long_desc_label.text = "Change language, graphics, audio, accessibility..."

		quit_button :
			short_desc_label.text = "So soon ?"
			long_desc_label.text = "We will miss you. "

	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_property(short_desc_label, "visible_ratio", 1.0, 0.2)
	tween.tween_property(long_desc_label, "visible_ratio", 1.0, 0.2)
