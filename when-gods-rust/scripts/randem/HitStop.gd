extends Node

var _time_left := 0.0
var _restore_scale := 1.0
var _last_tick := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func request(duration: float, stop_scale: float = 0.05) -> void:
	if duration <= 0.0:
		return

	if _time_left <= 0.0:
		_restore_scale = Engine.time_scale

	_time_left = maxf(_time_left, duration)
	Engine.time_scale = minf(_restore_scale, stop_scale)
	_last_tick = Time.get_ticks_usec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _time_left <= 0.0:
		return
	
	var now = Time.get_ticks_usec()
	_time_left -= float(now - _last_tick) / 1000000.0
	_last_tick = now
	
	if _time_left <= 0.0:
		_time_left = 0
		Engine.time_scale = _restore_scale
