extends Control
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(texture, quantity):
	sprite_2d.texture = load(texture)
	label.text = str(quantity)
