extends Node3D
class_name EngineNoise

@onready var player : AudioStreamPlayer3D = %AudioStreamPlayer3D

var sample_hz = 22050.0
var time : float = 0.0
var playback : AudioStreamGeneratorPlayback = null

@export var noise_gen : Noise

func quad_ease(t : float) -> float:
	var sqr := t * t
	return sqr / (2.0 * (sqr - t) + 1.0)

func db_to_amp(db : float) -> float:
	return pow(10, db / 20.0)

func sine_wave(secs : float, offset : float, freq : float) -> float:
	var phase := fmod(secs + offset, 1/freq) * freq
	return sin(phase * TAU)

func square_wave(secs : float, offset : float, freq : float) -> float:
	var phase := fmod(secs + offset, 1/freq) * freq
	return 1.0 if phase < 0.5 else 0.0

func saw_wave(secs : float, offset : float, freq : float) -> float:
	var phase := fmod(secs + offset, 1/freq) * freq
	return lerp(1.0, 0.0, phase)
	
func sine_wave_quadstort(secs : float, offset : float, freq : float) -> float:
	var phase := fmod(secs + offset, 1/freq) * freq
	return sin(quad_ease(phase) * TAU)

var accel : float = 0.0

func _fill_buffer():
	var to_fill = playback.get_frames_available()
	for i in range(0, to_fill):
		var frame_time : float = time + (i / sample_hz)
		var sample = 0.0
		
		var base_freq : float = 50.0
		
		# Basic tone
		sample += saw_wave(frame_time, 0.1, base_freq) * db_to_amp(-24.0)
		
		# LFOs
		var lfo1 = sine_wave(frame_time, 0.5, 5.0)
		var lfo2 = square_wave(frame_time, 0.0, 20.0)
		var lfo3 = saw_wave(frame_time, 1.5, 15.0)
		
		# Some harmonics
		sample += sine_wave(frame_time, 0.5, base_freq * 2.0) * db_to_amp(-18.0)
		sample += sine_wave(frame_time, 0.5, base_freq * 2.0 + 20.0) * db_to_amp(-24.0)
		sample += sine_wave_quadstort(frame_time, 20.0, base_freq * 12.0) * lfo2 * db_to_amp(-42.0)
		
		# LFO one for modulation
		sample *= lfo1
		
		# Add in some noise
		var noise := noise_gen.get_noise_1d(frame_time)
		sample += noise * lfo3 * db_to_amp(-20.0)
		
		if absf(sample) > 1.0:
			print("Warning, sample exceeds 1.0 amplitude: %f" % sample)
			
		sample = clampf(sample, -1.0, 1.0)
		playback.push_frame(Vector2.ONE * sample)
	time += to_fill / sample_hz

func _ready():
	var generator := player.stream as AudioStreamGenerator
	if sample_hz:
		generator.mix_rate = sample_hz
	else:
		sample_hz = generator.mix_rate
	player.play()
	playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	_fill_buffer()

func _process(delta):
	_fill_buffer()
	
