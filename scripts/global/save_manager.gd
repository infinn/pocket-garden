extends Node

const SAVE_PATH = "user://save_data.json"

var user_data = {
	"player_name": "anon",
	"money": 5,
	"highscore": 0,
	"score_sum": 0,
	"seed": {
		"twin_sunflower": false,
		"reapeter": false,
		"tall_nut": false
	},
	"config":
		{
			"music":true,
			"direction":0,
			"scale":1
		}
}

func _ready():
	user_data = get_user_data()
	Global.money = user_data["money"]

func get_user_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		save_data() 
		return user_data
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		var loaded_data = json.data
		for key in loaded_data.keys():
			user_data[key] = loaded_data[key]
		return user_data
	else:
		return user_data

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(user_data, "\t")
	file.store_string(json_string)
	file.close()
