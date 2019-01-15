import csv
import subprocess
import collections
import argparse
import os

PIPE = subprocess.PIPE
parser = argparse.ArgumentParser()
parser.add_argument('versions_file', help='CSV file with "project,bugId" pairs to ask about')

parser.add_argument('--start-from', default="0")

args = parser.parse_args()

with open(args.versions_file) as f:
  versions = list(csv.reader(f))

start = 0
if (args.start_from != '0'):
  start = int(args.start_from) -1
  versions=versions[start:]


for i, (project,bug) in enumerate(versions, start=1):
	subprocess.run("interdiff $D4J_HOME/framework/projects/{}/patches/{}.src.patch /dev/null > temp.r.patch".format(project,bug), shell = True)
	print("reading {}-{} ({}/{})".format(project,bug,i,len(versions)))
	with open("temp.r.patch") as patch_file:
		print(patch_file.read())

	input("Press Enter to continue ....")


subprocess.run("rm -f temp.r.patch", shell = True)