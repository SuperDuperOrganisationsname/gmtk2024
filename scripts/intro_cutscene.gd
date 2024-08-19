extends Control

var left_bubble_text: Array[String] = [
	"Oh ****!",
	"We still need a story for this garbage.",
	"...",
	"Let's just say you play as ... uhhh ...",
	"...",
	"You thought about this one, didn't you?",
	"Ok sure, what is the SCALEMASTER doing here?",
	"Makes sense... but what does this have to do with the theme?",
	"... he made his talisman thingy that can scale the universe right?",
	"So one could argue that it was BUILD TO SCALE...",
	"...",
]

var right_bubble_text: Array[String] = [
	"What?",
	"...",
	"OH ****!",
	"... the SCALEMASTER, bender of Space itself!",
	"...", 
	"Maybe a little...",
	"Maybe some eldritch horror stole his pancakes or something. They are incomprehesable. That explains, why we didn't animate it.",
	"Uhhhh.... ",
	"Yeah?",
	"...",
	"I hate you..."
]

@onready var left_bubble_label = $SpeechBubbleLeft/Label
@onready var right_bubble_label = $SpeechBubbleRight/Label
@onready var right_bubble_node = $SpeechBubbleRight
var left_text_index = 0
var right_text_index = 0
var update_left_bubble = true

func update_bubbles() -> void:
	if right_text_index == right_bubble_text.size():
		get_tree().change_scene_to_file("res://scenes/game.tscn")	
		return

	if update_left_bubble:
		left_bubble_label.text = left_bubble_text[left_text_index]
		update_left_bubble = false
		left_text_index += 1
	else:
		if !right_bubble_node.visible:
			right_bubble_node.visible = true
		right_bubble_label.text = right_bubble_text[right_text_index]
		update_left_bubble = true
		right_text_index += 1

func _ready() -> void:
	left_bubble_label.text = ""
	right_bubble_label.text = ""
	right_bubble_node.visible = false
	left_text_index = 0
	right_text_index = 0
	update_bubbles()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		update_bubbles()
	if Input.is_action_just_pressed("open_pause_menu"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")
