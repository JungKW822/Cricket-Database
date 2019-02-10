#!/usr/bin/env python3.5
import random
import redis
import csv
import datetime
# Very messy quick implementation. Not effiecent or good by anymeans.
"""
The format for the game key is:
TEAMvTEAM:dd/mm/yy
The format for the timestamp key is:
hh:mm:ss
"""
# Connect to redis server
r = redis.Redis(host='localhost', port=6379, db=0)

# Set up teams
date = datetime.datetime.now().strftime("%d"+"/"+"%m"+"/"+"%y")
teamAName = "ENG"
teamAplayers = ["Eoin_Morgan","Moeen_Ali","Jonny_Bairstow","Jos_Buttler","Tom_Curran","Alex_Hales","Liam_Plunkett","Adil_Rashid","Joe_Root","Jason_Roy","Mark_Wood"] 
teamBName = "AUS"
teamBplayers = ["Time_Paine","Aaron_Finch","Ashton_Agar","Alex_Carey","Travis_Head","Nathan_Lyon","Glenn_Maxwell","Shaun_Marsh","Jhye_Richardson","Kane_Richardson","Andrew_Tye"]
outPlayers = []

# Set up play types
strikeType = ["Drive", "Defence","Hook"]
ballType = ["LegSpin","OffSpin","Fast"]
fieldType = ["Caught","HitWickets"]

# Set up csv data
bowlCsv = [["time", "team", "current_bowler", "ball_number", "ball_type", "speed"]]
battCsv = [["time", "team", "current_batter", "ball_number", "strike_type", "run_score"]]
fieldCsv = [["time", "team", "fielder_bowler", "ball_number", "out_type"]]

