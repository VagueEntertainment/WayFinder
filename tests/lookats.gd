extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	$Camera.look_at($MeshInstance.translation,Vector3(0,1,0))


#func _on_Timer_timeout():
	#$Camera.look_at($MeshInstance.translation,Vector3(0,1,0))
	#pass # Replace with function body.