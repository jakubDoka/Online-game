extends Control

onready var Name:=$c/name
onready var address:=$c/addres
onready var state:=$c/state
onready var mechs:=$c/mechs
onready var port:=$c/port


func _ready():
	mechs.add_item("Mech")
	Net.connect("stateChange",self,"set_state")

func set_state(message:String):
	state.text=message

func _on_host_pressed():
	if not port.text.is_valid_integer():
		set_state("poet has to be number")
		return
	Net.create_server(yield(get_info(),"completed"),int(port.text))

func _on_join_pressed():
	if not port.text.is_valid_integer():
		set_state("poet has to be number")
		return
	Net.create_client(yield(get_info(),"completed"),int(port.text))

func get_info()->Dictionary:
	return {
	mechName=mechs.get_item_text(mechs.selected),
	Name=Name.text,
	address=yield(Global.getPublicIP(),"completed"),
	}
func _on_connection_success():
	hide()


func _on_game_ended():
	show()



