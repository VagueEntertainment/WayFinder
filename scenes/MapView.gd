extends Control

var currentTask = ""
var main_event_marked = []
var cp_marked = []
var event_marked = []
var open_paths_marked = []
var PlayerPositions = []
var marker = preload("res://scenes/mapInfoMaker.tscn")
var event_texture = preload("res://assets/Tex_skill_13.PNG")
var cp_texture = preload("res://assets/Tex_skill_21.PNG")
var path_texture = preload("res://assets/Arrow.png")
#signal skipped()
# Called when the node enters the scene tree for the first time.
func _ready():
	var _error = WayFinder.connect("step_completed",self,"on_step_completed")
	self.rect_size = OS.window_size
	
	pass # Replace with function body.

#func _physics_process(_delta):
#	fill_map()

func fill_map():
	
	var current_player = WayFinder.players[WayFinder.turn -1]
	var playerPos = WayFinder.currentView.get_node("boardBacking/FullBoard").unproject_position(current_player.get_global_transform().origin)
	$PlayerMarker.rect_position = playerPos
	$PlayerMarker.set_info(current_player.info["class"])
	
	for c in WayFinder.map:
		if c["card"].connectors == []:
			for p in open_paths_marked:
				if p["card"] == c["card"]:
					$pathways.remove_child(p["marker"])
					p["marker"].queue_free()
					open_paths_marked.remove(open_paths_marked.find(p))
		else:
			var subset = []
			for i in open_paths_marked:
				if i["card"] == c["card"]:
					subset.append(i)
					
			for s in subset: 
				if !s in c["card"].connectors:
					$pathways.remove_child(s["marker"])
					s["marker"].queue_free()
					open_paths_marked.remove(open_paths_marked.find(s))

		if !str(c["card"]) in str(open_paths_marked):
			if !c["card"].connectors == []:
				for con in c["card"].connectors:
					var themark = marker.instance()
					themark.set_info("")
					themark.set_icon(path_texture)
					themark.rect_scale = Vector2(0.4,0.4)
					$pathways.add_child(themark)
					open_paths_marked.append({"marker":themark,"card":c["card"],"position":con})

		if !str(c["card"]) in str(main_event_marked):
			if c["card"].info["event"] == 4:
				var themark = marker.instance()
				themark.set_info("")
				themark.set_icon(event_texture)
				$markers.add_child(themark)
				main_event_marked.append({"marker":themark,"card":c["card"]})
				
		if !str(c["card"]) in str(cp_marked):
			if c["card"].info["cp"] == true:
				var themark = marker.instance()	
				themark.set_info("")
				themark.set_icon(cp_texture)
				themark.rect_scale = Vector2(0.5,0.5)
				$markers.add_child(themark)
				cp_marked.append({"marker":themark,"card":c["card"]})
				
	for m in main_event_marked:
		
		var cardPos 
		if m["card"].info["event"] == 4:
			cardPos = WayFinder.currentView.get_node("boardBacking/FullBoard").unproject_position(m["card"].get_global_transform().origin)
			m["marker"].rect_position = cardPos
		elif m["card"].info["event"] == 0:
			$markers.remove_child(m["marker"])
			m["marker"].queue_free()
			main_event_marked.remove(main_event_marked.find(m))
	
	for m in cp_marked:
		var cp_cardPos
		if m["card"].info["cp"]:
			cp_cardPos = WayFinder.currentView.get_node("boardBacking/FullBoard").unproject_position(m["card"].get_global_transform().origin)
			m["marker"].rect_position = cp_cardPos - Vector2(20,-20)
			
	for m in open_paths_marked:
		var door_pos = WayFinder.currentView.get_node("boardBacking/FullBoard").unproject_position(m["card"].get_node("Connectors/"+m["position"]).get_global_transform().origin)
		m["marker"].rect_position = door_pos
		match m["position"]:
			"Connector2":
				m["marker"].rect_rotation = 180 
			"Connector3":
				m["marker"].rect_rotation = 90
			"Connector4":
				m["marker"].rect_rotation = -90
			_:
				pass

func set_task(_line):
	#$WFpanel/PlayerControls/CurrentTask/Label.text = line	
	pass

func show_map():

	$AnimationPlayer.play("Show")
	$WFpanel/MapControls/Info/Label.text = WayFinder.players[WayFinder.turn-1].info["class"]
	$WFpanel/MapControls/MapControlsButton.text = "Confirm"
	fill_map()

func hide_map():
	set_texture()
	$AnimationPlayer.play("Hide")

