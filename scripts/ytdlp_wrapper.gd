extends Node

const FILE_NAME = "yt-dlp.exe"
const ZIP_LOCATION : String = "res://resources/yt-dlp.zip"
const LOCATION : String = "user://" + FILE_NAME

enum VideoFormat {
	ORIGINAL,
	MP4,
	MKV,
	AVI,
	WEBM
}

enum VideoQuality {
	MAX,
	_4K,
	_1440P,
	_1080P,
	_720P,
	_480P,
	_240P,
	_144P
}

enum AudioFormat {
	ORIGINAL,
	MP3,
	WAV,
	OGG,
	FLAC
}

enum AudioQuality {
	KBPS_320,
	KBPS_256,
	KBPS_128,
	KBPS_96,
	KBPS_64,
	KBPS_8,
}

var source_dir : String 

func _ready() -> void:
	source_dir = LOCATION
	source_dir = source_dir.replace(FILE_NAME, "")
	
	if FileAccess.file_exists(LOCATION):
		# update ytdlp
		await update_ytdlp()
	
	else:
		File.extract_all_from_zip(ZIP_LOCATION, source_dir)
		
		print("Created " + FILE_NAME + " at " + ProjectSettings.globalize_path(source_dir))
		await update_ytdlp()

func run(args : Array[String], console : bool = false, print_output : bool = false):
	var output : Array = []
	var concatinated_args : String = ""
	for arg : String in args:
		concatinated_args += " " + arg
	
	OS.execute("CMD.exe", ["/C", "cd " + ProjectSettings.globalize_path(source_dir) + " && " + FILE_NAME + concatinated_args], output, false, console)
	if print_output:
		print(str(output[0]))

func update_ytdlp():
	print ("Verifying YT-DLP version...")
	run(["-U"], false, true)

func download_audio(link : String, output_dir : String, file_name: String, format : AudioFormat, quality : AudioQuality):
	pass

func download_video(link : String, output_dir : String, file_name: String, format : VideoFormat, quality : VideoQuality):
	pass
