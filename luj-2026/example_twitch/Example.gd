@icon("res://assets/placeholders/twitch_michinko1.svg")
extends Control

@export var client_id : String = "gultqtjz4ufcfhlsrlvbsvhbko9frw" #nota, cambiar cuando exporte el proyecto final
@export var channel : String
@export var username : String

#var nombre_temporal = "probando"
var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection

var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()
var iconloader : TwitchIconDownloader

func _ready() -> void:
	Global.boton_twitch_presionado.connect(_on_button_conectar_con_twitch_pressed)

func hello(cmd_info : CommandInfo) -> void:
	irc.chat("Hello World!")

func list(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	irc.chat(", ".join(arg_ary))

func on_event(type : String, data : Dictionary) -> void:
	match(type):
		"channel.follow":
			print("%s followed your channel!" % data["user_name"])

func send_message() -> void:
	irc.chat(%LineEdit.text)
	%LineEdit.text = ""

func put_chat(senderdata : SenderData, msg : String):
	return
	#var bottom : bool = %ChatScrollContainer.scroll_vertical == %ChatScrollContainer.get_v_scroll_bar().max_value - %ChatScrollContainer.get_v_scroll_bar().get_rect().size.y
	#var label : RichTextLabel = RichTextLabel.new()
	#var time = Time.get_time_dict_from_system()
	#label.fit_content = true
	#label.selection_enabled = true
	#label.push_font_size(12)
	#label.push_color(Color.WEB_GRAY)
	#label.add_text("%02d:%02d " % [time["hour"], time["minute"]])
	#label.pop()
	#label.push_font_size(14)
	#var badges : Array[Texture2D]
	#for badge in senderdata.tags["badges"].split(",", false):
		#label.add_image(await(iconloader.get_badge(badge, senderdata.tags["room-id"])), 0, 0, Color.WHITE, INLINE_ALIGNMENT_CENTER)
	#label.push_bold()
	#if (senderdata.tags["color"] != ""):
		#label.push_color(Color(senderdata.tags["color"]))
	#label.add_text(" %s" % senderdata.tags["display-name"]) #aca esta el username de quien mando un mensaje, esto usarlo para diferenciar cada personaje
##	nombre_temporal =senderdata.tags["display-name"] #IMPORTANTISIMO, aca se guarda el nombre del usuario para usarse en funciones como join
	#label.push_color(Color.WHITE)
	#label.push_normal()
	#label.add_text(": ")
	#var locations : Array[EmoteLocation] = []
	#if (senderdata.tags.has("emotes")):
		#for emote in senderdata.tags["emotes"].split("/", false):
			#var data : PackedStringArray = emote.split(":")
			#for d in data[1].split(","):
				#var start_end = d.split("-")
				#locations.append(EmoteLocation.new(data[0], int(start_end[0]), int(start_end[1])))
	#locations.sort_custom(Callable(EmoteLocation, "smaller"))
	#if (locations.is_empty()):
		#label.add_text(msg)
	#else:
		#var offset = 0
		#for loc in locations:
			#label.add_text(msg.substr(offset, loc.start - offset))
			#label.add_image(await(iconloader.get_emote(loc.id)), 0, 0, Color.WHITE, INLINE_ALIGNMENT_CENTER)
			#offset = loc.end + 1
	#%Messages.add_child(label)
	#await(get_tree().process_frame)
	#if (bottom):
		#%ChatScrollContainer.scroll_vertical = %ChatScrollContainer.get_v_scroll_bar().max_value

class EmoteLocation extends RefCounted:
	var id : String
	var start : int
	var end : int

	func _init(emote_id, start_idx, end_idx):
		self.id = emote_id
		self.start = start_idx
		self.end = end_idx

	static func smaller(a : EmoteLocation, b : EmoteLocation):
		return a.start < b.start


func conexion_exitosa_esconder_botones():
	print("CONEXION EXITOSA")
	Global.twitch_conectado.emit(true)
	#$CanvasLayer.hide() #agregar los botones restantes al final
	#$AudioSonido.play()

func conexion_fallida_mostrar_botones():
	print("CONEXION FALLIDA")
	Global.twitch_conectado.emit(false)
	#$CanvasLayer.show()
	#$AudioErrorYaUnido.play() #solo debug
#-----######-------------------- COMANDOS DEL CHAT ---------------------------######----------


func probando(cmd_info : CommandInfo):
	print("SE ESCRIBIO EL MENSAJE PROBANDO EN EL CHAT, SI VES ESTO ENTONCES FUNCIONA!!!")

func acariciar(cmd_info : CommandInfo):
	var nombre_usuario : String = cmd_info.sender_data.user
	#var tags = cmd_info.sender_data.tags
	#var color = tags["color"]
	print("ACARICIAR A MICHINKO OWWWWWWWWWWW")
	Global.acariciar_desde_twitch.emit(nombre_usuario)




#----------#########------------FIN COMANDOS DEL CHAT --------------##########--------------

func _on_button_conectar_con_twitch_pressed() -> void:
#	$CanvasLayer.hide() #temporal
	var auth : ImplicitGrantFlow = ImplicitGrantFlow.new()
	get_tree().process_frame.connect(auth.poll) 

	var token : UserAccessToken = await(auth.login(client_id, ["chat:read", "chat:edit"])) #aca estan los scopes
	print("TOKEN VALE: ", token)
	if (token == null):
		# Authentication failed. Abort.
		return

	id = TwitchIDConnection.new(token)
	irc = TwitchIRCConnection.new(id)
	api = TwitchAPIConnection.new(id)
	iconloader = TwitchIconDownloader.new(api)
	var user_info = await id.get_user_info(self) #funcion que agregue
	if user_info != {}:
		print("User ID vale... ", user_info["id"])
		username = user_info["login"]
		channel = user_info["login"]
		print("Login del usuario: ", username)

	get_tree().process_frame.connect(id.poll)

	# Connect to the Twitch chat.
	if(!await(irc.connect_to_irc(username))):
		# Authentication failed. Abort.
		conexion_fallida_mostrar_botones()
		return
	else:
		conexion_exitosa_esconder_botones()
	irc.request_capabilities()
	# Join the channel specified in the exported 'channel' variable.
	irc.join_channel(channel)

	# #####   Agregar comandos, pueden ser personalizados como el de sonido  #####
	cmd_handler.add_command("helloworld", hello)
	cmd_handler.add_command("probando", probando)
	cmd_handler.add_command("acariciar", acariciar)
	cmd_handler.add_alias("helloworld", "hello")
	cmd_handler.add_command("list", list, -1, 1)
	cmd_handler.add_alias("join", "unirse")

	cmd_handler.add_alias("follow", "seguir")
	irc.chat_message.connect(put_chat)

	# We also have to forward the messages to the command handler to handle them.
	irc.chat_message.connect(cmd_handler.handle_command)
	# If you also want to accept whispers, connect the signal and bind true as the last arg.
	irc.whisper_message.connect(cmd_handler.handle_command.bind(true))

	# When we press enter on the chat bar or press the send button, we want to execute the send_message
	# function.
	%LineEdit.text_submitted.connect(send_message.unbind(1))
	%Button.pressed.connect(send_message)
	print("**** Conectado correctamente al canal ", channel)
	# This part of the example only works if GIFT is logged in to your broadcaster account.
	# If you are, you can uncomment this to also try receiving follow events.
	# Don't forget to also add the 'moderator:read:followers' scope to your token.
#	eventsub = TwitchEventSubConnection.new(api)
#	await(eventsub.connect_to_eventsub())
#	eventsub.event.connect(on_event)
#	var user_ids : Dictionary = await(api.get_users_by_name([username]))
#	if (user_ids.has("data") && user_ids["data"].size() > 0):
#		var user_id : String = user_ids["data"][0]["id"]
#		eventsub.subscribe_event("channel.follow", "2", {"broadcaster_user_id": user_id, "moderator_user_id": user_id})
