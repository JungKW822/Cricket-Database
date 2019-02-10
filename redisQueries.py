import redis

def chooseGame(r):
	team = input("Enter 3 letter team (ie ENG): ")
	#team = "ENG"
	options = []
	count = 1
	for i in r.keys("*"+team+"*"):
		options.append(str(i).replace("b'","").replace("'",""))
		print(str(count)+") "+options[count-1])
		count+=1
	print("*"*20)
	choice1 = int(input("Choose a game by the number: "))
	#choice1 = 2
	print(options[choice1-1])
	return(chooseRange(r,choice1,options))

def chooseRange(r,choice1,options):
	print("*"*20)
	choice2 = int(input("Enter the lrange start: "))
	#choice2 = 0
	choice3 = int(input("Enter the lrange end: "))
	#choice3 = 10
	count = 0
	options2 = []
	for i in r.lrange(options[choice1-1], choice2, choice3):
		options2.append(str(i).replace("b'","").replace("'",""))
		print(str(count)+") "+options2[count])
		count+=1
	return(chooseTime(r,choice1,choice2, choice3, options, options2))

def chooseTime(r,choice1,choice2, choice3, options,options2):
	print("*"*20)
	choice4 = int(input("Choose a time stamp to get values: "))
	print("Time: " + str(options2[choice4]))
	#choice4 = 2
	z = r.hgetall(options2[choice4])
	for x in z:
		k = str(str(x).replace("b'","").replace("'",""))
		v = str(str(z.get(x)).replace("b'","").replace("'",""))
		print(k+":"+v)
	return(moreOptions(r,choice1,choice2,choice3,options, options2))

def moreOptions(r,choice1,choice2,choice3,options,options2):
	print("*"*20)
	print("1) Choose different game\n2) Choose different range\n3) Choose different time\n4) Exit\n")
	choice = int(input("Choice: "))
	if choice == 1:
		print("*"*20)
		return(chooseGame(r))
	elif choice == 2:
		chooseRange(r,choice1,options)
	elif choice == 3:
		chooseTime(r,choice1,choice2, choice3, options, options2)
	else:
		return

def main():
	r = redis.Redis(host='localhost', port=6379, db=0)
	chooseGame(r)

if __name__ == '__main__':
	main()