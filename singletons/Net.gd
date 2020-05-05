extends Node

const serverID:=1

var maxPeers:int=10
var address:String=Global.loopBack
var isServer:bool
var player:Player
var clientInfo:Dictionary

signal connected
signal disconnected
signal playerAdded(player)
signal stateChange(state)

onready var playerGroup:=PlayerGroup.new()

onready var peer:NetworkedMultiplayerENet


func _ready() -> void:
	playerGroup.name="pg"
	get_tree().root.call_deferred("add_child",playerGroup)
	
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _exit_tree() -> void:
	restart()


func _client_connected(id:int)->void:
	emit_signal("stateChange","someone connected")
	rpc_id(id,"send_client_data")
	
func _client_disconnected(id:int)->void:
	rpc("remove_client",id)

func _connected_ok()->void:
	emit_signal("stateChange","client connected")

func _connected_fail()->void:
	emit_signal("stateChange","failed to connect")
	restart()

func _server_disconnected()->void:
	emit_signal("stateChange","server disconected")
	restart()

func create_server(clientInfo:Dictionary,port:int)->void:
	restart()
	peer=NetworkedMultiplayerENet.new()
	var err=peer.create_server(port,maxPeers)
	if err!=OK:
		emit_signal("stateChange","unable to create server")
		return
	get_tree().connect("network_peer_connected", self, "_client_connected")
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	get_tree().set_network_peer(peer)
	emit_signal("stateChange","server running")
	register_client(clientInfo,get_tree().get_network_unique_id())
	emit_signal("connected")

func create_client(clientInfo:Dictionary,port:int)->void:
	restart()
	self.clientInfo=clientInfo
	peer=NetworkedMultiplayerENet.new()
	peer.create_client(address,port)
	get_tree().set_network_peer(peer)
	emit_signal("stateChange","client connecting")

func restart()->void:
	if get_tree().is_connected("network_peer_connected", self, "_client_connected"):
		get_tree().disconnect("network_peer_connected", self, "_client_connected")
	if get_tree().is_connected("network_peer_disconnected", self, "_client_disconnected"):
		get_tree().disconnect("network_peer_disconnected", self, "_client_disconnected")
	if peer and peer.get_connection_status()==NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		peer.close_connection(0)
	playerGroup.clear()
	get_tree().set_network_peer(null)
	emit_signal("disconnected")

remotesync func remove_client(id:int)->void:
	var p:=playerGroup.get_by_id(id)
	if not p: return
	playerGroup.remove_player(p)
	emit_signal("stateChange",p.Name+" disconected")
	p.queue_free()

remotesync func register_client(data:Dictionary,id:int)->void:
	var p:=Player.new(id)
	Global.init(p,data)
	if id==get_tree().get_network_unique_id():player=p
	p.set_network_master(id)
	playerGroup.add_player(p)
	emit_signal("stateChange",str(playerGroup.get_ids()))

remote func process_client_data(data:Dictionary)->void:
	var clientId:int=get_tree().get_rpc_sender_id()
#	if playerGroup.get_by_address(data.address):
#		peer.disconnect_peer(clientId)
	for p in playerGroup.get_children():
		rpc_id(clientId,"register_to_client",Global.get_properies(p))
	rpc("register_client",data,clientId)
	rpc_id(clientId,"connected")

remote func register_to_client(data:Dictionary)->void:
	var p:=Player.new()
	Global.init(p,data)
	p.set_network_master(p.id)
	playerGroup.add_player(p)

remote func send_client_data()->void:
	rpc_id(1,"process_client_data",clientInfo)

remote func connected():
	emit_signal("connected")

func get_players()->Array:
	return playerGroup.get_children()
