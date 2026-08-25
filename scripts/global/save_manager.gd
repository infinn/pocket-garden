extends Node

const SAVE_PATH = "user://save_data.json"

var default_data = {
	"player_name": "anon",
	"money": 5,
	"highscore": 0,
	"score_sum": 0,
	"seed": {
		"twin_sunflower": false,
		"reapeter": false,
		"tall_nut": false,
		"snow_pea": false
	},
	"config":
		{
			"music": true,
			"direction": 0,
			"scale": 1
		},
	"last_version_play": _get_current_version()
}

var user_data = {}

func _ready():
	user_data = load_user_data()
	Global.money = user_data["money"]

func _get_current_version() -> String:
	return ProjectSettings.get_setting("application/config/version", "0.5.0")

func load_user_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		user_data = default_data.duplicate(true)
		user_data["last_version_play"] = _get_current_version()
		save_data()
		return user_data

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		user_data = default_data.duplicate(true)
		user_data["last_version_play"] = _get_current_version()
		save_data()
		return user_data

	var loaded_data = json.data

	_ensure_all_data(loaded_data)

	if loaded_data.get("last_version_play", "") != _get_current_version():
		loaded_data = _migrate_data(loaded_data)

	user_data = loaded_data
	save_data()
	return user_data

func _ensure_all_data(data: Dictionary):
	_merge_missing(default_data, data)

func _merge_missing(defaults: Dictionary, data: Dictionary):
	for key in defaults.keys():
		if not data.has(key):
			data[key] = _duplicate_value(defaults[key])
		elif defaults[key] is Dictionary and data[key] is Dictionary:
			_merge_missing(defaults[key], data[key])

func _duplicate_value(value):
	if value is Dictionary:
		return value.duplicate(true)
	return value

func _migrate_data(old_data: Dictionary) -> Dictionary:
	var new_data = default_data.duplicate(true)
	for key in old_data.keys():
		if not new_data.has(key):
			continue
		if new_data[key] is Dictionary and old_data[key] is Dictionary:
			for sub in old_data[key].keys():
				if new_data[key].has(sub):
					new_data[key][sub] = old_data[key][sub]
		else:
			new_data[key] = old_data[key]
	new_data["last_version_play"] = _get_current_version()
	return new_data

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(user_data, "\t")
	file.store_string(json_string)
	file.close()
