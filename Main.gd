extends Control

#Data is saved in %appdata% > SignupApp in Account.json
var savePath = "user://Accounts.json"
var file = File.new()
var LoginAttempt = 0
var isSwitch : bool = false
var Accounts = {
	"Users": [],
	"Pass": []
}
var symbols = " /!@#$%^&*{}[]()_-+<>:|?'\""

func _ready() -> void:
	load_data()
	$Switch.connect("pressed",self, "OnSwitch")
	$Login/LoginButton.connect("pressed", self, "OnLoginAttempt")
	$Register/RegisterButton.connect("pressed", self, "OnRegisterAttempt")


func OnLoginAttempt() -> void:
	$ErrorMSG.visible = false
	if (LoginAttempt > 5):
		#Add a timer to reset login attempt
		MSGError("Too many Attempts try again later")
		return
	Login()

func OnRegisterAttempt() -> void:
	$ErrorMSG.visible = false
	for users in Accounts["Users"]:
		if $Register/Username.text.to_lower() == users.to_lower():
			MSGError("USERNAME ALREADY REGISTERED")
			return
	if $Register/Username.text == "" || $Register/Password.text == "":
		MSGError("Username or Password Can't be left Empty")
		return
	if $Register/Username.text.length() < 4:
		MSGError("Username Must be at least 4 characters long")
		return
	for chars in symbols:
		if  chars in $Register/Username.text:
			MSGError("Username Cannot contain Symbols")
			return
	if $Register/Password.text.length() > 8:
		MSGSucessful("Account Successfully Registered")
		Register()
	else:
		MSGError("Password Must be at least 8 characters")



func Login() -> void:
	var UserID = Accounts["Users"].find($Login/Username.text.to_lower())
	var UserPass = Accounts["Pass"].find($Login/Password.text.sha256_text())
	if Accounts["Users"][UserID].to_lower() == $Login/Username.text.to_lower() && UserID != -1 && UserID == UserPass:
		MSGSucessful("Logged in Successfully")
	else:
		LoginAttempt += 1
		MSGError("Username or Password is Incorrect")

func Register() -> void:
	Accounts["Users"].append($Register/Username.text.to_lower())
	Accounts["Pass"].append($Register/Password.text.sha256_text())
	save_data()
	

func MSGSucessful(Text : String) -> void:
	$ErrorMSG.visible = true
	$ErrorMSG.text = Text
	$ErrorMSG.add_color_override("font_color", "ffffff")
	
func MSGError(Text : String) -> void:
	$ErrorMSG.visible = true
	$ErrorMSG.text = Text
	$ErrorMSG.add_color_override("font_color", "ff0000")

func OnSwitch() -> void:
		$ErrorMSG.visible = false
		isSwitch = !isSwitch
		$Login.visible = !isSwitch
		$Register.visible = isSwitch
		if !isSwitch:
			$Switch.text = "Create an Account"
		else:
			$Switch.text = "Back to Login"

func save_data():
	file.open(savePath, File.WRITE)
	file.store_line(to_json(Accounts))
	file.close()
	print(OS.get_user_data_dir())

func load_data():
	if file.file_exists(savePath):
		file.open(savePath, File.READ)
		Accounts = parse_json(file.get_as_text())
