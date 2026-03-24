extends Control

const YTDLP_FILE_NAME = "yt-dlp.exe"
const YTDLP_ZIP_LOCATION : String = "res://resources/yt-dlp.zip"
const YTDLP_LOCATION : String = "user://" + YTDLP_FILE_NAME

var source_dir : String 

func _ready() -> void:
	source_dir = YTDLP_LOCATION
	source_dir = source_dir.replace("yt-dlp.exe", "")
	
	if FileAccess.file_exists(YTDLP_LOCATION):
		# update ytdlp
		await update_ytdlp()
	
	else:
		File.extract_all_from_zip(YTDLP_ZIP_LOCATION, source_dir)
		
		print("Created " + YTDLP_FILE_NAME + " at " + ProjectSettings.globalize_path(source_dir))
		
		await update_ytdlp()

func update_ytdlp():
	print ("Verifying YT-DLP version...")
	run_ytdlp_command(["-U"], false, true)


func run_ytdlp_command(args : Array[String], console : bool = false, print_output : bool = false):
	var output : Array = []
	var concatinated_args : String = ""
	for arg : String in args:
		concatinated_args += " " + arg
	
	OS.execute("CMD.exe", ["/C", "cd " + ProjectSettings.globalize_path(source_dir) + " && " + YTDLP_FILE_NAME + concatinated_args], output, false, console)
	if print_output:
		print(str(output[0]))
