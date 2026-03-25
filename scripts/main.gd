extends Control


const DEFAULT_TITLE_FORMAT = "[title] - [author] ([quality])"
#const DEFAULT_OUTPUT_FOLDER = "%USERPROFILE%/downloads"

const DEFAULT_WINDOWS_SIZE = Vector2i(864, 140)
const SETTINGS_WINDOWS_SIZE = Vector2i(864, 486)
const ANIMATION_SPEED : float = 0.75

@export var selectors : Array[SingleSelectContainer]

@onready var ui_animations: AnimationPlayer = %UIAnimations
@onready var settings_animations: AnimationPlayer = %SettingsAnimations
@onready var link_entry: LineEdit = %LinkEntry
@onready var output_folder: LineEdit = %OutputFolder
@onready var title_format_edit: LineEdit = %TitleFormat
@onready var disable_animations_check: CheckBox = %DisableAnimationsCheck
@onready var audio: Button = %Audio
@onready var video: Button = %Video
@onready var mute: Button = %Mute


var first_press : bool = true
var using_audio : bool = false:
	set(val):
		mute.text = "🔊" if val else "🔈  "
		using_audio = val
	
var using_video : bool = false
var settings_open : bool = false
var output_path : String = ""
var title_format : String = DEFAULT_TITLE_FORMAT
var goin_up : bool 
var disable_animations : bool = false 

func _ready() -> void:
	load_settings()
	get_window().size = SETTINGS_WINDOWS_SIZE
	await get_tree().process_frame
	get_window().size = DEFAULT_WINDOWS_SIZE

func load_settings():
	output_path = File.load_var("output_path", OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS))
	output_folder.text = output_path
	
	title_format = File.load_var("title_format", DEFAULT_TITLE_FORMAT)
	title_format_edit.text = title_format
	
	disable_animations = File.load_var("disable_animations", false)
	disable_animations_check.button_pressed = disable_animations
	
	for selector : SingleSelectContainer in selectors:
		selector.update_button_state(File.load_var(selector.update_id, selector.default_pressed_id))







func _on_audio_pressed() -> void:
	if video.button_pressed and audio.button_pressed and not first_press:
		ui_animations.play("audio_back")
	
	audio.button_pressed = true
	video.button_pressed = false
	mute.button_pressed = false
	
	using_audio = true
	using_video = false
	first_press = false
	
	mute.text = "🔊"



func _on_video_pressed() -> void:
	if video.button_pressed and audio.button_pressed or first_press:
		ui_animations.play("audio")
	
	audio.button_pressed = false
	video.button_pressed = true
	mute.button_pressed = false
	
	using_audio = true
	using_video = true
	first_press = false


func _on_mute_pressed() -> void:
	using_audio = !using_audio

func _on_settings_pressed() -> void:
	var tween : Tween = create_tween()
	
	settings_open = !settings_open
	
	
	if not settings_open:
		tween.set_parallel()
		if goin_up and get_window().position.y > DisplayServer.screen_get_size().y- SETTINGS_WINDOWS_SIZE.y:
			tween.tween_property(get_window(), "position:y", get_window().position.y + SETTINGS_WINDOWS_SIZE.y - 140.0, ANIMATION_SPEED if not disable_animations else 0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		tween.tween_property(get_window(), "size", DEFAULT_WINDOWS_SIZE, ANIMATION_SPEED if not disable_animations else 0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		if not disable_animations:
			ui_animations.play("gear_ccw")
			settings_animations.play("hide")
		else:
			settings_animations.play("hide", -1, 1000.0)
		
		
	else:
		
		
		goin_up = get_window().position.y > DisplayServer.screen_get_size().y- SETTINGS_WINDOWS_SIZE.y
		
		
		
		if goin_up: tween.tween_property(get_window(), "position:y", get_window().position.y - SETTINGS_WINDOWS_SIZE.y + 140.0, ANIMATION_SPEED if not disable_animations else 0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(get_window(), "size", SETTINGS_WINDOWS_SIZE, ANIMATION_SPEED if not disable_animations else 0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		if goin_up and not disable_animations: await Util.wait(ANIMATION_SPEED)
			#tween.tween_property(get_window(), "position:y", SETTINGS_WINDOWS_SIZE.y + 80, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		
		if not disable_animations:
			ui_animations.play("gear_cw")
			settings_animations.play("show")
		else:
			settings_animations.play("show", -1, 1000.0)
	

	#tween.tween_method(DisplayServer.window_set_size, DisplayServer.window_get_size(), SETTINGS_WINDOWS_SIZE, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#get_viewport().set_si


func _on_output_folder_text_submitted(a = null) -> void:
	var new_text : String = output_folder.text
	if DirAccess.dir_exists_absolute(new_text) and new_text != "":
		output_path = new_text
		File.save_var("output_path", new_text)
		print("New output path saved: " + new_text)
	
	else:
		output_folder.text = output_path
		print("Directory does not exist: " + new_text)

func _on_find_file_pressed() -> void:
	var output : Array = await Util.open_file_dialog(self, FileDialog.FileMode.FILE_MODE_OPEN_DIR, [], "last", "Select output folder for media")
	var selected : String = output[0]
	if selected == "": return
	
	output_folder.text = selected
	_on_output_folder_text_submitted()


func _on_title_format_reset_pressed() -> void:
	title_format_edit.text = DEFAULT_TITLE_FORMAT
	_on_title_format_text_submitted()


func _on_title_format_text_submitted(a = null) -> void:
	var new_text : String = title_format_edit.text
	if new_text.is_valid_filename():
		title_format = new_text
		File.save_var("title_format", new_text)
		print("New title format saved: " + new_text)
	
	else:
		title_format_edit.text = title_format
		print("Invalid title format: " + new_text)


func _on_setting_selection_updated(active_button_id: String, update_id: String) -> void:
	File.save_var(update_id, active_button_id)
	print("saved " + update_id + " to " + active_button_id)


func _on_disable_animations_check_toggled(toggled_on: bool) -> void:
	disable_animations = toggled_on
	File.save_var("disable_animations", disable_animations)
