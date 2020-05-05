class_name Player
extends Node

remotesync var Name:="noname"
var address:String=Global.loopBack
var mechName:String
var id:int
var mech:Mech
var inputMap:Dictionary
var mousePos:Vector2

func _init(id:=1) -> void:
	self.id=id
	name=str(id)

func _ready() -> void:
	set_process(is_network_master())
	mech=load("res://scenes/world/mechs/"+mechName+".tscn").instance()
	mech.init(self)
	mech.set_network_master(1)
	mech.name=name
	mech.position=Vector2(200,200)
	add_child(mech)
	for i in InputMap.get_actions():
		inputMap[i]=false

func _process(delta: float) -> void:
	var pos:=mech.get_global_mouse_position()
	mousePos=pos
	rpc("sync_mouse",pos)

func _unhandled_input(event: InputEvent) -> void:
	if not is_network_master() : return
	for i in inputMap:
		if event.is_action(i):
			inputMap[i]=event.is_pressed()
			if get_tree().is_network_server(): return
			rpc_id(Net.serverID,"handle_input",i,event.is_pressed())

puppet func sync_mouse(pos:Vector2)->void:
	mousePos=pos

puppet func handle_input(action:String,pressed:bool):
	inputMap[action]=pressed
	Net.emit_signal("stateChange","{} just {} {}".format(
		[Name,"pressed" if pressed else "released",action],"{}"))
