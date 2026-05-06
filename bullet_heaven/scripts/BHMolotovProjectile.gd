extends Area2D

const BHExplosionScript = preload("res://bullet_heaven/scripts/BHExplosion.gd")

var direction: Vector2 = Vector2.UP
var speed: float = 220.0
var damage: int = 1
var explosion_damage: int = 3
var explosion_radius: float = 84.0
var explosion_lifetime: float = 1.4
var max_distance: float = 430.0
var travelled_distance: float = 0.0
var lifetime_after_explosion: float = 0.01
var anchor_ref: Node2D = null
var exploded: bool = false
var glow_phase: float = 0.0

func get_damage() -> int:
	return damage

func _ready() -> void:
	collision_layer = 3
	collision_mask = 1
	add_to_group("bh_player_attack")

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	collision.shape = shape
	add_child(collision)

	var body := ColorRect.new()
	body.size = Vector2(16.0, 16.0)
	body.position = Vector2(-8.0, -8.0)
	body.color = Color(0.95, 0.35, 0.1, 1.0)
	add_child(body)

	var flame := ColorRect.new()
	flame.size = Vector2(8.0, 8.0)
	flame.position = Vector2(-4.0, -4.0)
	flame.color = Color(1.0, 0.82, 0.35, 0.95)
	add_child(flame)
	queue_redraw()

func _draw() -> void:
	if exploded:
		return
	var outer_alpha := 0.2 + 0.08 * (0.5 + 0.5 * sin(glow_phase))
	var inner_alpha := 0.26 + 0.1 * (0.5 + 0.5 * cos(glow_phase * 1.35))
	draw_circle(Vector2.ZERO, 18.0, Color(1.0, 0.45, 0.14, outer_alpha))
	draw_circle(Vector2.ZERO, 10.5, Color(1.0, 0.75, 0.3, inner_alpha))

func _process(delta: float) -> void:
	if exploded:
		lifetime_after_explosion -= delta
		if lifetime_after_explosion <= 0.0:
			queue_free()
		return

	var step := direction.normalized() * speed * delta
	position += step
	rotation = direction.angle()
	glow_phase += delta * 12.0
	queue_redraw()
	travelled_distance += step.length()
	if travelled_distance >= max_distance:
		_explode()

func _explode() -> void:
	if exploded:
		return
	exploded = true
	visible = false
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false

	var explosion := BHExplosionScript.new()
	explosion.damage = explosion_damage
	explosion.radius = explosion_radius
	explosion.lifetime = explosion_lifetime
	explosion.anchor_ref = anchor_ref
	if get_parent() != null:
		get_parent().add_child(explosion)
		explosion.global_position = global_position
