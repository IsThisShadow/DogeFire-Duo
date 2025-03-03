extends CharacterBody2D
class_name player

signal healthChanged

var direction: Vector2 = Vector2.ZERO

var is_dead = false

@export var maxHealth = 3
@onready var currentHealth: int = maxHealth
@onready var effects = $Effects
@onready var hurtTimer = $hurtTimer

@export var speed: int = 400

var isHurt: bool = false

func _ready():
	effects.play("RESET")

func _process(_delta):
	direction = Input.get_vector("p1_left","p1_right","p1_up","p1_down")


func handleCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		print_debug(collider.name)

func _physics_process(_delta):
	velocity = direction * 400
	move_and_slide()
	handleCollision()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if isHurt: return
	if area.name == "hitBox":
		currentHealth -=1
		if currentHealth < 0:
			currentHealth = maxHealth
			
		
		healthChanged.emit(currentHealth) 
		isHurt = true
		
		effects.play("hurtBlink")
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")
		isHurt = false
