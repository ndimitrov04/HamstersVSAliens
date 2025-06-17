extends Panel

@onready var comm_pic = $CommPic
@onready var comm_message = $CommMessage
@onready var comm_notification = $CommNotification
@onready var comm_time = $CommTime

@onready var EVIL_1 = preload("res://Textures/HUD/Portraits/evil1.PNG")
@onready var GOOD_1 = preload("res://Textures/HUD/Portraits/good1.PNG")

var messages_s1 = [
	"General! Sector Charlie E2 Sigma Echo is currently under attack!
	Due to King Parmigano's recent order of 992158152 translucent shiny balls,
	we have no budget to dispatch any units to the sector. Please protect
	it on your own, without any support. Glory to Hamsterland! 
	(This message has been approved by the ministry of shiny round objects.)",
	
	"Greetings, small furry obloid creature!
	We are currently trying to take over your planet.
	Please give up. Our soldiers bruise easily and do not like violence.",
	
	"Attacking people is not nice :(
	Your actions have made our cybernetic overlords sad.
	Please refrain from repeating them in the future.",
	
	"GENERAL! Please finish the mission more quickly,
	Princess Ricotta has a birthday tommorow, you have to
	bake her a cake after you're done. (We have fired all of
	our cooks to accomodate for more hamster balls into our budget).",
	
	"We are sending you a gift of baked pistachios.
	The pistachios are in our red ships, which may be kind of hot.
	Please hug the ships to recieve the gifts.
	Thank you for our cooperation.
	(P.S. There are no micro explosives in the gift).",
	
	"GENERAL! THE ENEMY ARE LIARS, KING PARMIGANO ATE
	THEIR GIFT AND IT DID NOT TASTE GOOD!
	THIS IS A CULINARY INSULT TO OUR COUNTRY. 
	DISPATCH THEM AT ONCE.",
	
	"We have recieved a very angry message from your king's
	personal consultant and are concerned about his mental health.
	We are sending a fleet of around 10 ships full of behavioural therapists
	to help manage his anger issues.",
	
	"GENERAL! I've had a nice chat with enemy general Pinky Longneck.
	I think that I will resign from this position, since it
	has been quite stressful lately. I'm just a hamster.",
	
	"GENERAL! Why are there still enemies in the sky? We have to
	bake that cake, or Queen Mozzarella will throw me to the
	cats again!",
	
	"Dear Diary, After meeting with the king of Hamsterland 
	I have been having weird feelings about Princess Ricotta.
	I think I am in love.
	Wait WAIT WAIT, STOP WRITING TO THE COMMUNICATION SYSTEM. 
	DELETE! DELETE! DELETE REQUEST! STOP! TERMINATE CONNECTION!",
	
	"GENERAL! Did you get that last message? Spicy ^^.
	The king got the message too and broadcasted it
	to our citizens. Popular polls say that they want
	to read enemy general Pinky Longneck's diary.
	Please make seizing his diary a top priority (after baking the cake)",
	
	"Dear hamster general and protector of hamsterland,
	my communicator was hacked by enemy forces (not yours, 
	other enemy forces (you wouldn't know them,
	they are not from this galaxy)).
	Please disregard all previous messages.
	Also my little brother ran over my keyboard.
	My little brother is a cat.",
	
	"GENERAL! THE KING HAS EXPLODED! THIS IS A SEVERE EMERGENCY! 
	HELP! HELP! PANIC!",
	
	"It's over for you rodents.
	And you general, prepare to face the hamster
	extermination squad.
	#EvilLaugh #Ratio #DeadKing #HamsterLife
	#MyArmyInBio #NooneAsked #L",
	
	"GENERAL! WE MUST PREVAIL AGAINST THIS BARBARIC PINKY LONGNECK!
	YOU DESTROY HIS ENDLESS WAVES OF SPACESHIPS AND I WILL
	RATIO HIM ON HAMWITTER! #FORTHEKING",
]



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_comms(current_wave):
	if current_wave < 15: 
		show()
		comm_time.start()
		comm_notification.play()
		
		comm_message.text = messages_s1[current_wave]
		
		match current_wave:
			0:
				comm_pic.texture = GOOD_1
			1:
				comm_pic.texture = EVIL_1
			2:
				comm_pic.texture = EVIL_1
			3:
				comm_pic.texture = GOOD_1
			4:
				comm_pic.texture = EVIL_1
			5:
				comm_pic.texture = GOOD_1
			6:
				comm_pic.texture = EVIL_1
			7:
				comm_pic.texture = GOOD_1
			8:
				comm_pic.texture = GOOD_1
			9:
				comm_pic.texture = EVIL_1
			10:
				comm_pic.texture = GOOD_1
			11:
				comm_pic.texture = EVIL_1
			12:
				comm_pic.texture = GOOD_1
			13:
				comm_pic.texture = EVIL_1
			14:
				comm_pic.texture = GOOD_1

func _on_comm_time_timeout():
	hide()
