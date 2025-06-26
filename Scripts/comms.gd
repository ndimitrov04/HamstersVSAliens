extends Panel

@onready var main = $"../.."

@onready var comm_pic = $CommPic
@onready var comm_message = $CommMessage
@onready var comm_notification = $CommNotification
@onready var comm_time = $CommTime

@onready var EVIL_1 = preload("res://Textures/HUD/Portraits/evil1.PNG")
@onready var GOOD_1 = preload("res://Textures/HUD/Portraits/good1.PNG")

var messages_s0 = [
	"Hello General! Time for your daily training. Move with WASD. Jump with SPACE. A drone will be sent to your location. Shoot it down with the left mouse button (LMB).",
	"Good job, you've destroyed the enemy and you've gained an upgrade! Hold left ALT and click on whichever upgrade you want to take.",
	"You can hit enemies with your hamster ball to instantly destroy them. The next wave will have a large ship that you will be able to take down easily by crashing into it. To jump higher than usually possible, move fast. The faster you move, the higher you can jump.",
	"The goal of the game is to protect yourself and your towers for 15 waves. If all of your towers are destroyed or you die, you lose.",
	"Maps are large, but you're not alone. You can build various buildings to help you protect your towers. Go near one of the small hills that say *Empty* above them. A menu will open. Hold ALT and click on one of the menu options to build a building where the building spot is.",
	"Moving fast fills up your combo bar. Your combo points can be used to dash with SHIFT or homing attack an enemy that you have locked onto with RIGHT CLICK. The more combo you have, the higher your top speed will be.",
	"To the left of your screen, above the speed gauge, there are two buttons that can be clicked. Those show you all currently discovered enemies and towers.",
	"Next to your speed gauge, there is an OVERHEAT bar. This bar shows you if your weapon is overheating. When it is full, you cannot shoot. Shooting fills that bar up. Moving fast makes it fill up slower than usual. Not shooting makes is cool down.",
	"You can switch weapons with the 1 2 and 3 buttons. Switch to your second weapon. That is a laser with infinite range. It is rather weak, but useful if you cannot get close to your enemy.",
	"Switch to your third weapon with 3. That is a taser which automatically locks onto nearby enemies and zaps them. It has quite a short range but is very useful for destroying large clumps of enemies.",
	"That is all for today. Good luck out there general :)",
	"text here",
	"text here",
	"text here",
	"text here"
]

var messages_s1 = [
	"General! Sector Charlie E2 Sigma Echo is currently under attack! Due to King Parmigano's recent order of 992158152 translucent shiny balls, we have no budget to dispatch any units to the sector. Please protect it on your own, without any support. Glory to Hamsterland! (This message has been approved by the ministry of shiny round objects.)",
	"Greetings, small furry obloid creature! We are currently trying to take over your planet. Please give up. Our soldiers bruise easily and do not like violence.",
	"Attacking people is not nice :( Your actions have made our cybernetic overlords sad. Please refrain from repeating them in the future.",
	"GENERAL! Please finish the mission more quickly, Princess Ricotta has a birthday tommorow, you have to bake her a cake after you're done. (We have fired all of our cooks to accomodate for more hamster balls into our budget).",
	"We are sending you a gift of baked pistachios. The pistachios are in our red ships, which may be kind of hot. Please hug the ships to recieve the gifts. Thank you for our cooperation. (P.S. There are no micro explosives in the gift).",
	"GENERAL! THE ENEMY ARE LIARS, KING PARMIGANO ATE THEIR GIFT AND IT DID NOT TASTE GOOD! THIS IS A CULINARY INSULT TO OUR COUNTRY.  DISPATCH THEM AT ONCE.",
	"We have recieved a very angry message from your king's personal consultant and are concerned about his mental health. We are sending a fleet of around 10 ships full of behavioural therapists to help manage his anger issues.",
	"GENERAL! I've had a nice chat with enemy general Pinky Longneck. I think that I will resign from this position, since it has been quite stressful lately. I'm just a hamster.",
	"GENERAL! Why are there still enemies in the sky? We have to bake that cake, or Queen Mozzarella will throw me to the cats again!",
	"Dear Diary, After meeting with the king of Hamsterland  I have been having weird feelings about Princess Ricotta. I think I am in love. Wait WAIT WAIT, STOP WRITING TO THE COMMUNICATION SYSTEM.  DELETE! DELETE! DELETE REQUEST! STOP! TERMINATE CONNECTION!",
	"GENERAL! Did you get that last message? Spicy ^^. The king got the message too and broadcasted it to our citizens. Popular polls say that they want to read enemy general Pinky Longneck's diary. Please make seizing his diary a top priority (after baking the cake)",
	"Dear hamster general and protector of hamsterland, my communicator was hacked by enemy forces (not yours,  other enemy forces (you wouldn't know them, they are not from this galaxy)). Please disregard all previous messages. Also my little brother ran over my keyboard. My little brother is a cat.",
	"GENERAL! THE KING HAS EXPLODED! THIS IS A SEVERE EMERGENCY!  HELP! HELP! PANIC!",
	"It's over for you rodents. And you general, prepare to face the hamster extermination squad. #EvilLaugh #Ratio #DeadKing #HamsterLife #MyArmyInBio #NooneAsked #L",
	"GENERAL! WE MUST PREVAIL AGAINST THIS BARBARIC PINKY LONGNECK! YOU DESTROY HIS ENDLESS WAVES OF SPACESHIPS AND I WILL RATIO HIM ON HAMWITTER! #FORTHEKING"
]

var messages_s2 = [
	"GENERAL! You must launch a counterattack against the planet of our enemies. We can launch a spaceship to there from our moon. The spaceship has no fuel though (budget cuts). Please survive long enough for the rocket to refuel and come to pick you up.",
	"You may have won the last battle, however you cannot hope to stand alone against our endless legions! Seriously, how are you supposed to win this alone? Only movie and game protagonists can do things like that. Oh wait...",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here"
]

var messages_s3 = [
	"GENERAL! Good work on setting up this forward base on the enemy's planet! Our hamster scientists have supercharged your hamster ball! Your top speed and acceleration are now doubled!",
	"Thanks for coming to your demise on your own, killing you would've been a real hassle if you hadn't come here. *evil laugh*",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here",
	"text here"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func update_comms(current_wave):
	if current_wave < 15: 
		show()
		comm_time.start()
		comm_notification.play()
		
		match main.get_meta("stage"):
			0:
				comm_message.text = messages_s0[current_wave]
			1:
				comm_message.text = messages_s1[current_wave]
			2:
				comm_message.text = messages_s2[current_wave]
			3:
				comm_message.text = messages_s3[current_wave]
		
		if main.get_meta("stage") == 1:
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
		elif main.get_meta("stage") == 2:
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
		elif main.get_meta("stage") == 3:
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
