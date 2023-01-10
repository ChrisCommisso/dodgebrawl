extends SGKinematicBody2D
export var Velx:int = 0
export var Vely:int = 0
export var airacc:int = 0
export var airspeed:int = 0
export var groundacc:int = 0
export var groundspeed:int = 0
enum ActionState{##the action state is used for the state machine
	Standing,
	Walking,
	Prejumping,
	Jumping,
	Falling,
	AirDodging,
	Rolling,
	Dodging,
	WindUp,
	Release,
	Deflect
}
var prevBallTimer:int = 0
export var ballTimer:int = 0
export var isLeft:bool = false
var CharacterActionState = ActionState.Standing
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var animator:NetworkAnimationPlayer
var raycastNode:SGRayCast2D
var toplay
var animStart:int
func ResolveNeutralAir(var input,var animation):
	if(input['left']==0||input['upleft']==0||input['downleft']==0&&CharacterActionState == ActionState.Falling):
		Velx -= clamp(Velx+airacc,0,airspeed) as int
	elif(input['right']==0||input['upright']==0||input['downright']==0&&CharacterActionState == ActionState.Falling):
		Velx += clamp(Velx+airacc,0,airspeed) as int
	elif(input['B'] == 0 && CharacterActionState == ActionState.Falling):
		if(isLeft):
			CharacterActionState = ActionState.AirDodging
			toplay = "AirDodgeLeft"
			if(ballTimer == 0):
				toplay = "Ball"+toplay
			animStart = SyncManager.current_tick
			animator.Play(toplay)
		else:
			CharacterActionState = ActionState.AirDodging
			toplay = "AirDodgeRight"
			if(ballTimer == 0):
				toplay = "Ball"+toplay
			animStart = SyncManager.current_tick
			animator.Play(toplay)
	elif(input['A'] == 0 && CharacterActionState == ActionState.Falling):
		if(isLeft):
			CharacterActionState = ActionState.WindUp
			toplay = "WindUpLeft"
			if(ballTimer == 0):
				toplay = "Ball"+toplay
			animStart = SyncManager.current_tick
			animator.Play(toplay)
		else:
			CharacterActionState = ActionState.WindUp
			toplay = "WindUpRight"
			if(ballTimer == 0):
				toplay = "Ball"+toplay
			animStart = SyncManager.current_tick
			animator.Play(toplay)
func ResolveNeutralGround(var input,var animation):
	if(input['left']==0&&animation!="WalkLeft"):
		isLeft = true
		CharacterActionState = ActionState.Walking
		toplay = "WalkLeft"
		if(ballTimer == 0):
			toplay = "Ball"+toplay
		animStart = SyncManager.current_tick
		animator.Play(toplay)
	elif(input['right']==0&&animation!="WalkRight"):
		isLeft = false;
		CharacterActionState = ActionState.Walking
		toplay = "WalkRight"
		if(ballTimer == 0):
			toplay = "Ball"+toplay
		animStart = SyncManager.current_tick
		animator.Play(toplay)
	elif(input['upright']==0||input['up']==0&&!isLeft):
		CharacterActionState = ActionState.Prejumping
		toplay = "PrejumpRight"
		if(ballTimer == 0):
			toplay = "Ball"+toplay
		animStart = SyncManager.current_tick
		animator.Play(toplay)
	elif(input['upleft']==0||input['up']==0&&isLeft):
		CharacterActionState = ActionState.Prejumping
		toplay = "PrejumpRight"
		if(ballTimer == 0):
			toplay = "Ball"+toplay
		animStart = SyncManager.current_tick
		animator.Play(toplay)
	else:
		CharacterActionState = ActionState.Standing
		toplay = "Idle"
		if(ballTimer == 0):
			toplay = "Ball"+toplay
		animStart = SyncManager.current_tick
		animator.Play(toplay)
	if(input['throw']==0&&(isLeft&&input['right']!=0||input['left']==0)):
		CharacterActionState = ActionState.WindUp
		toplay = "WindUpLeft"
		if(ballTimer == 0):
			toplay = "Ball"+toplay
		animStart = SyncManager.current_tick
		animator.Play(toplay)
	if(input['throw']==0&&(!isLeft&&input['left']!=0||input['right']==0)):
		CharacterActionState = ActionState.WindUp
		toplay = "WindUpRight"
		if(ballTimer == 0):
			toplay = "Ball"+toplay
		animStart = SyncManager.current_tick
		animator.Play(toplay)
	if(input['dodge']==0):
		if(input['left']==0):
			CharacterActionState = ActionState.Rolling
			toplay = "RollLeft"
			if(ballTimer == 0):
				toplay = "Ball"+toplay
			animStart = SyncManager.current_tick
			animator.Play(toplay)
		elif(input['right']==0):
			CharacterActionState = ActionState.Rolling
			toplay = "RollRight"
			if(ballTimer == 0):
				toplay = "Ball"+toplay
			animStart = SyncManager.current_tick
			animator.Play(toplay)
		else:
			CharacterActionState = ActionState.Dodging
			toplay = "Dodge"
			if(ballTimer == 0):
				toplay = "Ball"+toplay
			animStart = SyncManager.current_tick
			animator.Play(toplay)
	
	
