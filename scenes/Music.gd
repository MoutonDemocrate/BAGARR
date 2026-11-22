extends AudioStreamPlayer

func _ready() -> void:
	bus = &"Music"

func play_stream(audio_stream:AudioStream) -> void:
	self.stream = audio_stream
	self.play()

func play_from_path(path:String) -> void:
	play_stream(load(path))
