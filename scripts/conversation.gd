class_name Conversation

static func play(timeline: String, fox: Player, partner: BaseCharacter = null) -> void:
	if not is_instance_valid(fox) or fox.is_talking or Dialogic.current_timeline != null:
		return    # already talking - a second press of F
	fox.start_talk(partner)
	if is_instance_valid(partner) and partner.has_method("start_talk"):
		partner.call("start_talk", fox)
	# F picks the focused choice too, not only Enter / Space.
	Dialogic.Choices.use_input_action = true
	Dialogic.start(timeline)
	await Dialogic.timeline_ended
	# A stage change ends the dialogue too: by then the fox may be gone.
	if is_instance_valid(fox):
		fox.finish_talk()
	if is_instance_valid(partner) and partner.has_method("finish_talk"):
		partner.call("finish_talk")
