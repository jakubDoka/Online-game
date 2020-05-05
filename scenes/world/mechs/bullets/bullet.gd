class_name Bullet
extends Area2D

var sorce:Mech
var speed:=700



func init(sorce:Mech,pos:Vector2,rot:float):
	self.sorce=sorce
	position=pos
	rotation=rot

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	position+=Vector2(speed,0).rotated(rotation)*delta

func _on_liveTimer_timeout() -> void:
	queue_free()


func _on_bullet_body_entered(body: Node) -> void:
	if body==sorce:return
	if body is Mech:
		if get_tree().is_network_server():
			body.take_demige(1)
			body.rpc("take_demige",1)
		queue_free()