func skip_step():
	if WayFinder.players[WayFinder.turn -1].turnSteps["build"] == false:
		WayFinder.step_complete("build")
		WayFinder.placing = 0
		var movement_msg = ""
		if WayFinder.movement == 1:
			movement_msg = "Move  "+str(WayFinder.movement)+" card"
		else:
			movement_msg = "Move up to "+str(WayFinder.movement)+" cards"
		$Notification/VBoxContainer/Name.text = "Movement Phase"
		$Notification/VBoxContainer/info.text = movement_msg
		$WFpanel/MapControls/MapControlsButton.text = "  Hold  "
		$Notification/AnimationPlayer.play("Grow")
		$WFpanel/MapControls/Hint.text = movement_msg
	else:
		WayFinder.step_complete("move")
		hide_map()
		
		
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Show":
		get_parent().currentView.get_node("boardBacking/FullBoard").make_current()
		var build_msg = ""
		if WayFinder.placing == 1:
			build_msg = "Place "+str(WayFinder.placing)+" card"
		else:
			build_msg = "Place up to "+str(WayFinder.placing)+" cards"
		$WFpanel/MapControls/MapControlsButton.text = "  Confirm  "	
		$Notification/VBoxContainer/Name.text = "Build Phase"
		$Notification/VBoxContainer/info.text = build_msg
		$Notification/AnimationPlayer.play("Grow")
		$WFpanel/MapControls/Hint.text = build_msg
		$pathways.show()
		$markers.hide()
		


func on_step_completed(step):
	#var current_player = WayFinder.players[WayFinder.turn -1]
	if step == "build":
		var movement_msg = ""
		if WayFinder.movement == 1:
			movement_msg = "Move  "+str(WayFinder.movement)+" card"
		else:
			movement_msg = "Move up to "+str(WayFinder.movement)+" cards"
		$Notification/VBoxContainer/Name.text = "Movement Phase"
		$Notification/VBoxContainer/info.text = movement_msg
		$WFpanel/MapControls/MapControlsButton.text = "  Hold  "
		$Notification/AnimationPlayer.play("Grow")
		$WFpanel/MapControls/Hint.text = movement_msg
		$markers.show()
		$pathways.hide()

func _on_MapControlsButton_pressed():
	skip_step()
	pass # Replace with function body.

func _unhandled_key_input(event):
	if visible:
		#var _currentLocal = WayFinder.currentView.get_node("boardBacking/FullBoard").translation
		match event.as_text():
			"Down":
				WayFinder.currentView.get_node("boardBacking/FullBoard").translation += Vector3(0,0,-1)
				$ViewportContainer/Viewport/InterpolatedCamera.transform = WayFinder.currentView.get_node("boardBacking/FullBoard").transform
			"Up":
				WayFinder.currentView.get_node("boardBacking/FullBoard").translation += Vector3(0,0,1)
				$ViewportContainer/Viewport/InterpolatedCamera.transform = WayFinder.currentView.get_node("boardBacking/FullBoard").transform
			"Left":
				WayFinder.currentView.get_node("boardBacking/FullBoard").translation += Vector3(-1,0,0)
				$ViewportContainer/Viewport/InterpolatedCamera.transform = WayFinder.currentView.get_node("boardBacking/FullBoard").transform
			"Right":
				WayFinder.currentView.get_node("boardBacking/FullBoard").translation += Vector3(1,0,0)
				$ViewportContainer/Viewport/InterpolatedCamera.transform = WayFinder.currentView.get_node("boardBacking/FullBoard").transform
		fill_map()


func _on_MapView_visibility_changed():
	if visible:
		var currentHeight = WayFinder.currentView.get_node("boardBacking/FullBoard").translation.y
		var currentX = WayFinder.players[WayFinder.turn -1].translation.x
		var currentz = WayFinder.players[WayFinder.turn -1].translation.z
		WayFinder.currentView.get_node("boardBacking/FullBoard").translation = Vector3(currentX,currentHeight,currentz)
		$ViewportContainer/Viewport/InterpolatedCamera.transform = WayFinder.currentView.get_node("boardBacking/FullBoard").transform
		fill_map()
		if !WayFinder.currentView.is_connected("mapUpdate",self,"fill_map"):
			WayFinder.currentView.connect("mapUpdate",self,"fill_map")

func set_texture():
	var found = false
	var img = $ViewportContainer/Viewport.get_texture()
	for tex in WayFinder.screen_textures:
		if tex["type"] == "map":
			tex["texture"] = img
			#tex["texture"] = get_tree().get_root().get_texture()
			found = true
			break
	if !found:
		#WayFinder.screen_textures.append({"type":"map","texture":get_tree().get_root().get_texture()})
		WayFinder.screen_textures.append({"type":"map","texture":img})
