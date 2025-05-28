extends Panel

@onready var world_environment = $"../../../WorldEnvironment"

@onready var fullscreen_option = $Fullscreen/FullscreenOption
@onready var v_sync_option = $VSync/VSyncOption
@onready var upscaling_option = $Upscaling/UpscalingOption
@onready var anti_aliasing_option = $"Anti-Aliasing/Anti-AliasingOption"
@onready var global_illumination_option = $GlobalIllumination/GlobalIlluminationOption
@onready var bloom_option = $Bloom/BloomOption
@onready var ambient_occlusion_option = $AmbientOcclusion/AmbientOcclusionOption
@onready var screen_space_reflections_option = $ScreenSpaceReflections/ScreenSpaceReflectionsOption
@onready var screen_space_lighting_option = $ScreenSpaceLighting/ScreenSpaceLightingOption

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	#get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	#get_viewport().screen_space_aa = int(0) as Viewport.ScreenSpaceAA
	#get_viewport().use_taa = false
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_fullscreen_option_item_selected(index):
	if index == 0: # Disabled (default)
		get_tree().root.set_mode(Window.MODE_WINDOWED)
	elif index == 1: # Fullscreen
		get_tree().root.set_mode(Window.MODE_FULLSCREEN)
	elif index == 2: # Exclusive Fullscreen
		get_tree().root.set_mode(Window.MODE_EXCLUSIVE_FULLSCREEN)

func _on_v_sync_option_item_selected(index):
	if index == 0: # Disabled (default)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

func _on_upscaling_option_item_selected(index):
	# Viewport scale mode setting.
	if index == 0: # Bilinear (Fastest)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0 or 2.2.
	elif index == 1: # FSR 1.0 (Fast)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0 or 2.2.
		get_viewport().fsr_sharpness = 1
	elif index == 2: # FSR 2.2 (Fast)
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
		# FSR Sharpness is only effective when the scaling mode is FSR 1.0 or 2.2.
		get_viewport().fsr_sharpness = 1

func _on_anti_aliasing_option_item_selected(index):
	if index == 0: # Disabled (default)
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		get_viewport().screen_space_aa = int(0) as Viewport.ScreenSpaceAA
		get_viewport().use_taa = false
	elif index == 1: # FXAA
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		get_viewport().screen_space_aa = int(1) as Viewport.ScreenSpaceAA
		get_viewport().use_taa = false
	elif index == 2: # TAA
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		get_viewport().screen_space_aa = int(0) as Viewport.ScreenSpaceAA
		get_viewport().use_taa = true
	elif index == 3: # MSAA 2x
		get_viewport().msaa_3d = Viewport.MSAA_2X
		get_viewport().screen_space_aa = int(0) as Viewport.ScreenSpaceAA
		get_viewport().use_taa = false
	elif index == 4: # MSAA 4x
		get_viewport().msaa_3d = Viewport.MSAA_4X
		get_viewport().screen_space_aa = int(0) as Viewport.ScreenSpaceAA
		get_viewport().use_taa = false

func _on_global_illumination_option_item_selected(index):
	if index == 0: # Disabled (default)
		world_environment.environment.sdfgi_enabled = false
	if index == 1: # Low
		world_environment.environment.sdfgi_enabled = true
		RenderingServer.gi_set_use_half_resolution(true)
	if index == 2: # High
		world_environment.environment.sdfgi_enabled = true
		RenderingServer.gi_set_use_half_resolution(false)

func _on_bloom_option_item_selected(index):
	if index == 0: # Disabled (default)
		world_environment.environment.glow_enabled = false
	if index == 1: # Low
		world_environment.environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(false)
	if index == 2: # High
		world_environment.environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(true)

func _on_ambient_occlusion_option_item_selected(index):
	if index == 0: # Disabled (default)
		world_environment.environment.ssao_enabled = false
	if index == 1: # Very Low
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	if index == 2: # Low
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
	if index == 3: # Medium
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
	if index == 4: # High
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
	if index == 5: # Ultra
		world_environment.environment.ssao_enabled = true
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_ULTRA, true, 0.5, 2, 50, 300)

func _on_screen_space_reflections_option_item_selected(index):
	if index == 0: # Disabled (default)
		world_environment.environment.set_ssr_enabled(false)
	elif index == 1: # Low
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(8)
	elif index == 2: # Medium
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(32)
	elif index == 3: # High
		world_environment.environment.set_ssr_enabled(true)
		world_environment.environment.set_ssr_max_steps(56)

func _on_screen_space_lighting_option_item_selected(index):
	if index == 0: # Disabled (default)
		world_environment.environment.ssil_enabled = false
	if index == 1: # Very Low
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
	if index == 2: # Low
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
	if index == 3: # Medium
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
	if index == 4: # High
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)
	if index == 5: # Ultra
		world_environment.environment.ssil_enabled = true
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_ULTRA, true, 0.5, 4, 50, 300)
