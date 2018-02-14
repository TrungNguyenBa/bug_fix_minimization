import subprocess
import sys
import csv
import argparse
#import patch
import os
PIPE=subprocess.PIPE


def check_d4jcommand():
	result=subprocess.run("defects4j", stderr=PIPE, stdout=PIPE)
	if (result.stderr.decode() != ""):
		print ("D4J has not been installed")
		sys.exit()
	return
	
#checkout D4J defects (minimized and non-minimized)
def D4J_checkout (Project, bugID, checkoutdir="/tmp"):
	result = subprocess.run("defects4j checkout -p {} -v {}b -w {}/{}-{}b".format(Project,bugID,checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	if (result.returncode != 0):
		print ("D4J checkout error: {}-{}b".format(Project,bugID))
		return False
	result = subprocess.run("defects4j checkout -p {} -v {}00000b -w {}/{}-{}00000b".format(Project,bugID,checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	if (result.returncode != 0):
		print ("D4J checkout error: {}-{}00000b".format(Project,bugID))
		return False
	result = subprocess.run("defects4j checkout -p {} -v {}f -w {}/{}-{}f".format(Project,bugID,checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	if (result.returncode != 0):
		print ("D4J checkout error: {}-{}f".format(Project,bugID))
		return False


#Calling the diff function
def get_diff_value(file1, file2) :
	lines1 = (subprocess.run("cat {} | wc -l".format(file1),shell=True, stdout=PIPE)).stdout.decode()
	lines2 = (subprocess.run("cat {} | wc -l".format(file2),shell=True, stdout=PIPE)).stdout.decode()
	maxline=max(int(lines1),int(lines2))
	result = subprocess.run("diff -u -U{} {} {}".format(maxline,file1,file2),shell=True,  stdout=PIPE)
	try :
		return result.stdout.decode().splitlines()[3:]
	except:
		return False
	
def get_path_all_version(Project, bugID,checkoutdir = "/tmp"):
	return ["{}/{}-{}b".format(checkoutdir,Project,bugID),"{}/{}-{}00000b".format(checkoutdir,Project,bugID),"{}/{}-{}f".format(checkoutdir,Project,bugID)]


def get_minimized_modified_classes(Project, bugID, checkoutdir="/tmp"):
	fullpath="{}/{}-{}b".format(checkoutdir,Project,bugID)
	srcdir=subprocess.run("grep 'd4j.dir.src.classes' {}/defects4j.build.properties | cut -d '=' -f2".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode()
	files=subprocess.run("grep 'd4j.classes.modified' {}/defects4j.build.properties | cut -d '=' -f2 | tr '.' '/' ".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().split(",")
	return [(srcdir.strip() + "/"+ f.strip() + ".java") for f in files]

def remove_D4J_dir(Project,bugID,checkoutdir="/tmp"):
	subprocess.run("rm -rf {}/{}-{}00000b".format(checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	subprocess.run("rm -rf {}/{}-{}b".format(checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	subprocess.run("rm -rf {}/{}-{}f".format(checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
#get list of modified lines from buggy -> buggy' (minimized D4J)

#get list of modified lines from buggy -> fix


def get_modify_lines(diff_string) :
	l = []
	for line in diff_string:
		if (line.startswith("+")) or (line.startswith("-")):
			l.append(line)
	return l

class hunk:
	def __init__ (self, before_start_line, before_edited_stmts, after_start_line,after_edited_stmts):
		self.before_start_line = before_start_line
		self.before_edited_stmts = before_edited_stmts
		self.after_start_line = after_start_line
		self.after_edited_stmts = after_edited_stmts
	def get_before_start_line(self):
		return self.before_start_line
	def get_before_edited_stmts(self):
		return self.before_edited_stmts
	def get_after_edited_stmts(self):
		return self.after_edited_stmts

	def print_hunk(self):
		extra="@@ -{},{} +{},{} @@".format(self.before_start_line,len(self.before_edited_stmts),self.after_start_line,len(self.after_edited_stmts))
		removed_lines=""
		for s in self.before_edited_stmts:
			removed_lines+="\n"+s
		added_lines=""
		for s in self.after_edited_stmts:
			added_lines+="\n"+s
		string=extra+removed_lines+added_lines
		return string

def get_patch(diff_original, list_of_modified_line_from_D4J_diff):
	line_number = 0
	gap = 0
	start_gap =0
	hunks_list = []
	trigger = False
	changed_block_gap = 0
	hunk_start = 0
	before_edited_stmts = []
	after_edited_stmts = []
	for line in diff_original:
		if (line.startswith("+")) or (line.startswith("-")):
			if (list_of_modified_line_from_D4J_diff != []) and (line == list_of_modified_line_from_D4J_diff[0]):
				if (line.startswith("+")) and ( line.find("import ") != -1):
					# print("import added\n")
					after_edited_stmts.append(line)
					gap +=1
					if (trigger == False):
						hunk_start = line_number
						trigger = True
				else :
					if (trigger == True):
						newhunk = hunk(hunk_start + changed_block_gap,before_edited_stmts,hunk_start + changed_block_gap + start_gap, after_edited_stmts)
						hunks_list.append(newhunk)
						before_edited_stmts = []
						after_edited_stmts = []
						trigger = False
						start_gap = gap
						changed_block_gap = 0
					
					if (line.startswith("-")):
						line_number += 1
						changed_block_gap -=1
					

				list_of_modified_line_from_D4J_diff.pop(0)					
			else:
				if (line.startswith("-")):
					before_edited_stmts.append(line)
					line_number += 1
					gap -=1
					changed_block_gap = 0
				else:
					after_edited_stmts.append(line)
					gap +=1
				if (trigger == False):
					hunk_start = line_number
					trigger = True
		else:
			if (trigger == True):
				newhunk = hunk(hunk_start + changed_block_gap,before_edited_stmts,hunk_start+ changed_block_gap + start_gap, after_edited_stmts)
				hunks_list.append(newhunk)
				before_edited_stmts = []
				after_edited_stmts = []
				trigger = False
				start_gap = gap
				changed_block_gap = 0
			
			line_number += 1
			

	if (list_of_modified_line_from_D4J_diff != []):
		print ("patch modified in D4J cannot print patch")
		print(list_of_modified_line_from_D4J_diff)
		return []
	else:
		return hunks_list		

def patch_apply(project,bug,checkoutdir,output_dir,file):
	patch=file.replace("/",".") + ".patch"
	results1= subprocess.Popen("/Users/trung/Documents/Umass_rs/bug_fix_minimization/scripts/FL_2/applypatch.sh " + "{}/{}-{}patch/{} ".format(checkoutdir,project,bug,patch) + "{}/{}-{}00000b/{}".format(checkoutdir,project,bug,file),shell = True)
	results1.wait()
	if (results1.returncode == 0): 
		print (results1.args)
		return True
	else:
		print ("patch apply error {}-{} : file =  {}".format(project,bug,file))
		print ("Error message:")
		#print (results1.stderr.decode())
		print ("(--------------------)")
		return False


def test_trigger_tests(project,bug,checkoutdir):
	fullpath="{}/{}-{}00000b".format(checkoutdir,project,bug)
	tests=subprocess.run("grep 'd4j.tests.trigger' {}/defects4j.build.properties | cut -d '=' -f2 ".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().split(",")
	for t in tests:
		r = subprocess.run("defects4j test -w {} -t {}".format(fullpath,t),shell=True,stdout=PIPE,stderr=PIPE)
		if (r.returncode == 1) or (r.stdout.decode().find("Failing tests: 0") == -1):
			if (r.stderr.decode().find ("BUILD FAILED") != -1):
				return "Not Compiled"
			print ("Error test {}-{} : {}".format(project,bug,t))
			return False
	return True

parser = argparse.ArgumentParser()
parser.add_argument('versions_file', help='CSV file with "project,bugId" pairs to ask about')
parser.add_argument('--output-dir', default="/tmp")
parser.add_argument('--checkoutdir', default="/tmp")
parser.add_argument('--apply', action='store_true')
parser.add_argument('--trigger_tests',action='store_true' )
parser.add_argument('--delete-after-finish',action='store_true')
parser.add_argument('--Result-save', default="")
parser.add_argument('--Ignore-list', default="")
args = parser.parse_args()

check_d4jcommand()

with open(args.versions_file) as f: 
  versions = list(csv.reader(f))

if (args.Ignore_list != ""):
	with open(args.Ignore_list) as f:
		ignore_list = list(csv.reader(f))
		
if (args.Result_save != ""):
	filetowriteresult=open(args.Result_save,"w")

for i, (project,bug) in enumerate(versions, start=1):
	if [project,bug] in ignore_list:
		if (args.Result_save != ""):
			print ("Ignore {}-{}".format(project,bug))
			filetowriteresult.write("{}-{}: {}; {}\n".format(project,bug,"Ignore",""))
		continue
	print ("making patch for {}-{} ({}/{})".format(project,bug,i,len(versions)))
	D4J_checkout_result= D4J_checkout(project,bug,args.checkoutdir)
	if (D4J_checkout_result == False):
		if (args.Result_save != ""):
			print ("Checkout error {}-{}".format(project,bug))
			filetowriteresult.write("{}-{}: {}; {}\n".format(project,bug,"D4J checkout error",""))
		continue
	paths=get_path_all_version(project,bug,args.checkoutdir)
	modified_files=get_minimized_modified_classes(project,bug,args.checkoutdir)
	ready_to_apply = True
	Final_result = True
	Reason = ""
	for f in modified_files:
		original_diff=get_diff_value(paths[1]+"/"+f,paths[2]+"/"+f)
		D4J_minimized_diff=get_diff_value(paths[1]+'/'+f,paths[0]+"/"+f)
		if (original_diff == False) or (D4J_checkout_result == False):
			if (args.Result_save != ""):
				print ("Diff error {}-{}".format(project,bug))
				filetowriteresult.write("{}-{}: {}; {}\n".format(project,bug,"Diff error",""))
			continue
		D4J_diff_modified_lines=get_modify_lines(D4J_minimized_diff)
		pacth=get_patch(original_diff,D4J_diff_modified_lines)
		

		patchname=f.replace("/",".") + ".patch"
		subprocess.run("mkdir -p {}/{}-{}patch | ls {}/{}-{}patch".format(args.output_dir,project,bug,args.output_dir,project,bug),shell=True,stdout=PIPE,stderr=PIPE)

		filetowrite = open("{}/{}-{}patch/{}".format(args.output_dir,project,bug,patchname),"w")
		filetowrite.write("--- {}/{}-{}00000b/{}\n".format(args.output_dir,project,bug,f))
		filetowrite.write("+++ {}/{}-{}00000b/{}\n".format(args.output_dir,project,bug,f))
		if (pacth != []):
			for h in pacth:
				#creating patch file
				filetowrite.write(h.print_hunk()+"\n")
		else:
			ready_to_apply = False
			Final_result = False
			Reason = "False to patch"
		filetowrite.close()
	if (args.apply == True) and (ready_to_apply == True):
		print ("apply patch for {}-{}".format(project,bug))
		ready_to_test = True
		for f in modified_files:
			print("apply : {}".format(f))
			r = patch_apply(project,bug,args.checkoutdir,args.output_dir,f)
			if (r == False):
				ready_to_test = False
		if (args.trigger_tests == True) and (ready_to_test == True) :
			print ("testing the patched version of {}-{}".format(project,bug))
			r = test_trigger_tests(project,bug,args.checkoutdir)
			if (r == False) or (r == "Not Compiled"):
				print ("Not working {}-{}".format(project,bug))
				Final_result = False
				Reason = "Fail test"
				if (r == "Not Compiled"):
					Reason += "-" + r
				
			else :
				print ("Passing {}-{}".format(project,bug))
				

	print("\n")
	if (args.delete_after_finish == True):
		remove_D4J_dir(project,bug,args.checkoutdir)
	if (args.Result_save != ""):
		filetowriteresult.write("{}-{}: {}; {}\n".format(project,bug,Final_result,Reason))

if (args.Result_save != ""):
	filetowriteresult.close()