func AnimFinished():
	return (animator.get_current_animation_position()/animator.get_current_animation_length()==1)
var stickinput
func getInput(var previnput = null):
	var output = {
		"Neutral": 60,
		"Up": 60,
		"Upleft": 60,
		"Left": 60,
		"Downleft": 60,
		"Down": 60,
		"Downright": 60,
		"Right": 60,
		"Upright": 60,
		"A+B": 60,
		"A": 60,
		"B": 60,
		"qcfr": 60,
		"dpr": 60,
		"qcfl": 60,
		"dpl": 60
	}
	if(previnput!=null):
		output = previnput
	else:
		previnput = output
	output["Up"] = clamp(output["Up"]+1,0,60) as int
	output["Upleft"] = clamp(output["Upleft"]+1,0,60) as int
	output["Left"] = clamp(output["Left"]+1,0,60) as int
	output["Downleft"] = clamp(output["Downleft"]+1,0,60) as int
	output["Down"] = clamp(output["Down"]+1,0,60) as int
	output["Downright"] = clamp(output["Downright"]+1,0,60) as int
	output["Right"] = clamp(output["Right"]+1,0,60) as int
	output["Upright"] = clamp(output["Upright"]+1,0,60) as int
	output["Neutral"] = clamp(output["Neutral"]+1,0,60) as int
	output["A"] = clamp(output["A"]+1,0,60) as int
	output["B"] = clamp(output["B"]+1,0,60) as int
	output["qcfr"] = clamp(output["qcfr"]+1,0,60) as int
	output["dpr"] = clamp(output["dpr"]+1,0,60) as int
	output["qcfl"] = clamp(output["qcfl"]+1,0,60) as int
	output["dpl"] = clamp(output["dpl"]+1,0,60) as int
	stickinput = Vector2.ZERO;
	if(Input.is_action_pressed("Up")):
		stickinput = Vector2(stickinput.x,stickinput.y+1)
	if(Input.is_action_pressed("Down")):
		stickinput = Vector2(stickinput.x,stickinput.y-1)
	if(Input.is_action_pressed("Left")):
		stickinput = Vector2(stickinput.x-1,stickinput.y)
	if(Input.is_action_pressed("Right")):
		stickinput = Vector2(stickinput.x+1,stickinput.y)
	match stickinput:
		Vector2(0,-1):
			output["Down"]=0
			pass
		Vector2(0,1):
			output["Up"]=0
			pass
		Vector2(0,0):
			output["Neutral"]=0
			pass
		Vector2(-1,0):
			output["Left"]=0
			pass
		Vector2(-1,-1):
			output["Downleft"]=0
			pass
		Vector2(-1,1):
			output["Upleft"]=0
			pass
		Vector2(1,0):
			output["Right"]=0
			pass
		Vector2(1,1):
			output["Upright"]=0
			pass
		Vector2(1,-1):
			output["Downright"]=0
			pass
		Vector2(0,0):
			output["Neutral"]=0
	if(Input.is_action_pressed("A")):
		output["A"]=0
	if(Input.is_action_pressed("B")):
		output["B"]=0
	if((output["A"]<2&&output["B"]<2)&&output["A+B"]>0):
		output["A+B"]=0
	if(output["Down"]<15&&output["Downright"]<6&&output["Right"]<3):
		output["qcfr"]=0
		pass
	if(output["Down"]<15&&output["Downleft"]<6&&output["Left"]<3):
		output["qcfl"]=0
		pass
	if(output["Right"]<15&&output["Down"]<6&&output["Downright"]<3):
		output["dpr"]=0
		pass
	if(output["Left"]<15&&output["Down"]<6&&output["Downleft"]):
		output["dpl"]=0
		pass
	return output
func OnGround():
	return raycastNode.is_colliding();

