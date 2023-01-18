extends Node


onready var audio_bgm_players = []
var bgm_stage = 0
var bgm_fade_iterator = 0
var bgm_fade_step = 0
var miles = 0
var next_bgm = false
var db = 0
export var bgm_fade_steps = 9
var bgm_fade_offset = 70


# Called when the node enters the scene tree for the first time.
func _ready():
	audio_bgm_players.append($AudioStreamPlayer_BGM1)
	audio_bgm_players.append($AudioStreamPlayer_BGM2)
	audio_bgm_players.append($AudioStreamPlayer_BGM3)
	audio_bgm_players.append($AudioStreamPlayer_BGM4)
	audio_bgm_players.append($AudioStreamPlayer_BGM5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if next_bgm:
		if bgm_fade_step > 80+bgm_fade_offset-1:
			next_bgm = false
			bgm_stage += 1
			miles = 0
			bgm_fade_step = 0
			bgm_fade_iterator = 0
		else:
			audio_bgm_players[bgm_stage].volume_db = max(min(-bgm_fade_step+bgm_fade_offset,db),-80)
			audio_bgm_players[bgm_stage+1].volume_db = min(max(bgm_fade_step-80,-80),db)
			bgm_fade_iterator += 1
			if bgm_fade_iterator > bgm_fade_steps:
				bgm_fade_step += 1
				bgm_fade_iterator = 0
	else:
		if miles > 200 and bgm_stage < 4:
			next_bgm = true
	miles += 1
	
