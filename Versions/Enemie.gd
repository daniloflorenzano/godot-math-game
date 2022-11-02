extends KinematicBody2D

signal damage(amount)

var health: int  = 1
var challenge: int = 2*4
var hitted: bool = false
var velocity = Vector2(-100, 0)
onready var timer := $Timer as Timer
var start_timer = false


func _ready() -> void:
	if start_timer:
		timer.start()

func _on_Node2D_attack_enemie(answer) -> void:
	if int(answer) == challenge:
		print('Resposta correta')
		# TODO: criar funcao _throw_arrow() que verifique a colisao da flecha
		# com o inimigo e execute o codigo abaixo
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
		emit_signal("damage", 1)
