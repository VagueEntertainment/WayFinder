extends PanelContainer
signal finished(data)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$AnimationPlayer.stop(true)
	#WayFinder.connect("turn_start",self,"_on_turn_start")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func close_dialog():
	$AnimationPlayer.play_backwards("Show")
	var player = WayFinder.turn -1
	if WayFinder.players[player].turnSteps["build"] == false:
		if WayFinder.placing == 0:
			WayFinder.emit_signal("place_cards",WayFinder.roll_dice())
	else:
		WayFinder.emit_signal("turn_ended")

func _on_CrewLogContinue_pressed():
	close_dialog()

func player_log(playerClass):
	var thelog = WayFinder.currentMission.get_crew_comment(playerClass,WayFinder.mainEvent)
	$WFpanel/MC/VBoxContainer/Title.text = thelog["title"]
	$WFpanel/MC/VBoxContainer/RichTextLabel.theText = thelog["log"]
	$AnimationPlayer.play("Show")

#func _on_turn_start(player):
	
	#player_log(WayFinder.players[player-1].info["class"])
	#pass

#func _unhandled_key_input(event):
#	if get_parent().get_parent().visible and event.as_text() == "Escape":
#		_on_CrewLogContinue_pressed()


func _on_CrewLog_visibility_changed():
	var player = WayFinder.turn -1
	if visible:
		player_log(WayFinder.players[player].info["class"])
	#else:
	#	$WFpanel/MC/VBoxContainer/RichTextLabel.clear()
