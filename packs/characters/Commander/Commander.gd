extends Spatial

signal react(type)
signal finish(type)

var hp = 5
var animQueue = []
var shields = false

var weapon = preload("res://packs/characters/gun1.glb")
var lazerbeam = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_retro_laser_beam_002_44337.mp3.ogg")
var shield = preload("res://packs/characters/Effects/sfx/zapsplat_science_fiction_droning_pulsating_force_field_25225.mp3.ogg")

#var theme = "res://packs/characters/Commander/assets/PLPSF-Percussion_80_01.wav"

var command1 = preload("res://packs/characters/Commander/assets/Tex_skill_35.PNG")
var command2 = preload("res://packs/characters/Commander/assets/Tex_skill_94.PNG")
var command3 = preload("res://packs/characters/Commander/assets/Tex_skill_13.PNG")
var commands = [{
	"name":"Double Time",
	"type":"general",
	"cost":2,
	"unlock":"",
	"discription":"All alleys get a 2x multiplier to their movement rolls",
	"effect":{"target":["game","allies"],"view":"ActionView","when":"command","movement":"x2","duration":1},
	"icon": command1
},{
	"name": "Rally",
	"type":"general",
	"cost":3,
	"unlock":"",
	"discription": "Gives all alleys double damage during combat",
	"effect":{"target":["game","allies"],"view":"ActionView","when":"command","combatRoll":2,"duration":1},
	"icon": command2
}]

func get_info():
	var data = {
		"class":name,
		"hp": hp,
		"commands":commands
	}
	return data

func _process(_delta):
	if !$Commander/AnimationPlayer.is_playing() and len(animQueue) > 0:
		if $Commander/AnimationPlayer.has_animation(animQueue[0]):
			$Commander/AnimationPlayer.play(animQueue[0])
		else:
			do_stuff(animQueue[0])
		
func _ready():
# warning-ignore:return_value_discarded
	$Commander/AnimationPlayer.connect("animation_finished",self,"do_stuff")
	#$Commander/AnimationPlayer.play("onBase")
	animQueue.append("deflect")
	animQueue.append("onBase")
	var gun = weapon.instance()
	$Commander/Armature005/Skeleton/BoneAttachment/Empty.add_child(gun)

func action(act):
	match act:
		"start":
			animQueue.append("startCommander")
			#$Commander/AnimationPlayer.play("start")
		"melee":
			animQueue.append("meleeCommander")
			#$Commander/AnimationPlayer.play("melee")
		"range":
			$Timer.start()
			$sfx.stream = lazerbeam
			animQueue.append("rangedCommander")
			#$Commander/AnimationPlayer.play("ranged")
		"hit":
			animQueue.append("hitCommander")
			#$Commander/AnimationPlayer.play("hit")
		"block":
			$sfx.stream = shield
			animQueue.append("blockCommander")
			shields = true
			$sfx.play()
			#$Commander/AnimationPlayer.block("block")
		"drop":
			animQueue.append("deflectCommander")
			shields = false
			$sfx.stop()
		"win":
			animQueue.append("winCommander")
			shields = false
		"loss":
			animQueue.append("lossCommander")
			shields = false

func do_stuff(anim_name):
	if anim_name == "rangedCommander":
		$laserbolt.emitting = false
		$sfx.stop()
	
	if anim_name == "blockCommander":
		emit_signal("react","block")
	if anim_name == "rangedCommander":
		emit_signal("react","ranged")
	if anim_name == "meleeCommander":
		emit_signal("react","melee")
	if anim_name == "winCommander":
		emit_signal("finish","win")
	if anim_name == "lossCommander":
		emit_signal("finish","loss")
	
	animQueue.remove(0)


func _on_Timer_timeout():
	$laserbolt.emitting = true
	$sfx.play()
	$Timer.stop()
	pass # Replace with function body.
