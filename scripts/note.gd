extends Node3D
class_name Note

@export var main_mesh : MeshInstance3D 
@export var continuous_center : Node3D 
@export var continuous_mesh : MeshInstance3D

var has_duration : bool

func create_note(duration : float, velocity : float):
	#main_mesh.visible =  true
	has_duration = duration > 0
	continuous_center.visible = has_duration
	if has_duration:
		continuous_center.scale.z = duration * velocity
	
	main_mesh.set_surface_override_material(0, StandardMaterial3D.new())
	continuous_mesh.set_surface_override_material(0, StandardMaterial3D.new())
	

func display_hit():
	main_mesh.visible =  false	
	
func end_hit():
	continuous_mesh.visible = false
	#var material : StandardMaterial3D = continuous_mesh.get_active_material(0)
	#material.albedo_color = Color.GRAY
	#continuous_mesh.set_surface_override_material(0, material)

func display_mistake():
	#animation_player.play("mistake")
	
	var material : StandardMaterial3D = main_mesh.get_active_material(0)
	material.albedo_color = Color.BLACK
	main_mesh.set_surface_override_material(0, material)
	if has_duration:
		continuous_mesh.set_surface_override_material(0, material)
	#
	#if has_duration:
		#var cont_material : StandardMaterial3D = continuous_mesh.get_active_material(0)
		#cont_material.albedo_color = Color.BLACK
		#continuous_mesh.set_surface_override_material(0, cont_material)