# Set up game balls and start time
overs = 20
totalBalls = overs*6 # 1 over = 6 balls * 5overs = 30 balls
ball = 0
runsTotal = 0 # Internal for python to keep track	
timeStampH = 12
timeStampM = 0
timeStampS = 0
aOut = False
turn = 0
# Start loop for how many balls to be played
while turn !=2:
	if turn == 0:
		bowlingTeam = teamAName
		bowling = teamAplayers
		fielding = teamAplayers
		batting = teamBplayers
		battingTeam = teamBName
		bowlingTeam = teamBName
		bowling = teamBplayers
		fielding = teamBplayers
		batting = teamAplayers
		battingTeam = teamAName
		# Choose two random batters, remove from total team, assign one as current
		batterChoice = []
		batterChoice.append(random.choice(batting))
		outPlayers.append(batting.pop(batting.index(batterChoice[0])))
		batterChoice.append(random.choice(batting))
		outPlayers.append(batting.pop(batting.index(batterChoice[1])))
		currentBatter = batterChoice[0]
		currentBowler = random.choice(bowling)
	elif turn == 1:
		bowlingTeam = teamBName
		bowling = teamBplayers
		fielding = teamBplayers
		batting = teamAplayers
		battingTeam = teamAName
		bowlingTeam = teamAName
		bowling = teamAplayers
		fielding = teamAplayers
		batting = teamBplayers
		battingTeam = teamBName
		batterChoice = []
		batterChoice.append(random.choice(batting))
		outPlayers.append(batting.pop(batting.index(batterChoice[0])))
		batterChoice.append(random.choice(batting))
		outPlayers.append(batting.pop(batting.index(batterChoice[1])))
		currentBatter = batterChoice[0]
		currentBowler = random.choice(bowling)
	turn+=1
	for i in range(totalBalls):

		runsScored = 0
		speed = random.randrange(45,101)
		ball+=1

		# Decide random amount of runs with 1/3 chance scoring runs
		if random.randrange(1,4) == 1:
			runsScored = random.randrange(7)
			runsTotal += runsScored
			if runsTotal % 2 == 0:
				currentBatter = batterChoice[0]
			else:
				currentBatter = batterChoice[1]

		# Set Key value for match adding time stamp
		if timeStampM == 0:
			keyA = (str(timeStampH)+":"+str(timeStampM)+"0:"+str(timeStampS+random.randrange(10,21)))
			keyB = (str(timeStampH)+":"+str(timeStampM)+"0:"+str(timeStampS+random.randrange(21,41)))
			keyC = (str(timeStampH)+":"+str(timeStampM)+"0:"+str(timeStampS+random.randrange(41,55)))
			keyD = (str(timeStampH)+":"+str(timeStampM)+"0:"+str(timeStampS+random.randrange(55,60)))
		elif 10 > timeStampM > 1:
			keyA = (str(timeStampH)+":0"+str(timeStampM)+":"+str(timeStampS+random.randrange(10,21)))
			keyB = (str(timeStampH)+":0"+str(timeStampM)+":"+str(timeStampS+random.randrange(21,41)))
			keyC = (str(timeStampH)+":0"+str(timeStampM)+":"+str(timeStampS+random.randrange(41,55)))
			keyD = (str(timeStampH)+":0"+str(timeStampM)+":"+str(timeStampS+random.randrange(55,60)))
		else:
			keyA = (str(timeStampH)+":"+str(timeStampM)+":"+str(timeStampS+random.randrange(10,21)))
			keyB = (str(timeStampH)+":"+str(timeStampM)+":"+str(timeStampS+random.randrange(21,41)))
			keyC = (str(timeStampH)+":"+str(timeStampM)+":"+str(timeStampS+random.randrange(41,55)))
			keyD = (str(timeStampH)+":"+str(timeStampM)+":"+str(timeStampS+random.randrange(55,60)))
		
		# Increase play time small arbitrary amount
		timeStampM+= random.randrange(3,6)
		if timeStampM > 60:
			timeStampH +=1
			timeStampM = 0


		# Logic for randomly getting a player out, removing from  playable players pool. If not just continue play
		if random.randrange(1,20) == 1:
			c = random.choice(bowling)
			d = random.choice(fieldType)
			bowlValueH = {"Name":currentBowler,"Ball":ball,"Ball-Type":random.choice(ballType),"Speed":str(speed)+"mph"}
			fieldValueH = {"Name": c,"Type": d}
			battValueH = {"Name":currentBatter,"Ball":ball,"Strike-Type":random.choice(strikeType),"Runs-Scored":runsScored,"Out":"Yes"}

			if not batting:
				print("All batters out.")
				aOut = True
				break

			batterChoice.append(random.choice(batting))
			currentBatter = batterChoice[1]

			r.hmset(keyA,bowlValueH)
			r.hmset(keyB,battValueH)
			r.hmset(keyC,fieldValueH)
			r.rpush(teamAName+"v"+teamBName+":"+date, keyA, keyB, keyC)

			# Save in Csv data
			bowlCsv.append([keyA, bowlingTeam, currentBowler, str(ball), ballType, str(speed)])
			battCsv.append([keyB, battingTeam, currentBatter, str(ball), strikeType, str(runsScored)])
			fieldCsv.append([keyC, bowlingTeam, c, str(ball), d])    
			           
			# Write in Csv file
			with open("bowler.csv", 'w') as csvFile:
				writer = csv.writer(csvFile)
				writer.writerows(bowlCsv)
			with open("batter.csv", 'w') as csvFile:
				writer = csv.writer(csvFile)
				writer.writerows(battCsv)
			with open("fielder.csv", 'w') as csvFile:
				writer = csv.writer(csvFile)
				writer.writerows(fieldCsv)

			if ball%6 == 0:
				#r.set(keyD,"Over " + str(ball/6) + " Finished")
				r.hmset(keyD,{"Over":str(int(ball/6)) + " Finished"})
				r.rpush(teamAName+"v"+teamBName+":"+date, keyD)
				print(keyD,"Over " + str(int(ball/6)) + " Finished")

				if random.randrange(1,8) == 1:
					currentBowler = random.choice(bowling)
			# Debug
			print(keyA,bowlValueH)
			print(keyB,battValueH)
			print(keyC,fieldValueH)
			
		else:
			a = random.choice(ballType)
			b = random.choice(strikeType)
			bowlValueH = {"Name":currentBowler,"Ball":ball,"Ball-Type": a,"Speed":str(speed)+"mph"}
			battValueH = {"Name":currentBatter,"Ball":ball,"Strike-Type": b,"Runs-Scored":runsScored}

			# Save in Csv data
			bowlCsv.append([keyA, bowlingTeam, currentBowler, str(ball), a, str(speed)])
			battCsv.append([keyB, battingTeam, currentBatter, str(ball), b, str(runsScored)])            
	                       
	        # Write in Csv file
			with open("bowler.csv", 'w') as csvFile:
				writer = csv.writer(csvFile)
				writer.writerows(bowlCsv)
			with open("batter.csv", 'w') as csvFile:
				writer = csv.writer(csvFile)
				writer.writerows(battCsv)

			r.hmset(keyA, bowlValueH)
			r.hmset(keyB, battValueH)
			r.rpush(teamAName+"v"+teamBName+":"+date, keyA, keyB)

			if ball%6 == 0:
				r.hmset(keyD,{"Over":str(int(ball/6)) + " Finished"})
				r.rpush(teamAName+"v"+teamBName+":"+date, keyD)

				print(keyD,"Over " + str(ball/6) + " Finished")
				if random.randrange(1,8) == 1:
					currentBowler = random.choice(bowling)
			# Debug
			print(keyA,bowlValueH)
			print(keyB,battValueH)

	print(outPlayers)
	print(batting)
	for i in range(len(outPlayers)):
		batting.append(outPlayers.pop())
	"""
				# Only for debug
				if aOut == True:
					print("Game Over.")
				else:
					print(keyD,"Over " + str(int(ball/6)) + " Finished")"""

# Squad Members
# https://www.cricbuzz.com/cricket-series/2618/australia-tour-of-england-2018/squads