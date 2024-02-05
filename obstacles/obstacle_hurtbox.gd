extends Area2D





func _on_body_entered(body):
	print("zabiłem:",body)
	if get_parent().name == "ArrowsRain":
		get_parent().queue_free()
#	body.queue_free()
