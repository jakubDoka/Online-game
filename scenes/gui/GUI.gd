extends Control

onready var lobby:=$lobby
onready var discButton:=$Button

func _ready() -> void:
	Net.connect("connected",self,"_on_conection_succes")
	Net.connect("disconnected",self,"_on_disconnect")

func _on_conection_succes():
	lobby.hide()
	discButton.text="close server" if get_tree().is_network_server() else "disconnect"
	discButton.rect_position.x+=0
	discButton.rect_position.x=rect_size.x-discButton.rect_size.x
	
	discButton.show()
	

func _on_disconnect():
	lobby.show()
	discButton.hide()

func _on_Button_button_up() -> void:
	Net.restart()
