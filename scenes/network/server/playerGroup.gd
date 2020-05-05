class_name PlayerGroup
extends Node

signal added(player)
signal deleted(player)


func add_player(player:Player)->void:
	add_child(player)
	emit_signal("added",player)

func remove_player(player:Player)->void:
	remove_child(player)
	emit_signal("deleted",player)

func get_names()->PoolStringArray:
	var res:PoolStringArray=[]
	for p in get_children():
		res.append(p.Name)
	return res

func get_adreses()->PoolStringArray:
	var res:PoolStringArray=[]
	for p in get_children():
		res.append(p.address)
	return res

func get_by_address(adderss:String)->Player:
	for p in get_children():
		if adderss==p.address: return p
	return null

func get_by_id(id:int)->Player:
	for p in get_children():
		if id==p.id: return p
	return null

func get_ids()->PoolIntArray:
	var res:PoolIntArray=[]
	for p in get_children():
		res.append(p.id)
	return res

func clear()->void:
	for i in get_children():
		i.queue_free()
