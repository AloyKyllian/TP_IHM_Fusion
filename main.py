from ivy.ivy import IvyServer
import time
def MAE(Agent,Etat,message,delay):
	nv_etat = Etat
	if Etat == 1:
		if Agent.confiance > 70.0:
			delay = time.time()
			if Agent.action == "deplacer":
				message += Agent.action
				nv_etat = 5
			elif Agent.action == "supprimer":
				message += Agent.action
				nv_etat = 3
			elif Agent.forme != "None":
				message += Agent.action + ":" + Agent.forme
				nv_etat = 2
			else:
				message += Agent.action 
				nv_etat = 4	
		else:
			Agent.reset()
	elif Etat == 2:
		delay = time.time()
		if Agent.couleur != "None" and Agent.lieu != "None":
			nv_etat = 3
			message+= ":" + Agent.couleur 
		elif Agent.lieu != "None":
			nv_etat = 3
			message+= ":" + "noir"

	elif Etat == 3:
		if Agent.x != "None":
			nv_etat = 1
			message += ":" + Agent.x + ":" + Agent.y
			message = Agent.commande(message)
		if delay + 5 < time.time():
			nv_etat = 1
			Agent.reset()
			message = ""
	elif Etat == 4:
		if Agent.geste != "None":
			nv_etat = 2
			message += ":" + Agent.geste
		if delay + 5 < time.time():
			delay = time.time()
			nv_etat = 1
			Agent.reset()
			message = ""
	elif Etat == 5:
		if Agent.x != "None":
			nv_etat = 3
			message += ":" + Agent.x + ":" + Agent.y
			Agent.reset()
		if delay + 5 < time.time():
			nv_etat = 1
			Agent.reset()
			message = ""
	return nv_etat,message,delay

			
class MyAgent(IvyServer):
	def __init__(self, name):
		IvyServer.__init__(self,'Moteur')
		self.name = name
		self.start('127.255.255.255:2010')
		self.bind_msg(self.handle_hello, '^hello (.*)')
		self.bind_msg(self.receiveAudio, '^sra5 Parsed=(.*) Confidence=(.*) NP=.*')
		self.bind_msg(self.receiveGeste, '^ICAR Gesture=(.*)')
		self.bind_msg(self.receiveLieu, '^lieu(.*)')

		self.reset()


		time.sleep(2)
		self.send_msg('sra5 -p on')

	def commande(self,message):
		print("ordre=" + message)
		self.send_msg("ordre=" + message)
		self.reset()
		return ""
	def reset(self):
		self.action  = "None"
		self.forme = "None"
		self.couleur = "None"
		self.lieu = "None"
		self.confiance = 0.0
		self.geste = "None"
		self.x = "None"
		self.y = "None"

	def handle_hello(self, agent, arg):
		print ("[Agent %s] GOT hello from %r" %(self.name, agent))
		self.send_msg('Hello Back from %s' %arg)
	def receiveAudio(self, agent, arg,arg2):
		print ("[Agent %s] GOT Audio from %r %s %s" %(self.name, agent,arg,arg2))
		print(arg2)
		self.confiance = float(arg2.replace(',','.')) * 100
		ordre = arg.split(":")
		self.action = ordre[0]
		self.forme = ordre[1]
		self.couleur = ordre[2]
		self.lieu = ordre[3]
	def receiveGeste(self, agent, arg):
		print ("[Agent %s] GOT Geste from %r %s" %(self.name, agent,arg))
		self.geste = arg
	def receiveLieu(self, agent, arg):
		print ("[Agent %s] GOT Lieu from %r %s" %(self.name, agent,arg[16:-1]))
		coord = arg[16:-1].split(",")
		self.x= coord[0][2:]
		self.y= coord[1][2:]

a=MyAgent('HelloBack')
Etat = 1
message = ""
delay = 0
while True:
	Etat,message,delay = MAE(a,Etat,message,delay)
	print("Etat=" + str(Etat) + " message=" + message)