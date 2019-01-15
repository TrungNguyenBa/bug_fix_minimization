import subprocess
import csv
import argparse
PIPE=subprocess.PIPE

def patch_creating(patchdir, test, checkoutdir ):
	# test the trigger test
	fullpath = checkoutdir
	if (test == True):
		r = test_trigger_tests(checkoutdir)
		if (r == False):
			print ("the patch didn't pass the tests")
			return
	pid = subprocess.run("grep 'd4j.project.id' {}/defects4j.build.properties | cut -d '=' -f2".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().strip()
	bid = subprocess.run("grep 'd4j.bug.id' {}/defects4j.build.properties | cut -d '=' -f2".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().strip()
	srcdir= subprocess.run("grep 'd4j.dir.src.classes' {}/defects4j.build.properties | cut -d '=' -f2".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().strip()
	# creating new patch dir
	patchfullpath="{}/{}-{}.git.patch".format(patchdir,pid,bid)
	r  = subprocess.run("git -C {} diff tags/D4J_{}_{}_BUGGY_VERSION -- {} > {}".format(fullpath,pid,bid,srcdir,patchfullpath), shell = True, stdout=PIPE,stderr=PIPE)
	if (r.returncode != 0):
		print ("command {}".format(r.args))
		print (r.stderr.decode())
		print ("error occurs while creating the diff")
	return

def test_trigger_tests(checkoutdir):
	fullpath = checkoutdir
	tests=subprocess.run("grep 'd4j.tests.trigger' {}/defects4j.build.properties | cut -d '=' -f2 ".format(fullpath),shell=True,stdout=PIPE,stderr=PIPE).stdout.decode().split(",")
	for t in tests:
		r = subprocess.run("defects4j test -w {} -t {}".format(fullpath,t),shell=True,stdout=PIPE,stderr=PIPE)
		if (r.returncode == 1) or (r.stdout.decode().find("Failing tests: 0") == -1):
			if (r.stderr.decode().find ("BUILD FAILED") != -1):
				print ("Not Compiled")
				return False
			print ("Error test: {}".format(t))
			return False
	return True

parser = argparse.ArgumentParser()
parser.add_argument('--patchdir',required = True)
parser.add_argument('--checkoutdir',default=".")
parser.add_argument('--test-trigger-tests', action='store_true')
args = parser.parse_args()


patch_creating(args.patchdir,args.test_trigger_tests,args.checkoutdir)









