extends SceneTree

func _run() -> void:
	await create_timer(1.5).timeout
	var enemies: Array[Node] = get_nodes_in_group("Enemy")
	print("REPRO enemies: ", enemies.size())
	if enemies.is_empty():
		print("REPRO abort")
		quit(1)
		return
	var z: Node = enemies.front()
	var ap: AnimationPlayer = z.get_node_or_null("AnimationPlayer")
	print("REPRO anim player path ok: ", ap != null)
	var anim_names: Dictionary = ap.get_animation_names()
	print("REPRO library animations: ", anim_names.size())
	for name: StringName in anim_names:
		var a: Animation = ap.get_animation(name) if anim_names.has(name) else null
		print("REPRO anim ", name, " trackCount=", a.get_track_count(), " length=", a.length)
		for t in range(a.get_track_count()):
			var s: Object = a.get_track(t)
			if s.has_method("get_path"):
				print("REPRO   track", t, " path=\"", s.get_path(0), "\" type=", s.get_track_type())
			else:
				print("REPRO   track", t, " type=", s.get_class())
	print("REPRO forcing play Walk...")
	ap.play("Walk")
	print("REPRO immediately after playing Walk: is_playing=", ap.is_playing(), " current=", ap.get_current_animation())
	await create_timer(1.5).timeout
	print("REPRO after 1.5s walk: is_playing=", ap.is_playing(), " current=", ap.get_current_animation(), " pos=", ap.get_current_playback_position())
	ap.play("Idle")
	await create_timer(1.5).timeout
	print("REPRO after 1.5s idle: is_playing=", ap.is_playing(), " current=", ap.get_current_animation(), " pos=", ap.get_current_playback_position())
	print("REPRO DONE")
	await create_timer(1.5).timeout
	print("REPRO after 1.5s walk: is_playing=", ap.is_playing(), " current_anim=", ap.get_current_animation(), " pos=", ap.get_current_playback_position(), " speed=", ap.get_playback_speed())
	print("REPRO forcing play Idle...")
	ap.play("Idle")
	await create_timer(1.5).timeout
	print("REPRO after 1.5s idle: is_playing=", ap.is_playing(), " current_anim=", ap.get_current_animation(), " pos=", ap.get_current_playback_position(), " speed=", ap.get_playback_speed())
	print("REPRO DONE")
