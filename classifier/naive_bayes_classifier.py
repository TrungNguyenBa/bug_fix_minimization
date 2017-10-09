import sklearn
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import SGDClassifier
import git
from git import Repo
import csv

class commits_data:
	def __init__(self,p,h,c,l = -1):
		self.project = p
		self.hash = h
		self.content = c
		self.label = l
	def get_hash (self):
		return self.hash
	def get_content(self):
		return self.content
	def get_project(self):
		return self.project
	def get_label(self):
		return self.label
	def label_assign(self,lb):
		self.label = lb
	def get_label_string(self):
		result = ""
		if (self.label == '1'):
			result = "Bug-fix"
		elif (self.label == '0'):
			result = "Others"
		else:
			result = "N/A"
		return result
	def print_commits_data(self):
		string = self.project + "," + self.hash + "," + self.content +"," + str(self.label)
		print string

def get_data_from_csv(csv_data_file, ignore_first_line = True):
	dlist = []
	with open(csv_data_file,'rb') as f:
		dlist = list(csv.reader(f))
	if (ignore_first_line == True):
		dlist = dlist[1:]
	return dlist

def get_column_data(csv_data_file,commit_content_column):
	c_list = get_data_from_csv(csv_data_file,ignore_first_line = False)
	data = []
	for c in c_list:
		data.append(c[commit_content_column])
	return data



#getting training data 
csv_train_data_file = "/Users/trung/Documents/Umass_rs/bug_fix_minimization/msr-data/Commits.csv"
traindata = get_column_data(csv_train_data_file,6)
count_vect = CountVectorizer(stop_words ='english')
train_docterm_matrix = count_vect.fit_transform(traindata)
tfidf_transformer = TfidfTransformer()
train_docterm_matrix_tfidf = tfidf_transformer.fit_transform(train_docterm_matrix)

#getting_labels
csv_label_data_file = "/Users/trung/Documents/Umass_rs/bug_fix_minimization/msr-data/SurveyResults.csv"
data_labels = get_column_data(csv_label_data_file,2)

#train the NB classifier
trained_NB_clf = MultinomialNB().fit(train_docterm_matrix_tfidf, data_labels)

#train the SVM classifier
trained_SVM_clf = SGDClassifier().fit(train_docterm_matrix_tfidf,data_labels)

#getting test data 
#seperating commits hash and content
def commits_data_process(project,commit):
	c_index = commit.find(" ",0)
	content = (commit[(c_index+1):]).encode('ascii', 'ignore').decode('ascii')
	c_hash = (commit[0:c_index]).encode('ascii', 'ignore').decode('ascii')
	return  commits_data(project,c_hash,content)

def get_commit_test_data(dlist, directory, is_clone= False):
	commit_data_list =[]
	for repo in dlist:
		name = repo[1]
		link = repo[5]
		epochday = repo[3]
		endday = repo[4]
		if (is_clone == True):
			Repo.clone_from(link, directory + name)
		g = git.Git(directory + name)
		gitlog = g.log('--since=' + epochday, "--until=" +endday,'--pretty=oneline')
		for line in gitlog.splitlines(True):
				cd = commits_data_process(name,line)
				commit_data_list.append(cd)
	return commit_data_list

csv_test_data_file = "/Users/trung/Documents/Umass_rs/testedness_projects/data.csv"
dlist = get_data_from_csv(csv_test_data_file)
directory = "/Users/trung/Documents/Umass_rs/testedness_projects/"
test_commit_data = get_commit_test_data(dlist,directory,is_clone=False)
#converting commits data to array of commit contents
def content_array(testdata):
	lst = []
	for data in testdata:
		lst.append(data.get_content())
	return lst
#making the document-term matrix for the array of test commit contents		
testdata = content_array(test_commit_data)
test_docterm_matrix = count_vect.transform(testdata)
# tfidf_transformer = TfidfTransformer()
# test_docterm_matrix_tfidf = tfidf_transformer.fit_transform(test_docterm_matrix)


#classify using the trained NB classifier
predicted_NB_array = trained_NB_clf.predict(test_docterm_matrix)

#classify using the trained SVM classifier
predict_SVM_array = trained_SVM_clf.predict(test_docterm_matrix)

#assign predicted table to each test commits:
i = 0
#NB
test_commit_data_NB = test_commit_data
for label in predicted_NB_array:
	test_commit_data_NB[i].label_assign(label)
	i = i + 1
#SBM
test_commit_data_SVM = test_commit_data
i = 0
for label in predict_SVM_array:
	test_commit_data_SVM[i].label_assign(label)
	i =i + 1

#tranform commits data to csv file
def data_to_csv(list_of_commit_data,name_of_file):
	with open(name_of_file, 'w') as csvfile:
	    fieldnames = ['project', 'hash','content','label']
	    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
	    writer.writeheader()
	    for c in list_of_commit_data:
	    	writer.writerow({'project': c.get_project(), 'hash': c.get_hash(),'content' : c.get_content(), 'label' : c.get_label_string() })

#write results to csv files
NB_result_file = "/Users/trung/Documents/Umass_rs/bug_fix_minimization/NB_result.csv"
SVM_result_file  = "/Users/trung/Documents/Umass_rs/bug_fix_minimization/SVM_result.csv"

data_to_csv(test_commit_data_NB,NB_result_file)
data_to_csv(test_commit_data_SVM,SVM_result_file)





