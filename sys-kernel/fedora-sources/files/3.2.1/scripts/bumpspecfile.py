#!/usr/bin/python
#
# Uses git config options user.name and user.email, falls
# back to env vars $GIT_COMMITTER_NAME and $GIT_COMMITTER_EMAIL
#
import re
import sys
import time
import os
import string

class Specfile:
    def __init__(self,filename):
        file=open(filename,"r")
        self.lines=file.readlines()
        self.vr=""

    def getNextVR(self,aspec):
         # Get VR for changelog entry.
        (ver,rel) = os.popen("LC_ALL=C rpm --specfile -q --qf '%%{version} %%{release}\n' --define 'dist %%{nil}' %s | head -1" % aspec).read().strip().split(' ')
	pos = 0
        # general released kernel case, bump 1st field
        fedora_build = rel.split('.')[pos]
        if fedora_build == "0":
            # this is a devel kernel, bump 2nd field
            pos = 1
        elif rel.split('.')[-1] != fedora_build:
            # this is a branch, must bump 3rd field
            pos = 2
        fedora_build = rel.split('.')[pos]
        if pos == 1 and len(rel.split('.')) > 4:
            # uh... what? devel kernel in a branch? private build? just do no VR in clog...
            print "Warning: not adding any VR to changelog, couldn't tell for sure which field to bump"
            pos = -1
        next_fedora_build = int(fedora_build) + 1
        if pos == 0:
            nextrel = str(next_fedora_build)
        elif pos == 1:
            nextrel = "0." + str(next_fedora_build)
        elif pos == 2:
            nextrel = rel.split('.')[0] + "." + rel.split('.')[1] + "." + str(next_fedora_build)
        if pos >= 0:
            for s in rel.split('.')[pos + 1:]:
                nextrel = nextrel + "." + s
            self.vr = " "+ver+'-'+nextrel

    def addChangelogEntry(self,entry):
        user = os.popen("git config --get user.name").read().rstrip()
        if (user == ""):
            user = os.environ.get("GIT_COMMITTER_NAME","Unknown")
        email = os.popen("git config --get user.email").read().rstrip()
        if (email == ""):
            email = os.environ.get("GIT_COMMITTER_EMAIL","unknown")
        if (email == "unknown"):
            email = os.environ.get("USER","unknown")+"@fedoraproject.org"
        changematch=re.compile(r"^%changelog")
        date=time.strftime("%a %b %d %Y",   time.localtime(time.time()))
        newchangelogentry="%changelog\n* "+date+" "+user+" <"+email+">"+self.vr+"\n"+entry+"\n\n"
        for i in range(len(self.lines)):
            if(changematch.match(self.lines[i])):
                self.lines[i]=newchangelogentry
                break

    def writeFile(self,filename):
        file=open(filename,"w")
        file.writelines(self.lines)
        file.close()

if __name__=="__main__":
  aspec=(sys.argv[1])
  s=Specfile(aspec)
  entry=(sys.argv[2])
  s.getNextVR(aspec)
  s.addChangelogEntry(entry)
  s.writeFile(aspec)

