extends Node

## Second global script to run
##
## it handles reading the JSON files that contain the statistics for plants and zombies.

var plant_data = {}
var zombies_data = {}

func _ready():
	load_json()

func load_json():
	var file = FileAccess.open("res://data/plants.json", FileAccess.READ)
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	
	for p in data:
		plant_data[p["name"]] = p
	
	var file_z = FileAccess.open("res://data/zombies.json", FileAccess.READ)
	var content_z = file_z.get_as_text()
	var data_z = JSON.parse_string(content_z)
	
	for z in data_z:
		zombies_data[z["name"]] = z
