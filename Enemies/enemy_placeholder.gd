extends Node2D





func _on_area_2d_area_entered(area):
	var collision_layer = area.get_collision_layer()
	print(collision_layer)
