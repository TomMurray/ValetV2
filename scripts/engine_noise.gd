extends Node3D
class_name EngineNoise

@onready var player : AudioStreamPlayer3D = %AudioStreamPlayer3D

var sample_hz = 22050.0
var time : float = 0.0
var playback : AudioStreamGeneratorPlayback = null

@export var noise_gen : Noise

func db_to_amp(db : float) -> float:
	return pow(10, db / 20.0)

class WaveGenerator:
	var time : float = 0.0
	var phase_offset : float = 0.0
	var freq : float = 1.0:
		set(value):
			# Adjust the offset so that time + offset results in
			# the same phase offset into the new frequency
			var curr_phase := fmod(time + phase_offset, 1/freq) * freq
			var zero_phase := fmod(time, 1/value) * value
			phase_offset = fmod(curr_phase - zero_phase + 1.0, 1.0) / value
			freq = value
			
	func _init(freq_ : float, phase_offset_ = 0.0):
		freq = freq_
		phase_offset = phase_offset_
		
	func get_phase():
		return fmod(time + phase_offset, 1/freq) * freq

class SineWaveGenerator extends WaveGenerator:
	func _init(freq_ : float, phase_offset_ = 0.0):
		super(freq_, phase_offset_)
	
	func sample(time_ : float):
		time = time_
		return sin(get_phase() * TAU)

class SawWaveGenerator extends WaveGenerator:
	func _init(freq_ : float, phase_offset_ = 0.0):
		super(freq_, phase_offset_)
	
	func sample(time_ : float):
		time = time_
		return lerpf(1.0, 0.0, get_phase())

class SquareWaveGenerator extends WaveGenerator:
	func _init(freq_ : float, phase_offset_ = 0.0):
		super(freq_, phase_offset_)
	
	func sample(time_ : float):
		time = time_
		return 1.0 if get_phase() < 0.5 else 0.0

class SineWaveQuadStortGenerator extends WaveGenerator:
	func _init(freq_ : float, phase_offset_ = 0.0):
		super(freq_, phase_offset_)
	
	func sample(time_ : float):
		time = time_
		return sin(Utils.quad_ease(get_phase()) * TAU)

var base_gen = SawWaveGenerator.new(50.0)
var lfo1_gen = SineWaveGenerator.new(5.0)
var lfo2_gen = SquareWaveGenerator.new(20.0)
var lfo3_gen = SawWaveGenerator.new(15.0)
var harm1_gen = SineWaveGenerator.new(100.0)
var harm2_gen = SineWaveGenerator.new(120.0)
var harm3_gen = SineWaveQuadStortGenerator.new(600.0)
var harm4_gen = SawWaveGenerator.new(400.0)
var harm4_gen2 = SawWaveGenerator.new(400.0, 0.002)

var accel : float = 0.0:
	set(value):
		accel = value
		base_gen.freq = 50.0 * lerpf(1.0, 3.0, accel)
		lfo1_gen.freq = 5.0 * lerpf(1.0, 1.5, accel)
		lfo2_gen.freq = 20.0 * lerpf(1.0, 1.5, accel)
		lfo3_gen.freq = 15.0 * lerpf(1.0, 5.0, accel)
		harm1_gen.freq = 100.0 * lerpf(1.0, 2.0, accel)
		harm2_gen.freq = 120.0 * lerpf(1.0, 1.1, accel)
		harm3_gen.freq = 600.0 * lerpf(1.0, 1.05, accel)

func _fill_buffer():
	var to_fill = playback.get_frames_available()
	for i in range(0, to_fill):
		var frame_time : float = time + (i / sample_hz)
		var sample = 0.0
		
		var base_freq : float = 50.0
		
		# Basic tone
		sample += base_gen.sample(frame_time) * db_to_amp(lerpf(-28.0, -24.0, accel))
		
		# LFOs
		var lfo1 = lfo1_gen.sample(frame_time)
		var lfo2 = lfo2_gen.sample(frame_time)
		var lfo3 = lfo3_gen.sample(frame_time)
		
		# Some harmonics
		sample += harm1_gen.sample(frame_time) * lfo3 * db_to_amp(lerpf(-24.0, -18.0, accel))
		sample += harm2_gen.sample(frame_time) * db_to_amp(-24.0)
		sample += harm3_gen.sample(frame_time) * lfo2 * db_to_amp(lerpf(-42.0, -36.0, accel))
		
		# Combine phase shifted harmonic
		var harm4_sample = (harm4_gen.sample(frame_time) + harm4_gen2.sample(frame_time)) / 2
		sample += harm4_sample * db_to_amp(lerpf(-64.0, -32.0, accel))
		
		# LFO one for modulation
		sample *= lfo1
		
		# Add in some noise
		var noise := noise_gen.get_noise_1d(frame_time)
		sample += noise * lfo3 * db_to_amp(lerpf(-24.0, -18.0, accel))
		
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
	generator.buffer_length = 0.2
	player.play()
	playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	_fill_buffer()

func _process(delta):
	_fill_buffer()
	