func StateProcess(var input):
	var animation = animator.get_current_animation
	
	if (prevBallTimer>0&&ballTimer == 0):
		var temp = animator.current_animation_position
		animator.Play("Ball"+animation)
		animStart = SyncManager.current_tick
		animator.advance(temp)
	match CharacterActionState:
		ActionState.Standing, ActionState.Walking:
			#neutral ground
			ResolveNeutralGround(input,animation)
			pass	
		ActionState.AirDodging:
			#read only jump
			if(AnimFinished()):
				pass
				#read input and decide from neutral air
			if(OnGround()):
				ResolveNeutralGround(input,animation)
				pass
				#landing case
			pass
		ActionState.Prejumping:
			if(AnimFinished()):
				if(input["Upleft"]<input["Up"]&&input["Upleft"]<input["Upright"]):
					CharacterActionState = ActionState.Jumping
					toplay = ""
					if(isLeft):
						toplay = "JumpLeftLeft"
					if(!isLeft):
						toplay = "JumpLeftRight"
					if(ballTimer == 0):
						toplay = "Ball"+toplay
					animator.Play(toplay)
				if(input["Upright"]<input["Up"]&&input["Upright"]<input["Upleft"]):
					CharacterActionState = ActionState.Jumping
					toplay = ""
					if(isLeft):
						toplay = "JumpRightLeft"
					if(!isLeft):
						toplay = "JumpRightRight"
					if(ballTimer == 0):
						toplay = "Ball"+toplay
					animator.Play(toplay)
				if(input["Up"]<input["Upright"]&&input["Up"]<input["Upleft"]):
					CharacterActionState = ActionState.Jumping
					toplay = ""
					if(isLeft):
						toplay = "JumpUpLeft"
					if(!isLeft):
						toplay = "JumpUpRight"
					if(ballTimer == 0):
						toplay = "Ball"+toplay
					animator.Play(toplay)
			pass
		ActionState.Falling, ActionState.Jumping:
			#read input and decide from neutral air
			if(OnGround()):
				ResolveNeutralGround(input, animation)
			pass
		ActionState.Dodging, ActionState.Rolling:
			if(AnimFinished()):
				ResolveNeutralGround(input, animation)
			pass
		ActionState.WindUp:
			if(AnimFinished()):
				match input:
					{"Up": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = ""
						if(isLeft):
							toplay = "BallThrowUpForwardLeft"
						if(!isLeft):
							toplay = "BallThrowUpForwardRight"
						animator.Play(toplay)
					{"Left": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowForwardLeft"
						animator.Play(toplay)
					{"Right": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowForwardRight"
						animator.Play(toplay)
					{"Upleft": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowUpForwardLeft"
						animator.Play(toplay)
						pass
					{"Upright": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowUpForwardRight"
						animator.Play(toplay)
						pass
					{"Down": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = ""
						if(isLeft):
							toplay = "BallThrowDownForwardLeft"
						if(!isLeft):
							toplay = "BallThrowDownForwardRight"
						animator.Play(toplay)
					{"Downright": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowDownForwardRight"
						animator.Play(toplay)
						pass
					{"Downleft": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowDownForwardLeft"
						animator.Play(toplay)
						pass
					_:
						pass
			if(input["A"]>=1):
				match input:
					{"Up": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = ""
						if(isLeft):
							toplay = "BallThrowUpForwardLeft"
						if(!isLeft):
							toplay = "BallThrowUpForwardRight"
						animator.Play(toplay)
					{"Left": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowForwardLeft"
						animator.Play(toplay)
					{"Right": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowForwardRight"
						animator.Play(toplay)
					{"Upleft": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowUpForwardLeft"
						animator.Play(toplay)
						pass
					{"Upright": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowUpForwardRight"
						animator.Play(toplay)
						pass
					{"Down": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = ""
						if(isLeft):
							toplay = "BallThrowDownForwardLeft"
						if(!isLeft):
							toplay = "BallThrowDownForwardRight"
						animator.Play(toplay)
					{"Downright": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowDownForwardRight"
						animator.Play(toplay)
						pass
					{"Downleft": 0,..}:
						CharacterActionState = ActionState.Release
						toplay = "BallThrowDownForwardLeft"
						animator.Play(toplay)
						pass
					_:
						pass
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	animator = get_node("NetworkAnimationPlayer")
	raycastNode = get_node("OnGround")
	CharacterActionState = ActionState.Standing if (OnGround()) else ActionState.Falling
	pass # Replace with function body.



func _process(delta):
	print(delta*1000)
	
	
	pass
