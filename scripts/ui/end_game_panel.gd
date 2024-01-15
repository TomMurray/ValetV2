extends Panel

@onready var success_controls := [
	%success_text,
	%next_level_button
]

@onready var failure_controls := [
	%failure_text,
	%retry_level_button
]

func _on_level_logic_complete(success):
	# Configure some elements to show or not depending on the outcome
	
	if success:
		for c in success_controls:
			c.show()
	else:
		for c in failure_controls:
			c.show()
	
	# Show the panel
	show()
	
