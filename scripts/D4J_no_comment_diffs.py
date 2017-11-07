import csv
import os
class data:
	def __init__(self,p,bn,f,i,d,m):
		self.project = p
		self.bugnumber = bn
		self.filename = f
		self.inserted = i
		self.deleted = d
		self.modified = m
	def get_project (self):
		return self.project
	def get_bugnumber(self):
		return self.bugnumber
	def get_filename (self):
		return self.filename
	def get_inserted_num (self):
		return self.inserted
	def get_deleted_num (self):
		return self.deleted
	def get_modified_num (self):
		return self.modified

directory="/Users/trung/Documents/Umass_rs/bug_fix_minimization/raw_data"
list_of_D4J_project_names = ["Closure", "Lang", "Math", "Time"]

data_list= []
for project in list_of_D4J_project_names:
	dir_project =  directory+ "/D4J_projects/"+project
	dir_original=dir_project + "/remove_comment_patches"
	#get all the file with .stat extension
	stat_files=[f for f in os.listdir(dir_original) if f.endswith('.stat')]
	print len(stat_files)
	#iterate through the files
	for file in stat_files:
		#splitting the file name
		namestrings = file.split('.')
		bug_id = namestrings[0]
		content  = []
		with open(dir_original+"/"+file,"r") as f:
			content=f.readlines()
		#remove extra characters
		content = [x.strip() for x in content]
		i = 0
		for c in content:
			#ignore the first line
			if (i == 0):
				i+=1
				continue
			chunks = c.split(',')
			i = chunks[0]
			f = chunks[3]
			d = chunks[1]
			m = chunks[2]
			data_list.append(data(project,bug_id,f,i,d,m))

#read all collected data to a csv file
with open("/Users/trung/Documents/Umass_rs/bug_fix_minimization/csv_data/"+"D4J_no_comment_all_diffs.csv", 'w') as csvfile:
	fieldnames = ['PID', 'BID','File','inserted','deleted','modified']
	writer=csv.DictWriter(csvfile, fieldnames=fieldnames)
	writer.writeheader()
	for d in data_list:
		writer.writerow({'PID': d.get_project(), 'BID': d.get_bugnumber(),'File' : d.get_filename(),
						 'inserted' : d.get_inserted_num(), 'deleted': d.get_deleted_num(), 'modified' : d.get_modified_num()})




