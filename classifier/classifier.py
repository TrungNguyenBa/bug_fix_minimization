import git
from git import Repo
import csv
class data:
	def __init__ (self,n,ls):
		self.name = n
		self.list_of_bugfix_commit = ls
	def data_print(self):
		print (self.name + ':')
		print self.list_of_bugfix_commit

directory = "/Users/trung/Documents/Umass_rs/testedness_projects/"
matching_words = ["fix","fixed","error","errors","defect","defects","bug","bugs"]
data_file = directory + "data.csv"
dlist = []
with open(data_file,'rb') as f:
	dlist = list(csv.reader(f))
#adding some stuff
#print dlist
result = []
for repo in dlist:
	name = repo[1]
	link = repo[5]
	if link == "link":
		continue
	Repo.clone_from(link, directory+name)
	g = git.Git(directory + name)
	epochday = repo[3]
	endday = repo[4]
	gitlog = g.log('--since=' + epochday, "--until=" +endday,'--pretty=oneline')
	bugfix_list = []
	for line in gitlog.splitlines(True):
		for word in matching_words:
			if word in line:
				l = (line.lower()).split()
				bugfix_list.append(l[0])
	newdata = data(name,bugfix_list)
	result.append(newdata)

for d in result:
	d.data_print()
	print ("\n")

	
