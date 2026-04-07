extends RichTextEffect
class_name ShakeEffect

var speed: float = 25.0
var amount: float = 1.5

func _get_effect_name() -> String:
	return "shake"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# char_fx.label jest dostępne automatycznie
	# offset dla każdej litery
	var time = Time.get_ticks_msec() / 1000.0
	
	var offset_x = sin(time * speed + char_fx.absolute_index) * amount
	var offset_y = cos(time * speed * 1.3 + char_fx.absolute_index * 2) * amount
	
	char_fx.offset = Vector2(offset_x, offset_y)
	return true
