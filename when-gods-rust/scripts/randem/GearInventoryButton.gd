class_name GearInventoryButton
extends Button


var gear: GearData

func _get_drag_data(at_position: Vector2) -> Variant:
	if gear == null:
		return null
	
	var preview = Label.new()
	preview.text = gear.gear_name
	set_drag_preview(preview)
	
	return {"gear": gear}
