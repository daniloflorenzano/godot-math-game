extends KinematicBody2D

signal send_destination(destination)
signal damage(amount)

var health: int  = 1
var hitted: bool = false
var velocity = Vector2(-100, 0)
onready var timer := $Timer as Timer
var start_timer = false
var challenge := ""
var answer := ""

func _ready() -> void:
	var game_node = get_tree().root.get_node("Game")
	var enemy_handler_node = get_tree().root.get_node("Game").get_node("EnemyHandler")
	
	game_node.connect("attack_enemie", self, "_on_Game_attack_enemie")
	enemy_handler_node.connect("send_challange_and_answer", self, "_on_EnemyHandler_send_challange_and_answer")
	
	
#############################
# Dinâmica de desafios
# para cada inimigo gerado, um dos desafios deve ser atribuido a ele
# tanto o desafio, quanto a resposta sao recebidos do EnemyHandler
#############################
func _on_EnemyHandler_send_challange_and_answer(recieved_challenge, recieved_answer):
	if (get_node("Label").text.length() == 0): 
		challenge = recieved_challenge
		answer = recieved_answer
		
		get_node("Label").text = challenge
		
		if start_timer:
			timer.start() 


func _on_Game_attack_enemie(input_answer) -> void:
	if input_answer == answer:
		_throw_dart()


func new_dart():
	var dart = preload("res://Scenes/Dart.tscn").instance()
	
	get_tree().root.get_node("Game").add_child(dart)
	dart.position = get_tree().root.get_node("Game").get_node("DartPosition").global_position
	dart.connect("enemy_hitted", self, "_on_Dart_enemy_hitted")

func _throw_dart():
	var enemy_position = $".".global_position
	
	new_dart()
	emit_signal("send_destination", enemy_position)


func _on_Dart_enemy_hitted():
	hitted = true
	health -= 1
	yield(get_tree().create_timer(0.4), "timeout")
	hitted = false
	if health < 1:
		queue_free()

func _physics_process(delta: float) -> void:
	velocity = move_and_slide(velocity)
	
	_set_animation()


func _set_animation() -> void:
	var anim = 'run'
	
	if hitted:
		anim = 'hit'
		velocity.x = 0
	
	else:
		velocity.x = -100
	
	$anim.play(anim)

func _on_Timer_timeout() -> void:
	if $ray_wall.is_colliding():	
		emit_signal("damage", 10)

