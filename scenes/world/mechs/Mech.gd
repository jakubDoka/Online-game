class_name Mech
extends KinematicBody2D

export (PackedScene) var bullet

var vel:Vector2
var acc:=20
var twork:=3
var player
var loaded:=true
var nextPos:Vector2
var nextRot:float
var health:=10 setget take_demige

puppet func take_demige(amount:int):
	health-=amount
	$bar.value=health
	if health==0:
		take_demige(-10)
		rpc("take_demige",-10)
	
	
func init(player)->void:
	self.player=player

func _ready() -> void:
	$bar.max_value=health
	$bar.rect_position=-$bar.rect_size/2
	pass

func _process(delta: float) -> void:
	if not is_network_master():
		var dist=position.distance_to(nextPos)
		if dist>30:
			position=nextPos
		else:
			position=position.linear_interpolate(nextPos,dist*delta)
		rotation=nextRot
		if not is_player():
			return
	var inputMap=player.inputMap
	if inputMap["mLeft"]:
		shoot()
		if is_network_master():
			rpc("shoot")
	if inputMap["up"]:
		vel+=Vector2(acc,0).rotated(rotation)
	if inputMap["down"]:
		vel+=Vector2(-acc,0).rotated(rotation)
	if inputMap["right"]:
		rotation+=twork*delta
	if inputMap["left"]:
		rotation-=twork*delta
	vel-=vel*.05
	if position.x>get_viewport_rect().size.x:
		position.x=get_viewport_rect().size.x
		vel.x=-vel.x
	if position.x<0:
		position.x=0
		vel.x=-vel.x
	if position.y>get_viewport_rect().size.y:
		position.y=get_viewport_rect().size.y
		vel.y=-vel.y
	if position.y<0:
		position.y=0
		vel.y=-vel.y
	move_and_slide(vel)
	if is_network_master():
		rpc_unreliable("set_next",position,rotation)
	

puppet func shoot():
	if not loaded: return
	Global.make_bullet(self,bullet,position,(player.mousePos-position).angle())
	loaded=false
	$reload.start()

puppet func set_next(pos:Vector2,rot:float)->void:
	nextPos=pos
	nextRot=rot

func is_player()->bool:
	if not player or get_tree().is_network_server(): return false
	return player.id == get_tree().get_network_unique_id()
	


func _on_reload_timeout() -> void:
	loaded=true
