extends Node

## This script preloads all zombies and generates the wave data. 
##
## It works with a dictionary that has three elements: 
## (1) minimum respawn time, 
## (2) maximum respawn time, and 
## (3) wave information, which contains a pool of possible zombies along with their spawn probabilities.

@onready var common: PackedScene = load("res://scenes/characters/zombies/common.tscn")
@onready var conehead: PackedScene = load("res://scenes/characters/zombies/conehead.tscn")
@onready var buckethead: PackedScene = load("res://scenes/characters/zombies/buckethead.tscn")
@onready var football: PackedScene = load("res://scenes/characters/zombies/football.tscn")
@onready var screendoor: PackedScene = load("res://scenes/characters/zombies/doorzombie.tscn")
@onready var polevaulting: PackedScene = load("res://scenes/characters/zombies/polevaulting.tscn")

@onready var wave_info = [
	{
		"min-respawn":5,
		"max-respawn":15,
		"wave-data":[
			{
				"zombie" = common,
				"probability" = 1
			}
		]
	},
	{
		"min-respawn":5,
		"max-respawn":10,
		"wave-data":[
			{
				"zombie" = common,
				"probability" = 0.8
			},
			{
				"zombie" = conehead,
				"probability" = 0.2
			}
		]
	},
	{
		"min-respawn":5,
		"max-respawn":8,
		"wave-data":[
			{
				"zombie" = common,
				"probability" = 0.5
			},
			{
				"zombie" = conehead,
				"probability" = 0.4
			},
			{
				"zombie" = buckethead,
				"probability" = 0.1
			}
		]
	},
	{
		"min-respawn":4,
		"max-respawn":8,
		"wave-data":[
			{
				"zombie" = common,
				"probability" = 0.3
			},
			{
				"zombie" = conehead,
				"probability" = 0.4
			},
			{
				"zombie" = buckethead,
				"probability" = 0.3
			}
		]
	},
	{
		"min-respawn":4,
		"max-respawn":8,
		"wave-data":[
			{
				"zombie" = conehead,
				"probability" = 0.3
			},
			{
				"zombie" = buckethead,
				"probability" = 0.5
			},
			{
				"zombie" = football,
				"probability" = 0.2
			}
		]
	},
	{
		"min-respawn":3,
		"max-respawn":8,
		"wave-data":[
			{
				"zombie" = conehead,
				"probability" = 0.5
			},
			{
				"zombie" = buckethead,
				"probability" = 0.2
			},
			{
				"zombie" = polevaulting,
				"probability" = 0.05
			},
			{
				"zombie" = screendoor,
				"probability" = 0.2
			}
		]
	},
	{
		"min-respawn":2,
		"max-respawn":7,
		"wave-data":[
			{
				"zombie" = conehead,
				"probability" = 0.3
			},
			{
				"zombie" = buckethead,
				"probability" = 0.3
			},
			{
				"zombie" = football,
				"probability" = 0.2
			},
			{
				"zombie" = screendoor,
				"probability" = 0.2
			}
		]
	},
	{
		"min-respawn":4,
		"max-respawn":10,
		"wave-data":[
			{
				"zombie" = buckethead,
				"probability" = 0.3
			},
			{
				"zombie" = football,
				"probability" = 0.3
			},
			{
				"zombie" = screendoor,
				"probability" = 0.4
			}
		]
	},
	{
		"min-respawn":4,
		"max-respawn":7,
		"wave-data":[
			{
				"zombie" = conehead,
				"probability" = 0.5
			},
			{
				"zombie" = buckethead,
				"probability" = 0.2
			},
			{
				"zombie" = polevaulting,
				"probability" = 0.1
			},
			{
				"zombie" = screendoor,
				"probability" = 0.2
			}
		]
	},
	{
		"min-respawn":2,
		"max-respawn":5,
		"wave-data":[
			{
				"zombie" = conehead,
				"probability" = 0.1
			},
			{
				"zombie" = buckethead,
				"probability" = 0.1
			},
			{
				"zombie" = football,
				"probability" = 0.3
			},
			{
				"zombie" = screendoor,
				"probability" = 0.45
			},
			{
				"zombie" = polevaulting,
				"probability" = 0.05
			},
		]
	},
]
