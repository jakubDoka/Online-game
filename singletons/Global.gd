
extends Node

const loopBack:="127.0.0.1"
const defID:="nan"
const defPort:=8910

onready var clientInfoBlueprint:=get_properies(Player.new())

func getPublicIP():
	var req:=HTTPRequest.new()
	add_child(req)
	var error = req.request("https://api.ipify.org")
	if error != OK:
		return null
	return yield(req,"request_completed").back().get_string_from_utf8()

static func init(node:Node,properties:={}) -> void:
	for p in properties:
			node.set(p,properties[p])

static func get_properies(node:Node)->Dictionary:
	var res:={}
	for p in node.get_property_list():
		if p.usage==PROPERTY_USAGE_SCRIPT_VARIABLE:
			res[p.name]=node.get(p.name)
	res["name"]=node.name
	return res

func make_bullet(sorce:Mech,bullet:Resource,pos:Vector2,rot:float)->void:
	var b:Bullet=bullet.instance()
	b.init(sorce,pos,rot)
	add_child(b)
