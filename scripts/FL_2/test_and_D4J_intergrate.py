import subprocess
import csv
import argparse
PIPE=subprocess.PIPE

def D4J_checkout (Project, bugID, checkoutdir):
	if (int(bugID) >= 100000):
		result = subprocess.run("defects4j checkout -p {} -v {}b -w {}/{}-{}b".format(Project,bugID,checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
		if (result.returncode != 0):
			print ("D4J checkout error: {}-{}b".format(Project,bugID))
			return False
	else:
		result = subprocess.run("defects4j checkout -p {} -v {}00000b -w {}/{}-{}00000b".format(Project,bugID,checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	return True

def normal_patch_apply(project,bug,checkoutdir,output_dir,file):
	original_file=file.replace(".","/").replace("/java/patch",".java")
	results1= subprocess.Popen("$minimized_commits_data/D4J_evaluation/D4J_minimized_bug_to_patch/applypatch.sh " + "{}/{} ".format(output_dir,file) + "{}/{}-{}00000b/{}".format(checkoutdir,project,bug,original_file),shell = True)
	results1.wait()
	if (results1.returncode == 0): 
		print (results1.args)
		return True
	else:
		print ("patch apply error {}-{} : file =  {}".format(project,bug,file))
		print (results1.args)
		print ("(--------------------)")
		return False

def apply_patch (Project,bugID, diff_type, patch_dir, checkoutdir):
	if (diff_type == "normal"):
		files = subprocess.run("ls -1 {}".format(patch_dir),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().splitlines()
		if (files == []):
			print ("Empty folder or Error while getting file names ({})".format(patch_dir))
			return False
		for file in files:
			r = normal_patch_apply(Project,bugID,checkoutdir,patch_dir,file)
			if (r == False):
				print ("apply unsucessful {}-{}: file {}".format(Project,bugID,file))
				return False
				break

	if (diff_type == "git"):
		checkout_dir="{}/{}-{}00000b".format(checkoutdir,Project,bugID)
		file = "{}/{}-{}00000.git.patch".format(patch_dir,Project,bugID)
		r = subprocess.run("git -C {} apply {}".format(checkout_dir,file),shell=True,stdout=PIPE,stderr=PIPE)
		if (r.returncode != 0):
			print ("apply unsucessful {}-{}: file {}".format(Project,bugID,file))
			print (r.stderr.decode())
			return False
	return True

def test_trigger_tests(project,bug,checkoutdir):
	fullpath="{}/{}-{}00000b".format(checkoutdir,project,bug)
	tests=subprocess.run("grep 'd4j.tests.trigger' {}/defects4j.build.properties | cut -d '=' -f2 ".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().split(",")
	for t in tests:
		r = subprocess.run("defects4j test -w {} -t {}".format(fullpath,t),shell=True,stdout=PIPE,stderr=PIPE)
		if (r.returncode == 1) or (r.stdout.decode().find("Failing tests: 0") == -1):
			if (r.stderr.decode().find ("BUILD FAILED") != -1):
				print ("Not Compiled")
				return "Not Compiled"
			print ("Error test {}-{} : {}".format(project,bug,t))
			return False
	return True

def D4J_intergrate(project,bug,checkoutdir):
	intergrate_patches(project,bug,checkoutdir)
	r = subprocess.run("grep '^{}00000,' $D4J_HOME/framework/projects/{}/commit-db | cut -d',' -f2 ".format(bug,project),shell=True,stdout=PIPE,stderr=PIPE)
	if (r.returncode != 0 or r.stdout.decode().strip() == "" ):
		print ("error while getting the buggy hash")
		print(r.args)
		return False
	buggy_hash = r.stdout.decode().strip()
	r = subprocess.run("grep '^{}00000,' $D4J_HOME/framework/projects/{}/commit-db | cut -d',' -f3 ".format(bug,project),shell=True,stdout=PIPE,stderr=PIPE)
	if (r.returncode != 0 or r.stdout.decode().strip() == "" ):
		print ("error while getting the buggy hash")
		print(r.args)
		return False
	fixed_hash = r.stdout.decode().strip()
	hashes = buggy_hash+","+fixed_hash
	r = subprocess.run("grep '^{}011110' >> $D4J_HOME/framework/projects/{}/commit-db".format(bug,hashes,project),shell=True,stdout=PIPE,stderr=PIPE)
	if (r.returncode != 0):
		r = subprocess.run("echo '{}011110,{}' >> $D4J_HOME/framework/projects/{}/commit-db".format(bug,hashes,project),shell=True,stdout=PIPE,stderr=PIPE)
		if (r.returncode != 0 ):
			return False
	return True

def intergrate_patches(project,bug,checkoutdir):
	fullpath="{}/{}-{}00000b".format(checkoutdir,project,bug)
	d4j_path="$D4J_HOME/framework/projects/{}/patches".format(project)
	# making new commits
	srcdir= subprocess.run("grep 'd4j.dir.src.classes' {}/defects4j.build.properties | cut -d '=' -f2".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().strip()
	r = subprocess.run("git -C {} add -- {} && git -C {} commit -m 'Commit new fixed' ".format(fullpath,srcdir,fullpath),shell=True,stdout=PIPE,stderr=PIPE)
	if (r.returncode != 0):
		print ("git commit error {}-{}".format(project,bug))
		print (r.stderr.decode())
		return False

	r = subprocess.run("git -C {} diff HEAD~2 HEAD  -- {} > {}/{}011110.fixed.src.patch".format(fullpath,srcdir,d4j_path,bug),shell=True,stdout=PIPE,stderr=PIPE)
	if (r.returncode != 0):
		print ("git diff error {}-{}".format(project,bug))
		print (r.stderr.decode())
		return False
	r = subprocess.run("git -C {} diff HEAD HEAD~1 -- {} > {}/{}011110.src.patch".format(fullpath,srcdir,d4j_path,bug),shell=True,stdout=PIPE,stderr=PIPE)
	if (r.returncode != 0):
		print ("git diff error {}-{}".format(project,bug))
		print (r.stderr.decode())
		return False


def remove_D4J_dir(Project,bugID,checkoutdir="/tmp"):
	subprocess.run("rm -rf {}/{}-{}00000b".format(checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	subprocess.run("rm -rf {}/{}-{}011110b".format(checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	subprocess.run("rm -rf {}/{}-{}b".format(checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)
	subprocess.run("rm -rf {}/{}-{}f".format(checkoutdir,Project,bugID),shell=True,stdout=PIPE,stderr=PIPE)


parser = argparse.ArgumentParser()
parser.add_argument('versions_file', help='CSV file with "project,bugId,diff_type,patch_dir"')
parser.add_argument('--checkoutdir', help = 'Directory to checkout defect',default="/tmp")
parser.add_argument('--test', help = 'turn on to perform trigger test on the newly patched folder', action ="store_true")

args = parser.parse_args()

with open(args.versions_file) as f: 
	versions = list(csv.reader(f))

for i, (project,bug,difftype,patchdir) in enumerate(versions, start=1):
	print("Project {}, bug {}".format(project,bug))
	r = D4J_checkout(project,bug,args.checkoutdir)
	print("finish checkouting")
	test_result = True
	if ( r != False):
		r = apply_patch(project,bug,difftype,patchdir,args.checkoutdir)
		print("finish applying patch")
		if (r != False):
			if (args.test == True):
				test_result = test_trigger_tests(project,bug,args.checkoutdir)
				print("finish testing trigger tests")
				#continue
			if (test_result == True):
				r = D4J_intergrate(project,bug,args.checkoutdir)
				print("finish testing trigger tests")
				if (r == False):
					print ("D4J intergrate error".format(project,bug))
					continue
			else:
				print ("test error : {}-{}".format(project,bug))
				continue
		else:	
			print ("apply patch error : {}-{}".format(project,bug))
			continue
	else:
		print ("checkout error:s {}-{}".format(project,bug))
		continue

	r = subprocess.run("$minimized_commits_data/D4J_Evaluation/D4J_populate/new_minimized_fixed_version_populate.sh {} {} {}".format(project,bug,args.checkoutdir),shell=True,stdout=PIPE,stderr=PIPE)
	if (r.returncode != 0):
		print ("error:")
		print (r.args)
		print ("\nstdout:")
		print (r.stdout.decode())
		print ("\nstderr:")
		print (r.stderr.decode())

	#remove_D4J_dir(project,bug,args.checkoutdir)

	