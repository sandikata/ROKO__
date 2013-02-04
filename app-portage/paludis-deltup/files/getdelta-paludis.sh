#!/bin/sh
# getdelta.sh 
# A download-wrapper script for gentoo that tries to get dtu files 
# created by deltup instead of downloading complete source-files 
# to save bandwidth.
#
#    (C) 2004-2006 Nicolai Lissner <nlissne@linux01.gwdg.de>
#    This script is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License , or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, write to
#
#    The Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111, USA.

VERSION="0.7"

# Changelog
# version 0.7.7   2007/01/30
#		- added support for more than one local mirror in getdelta.rc 
#                 thanks to Alexander Polozov, who sent me the patch for this
# version 0.7.6   2006/10/08
#		- fixed a typo - thanks to Andrey, who reported this problem in gentoo bug #150426
# version 0.7.5   2006/10/03
#		- added support for changing timeout based on expected filesize
#		  if configured it will reduce the waiting timeout to the expected download-time (based on size of old version)
# version 0.7.4   2006/09/06
#		- do not remove log file but reset only to make this work with FEATURE userfetch
# version 0.7.3 
#		  2006/09/01
#		- fixed a bug in detection of original url (sometimes no url was found)
# version 0.7.2
#		  2006/08/18
#		- improved method of chosing the right candidate
# version 0.7.1
#		  2006/08/08
#		- fixed a problem in counting differences in filenames (aka bug #105011)
#		- 
# version 0.7
#		  2005/05/09
#		- servers create dtu files based on bdelta instead of xdelta
#		  this happens for two reasons: smaller dtu-files and amd64-compatibilty
#		  (yes, it's true - welcome to all new amd64 users of the servers)
#		  this is the reason for major update - and update forcing - you really 
#		  NEED bdelta now to use the servers, while you do *not* need xdelta anymore :)
#		- integrity change of old candidate is optional now and *disabled* by default
#		  if you want this time consuming "safe way" re-enable it via the config-file
#		- added some files to DO_NOT_REMOVE file 
#		- added "&time=<timestamp>" to prevent ANY proxy from returning results from cache
#		  instead of asking the server - the server does not use this parameter - it just
#		  exists to create unique request-URLS (as proposed by bodo "bothie" thiesen)
# version 0.6.9	  2005/03/11
#		­ exit with exitcode of wget to signal to portage if 
#		  download was successful
#		- handle metadata.dtd as exception (repoman uses FETCHCOMMAND)
#		- you can disable fetching of dtu-files now by setting  
#		  the environment variable GETDELTA=0
# version 0.6.8   2005/01/09
#		- init frontmatch and backmatch with 0 (thanks, Torsten Veller)
#		  I wonder when it disappeared from the script
# version 0.6.7	  2004/12/22
#		- corrected the formula for the saved size in percent
#		  as reported by Torsten Veller
# version 0.6.6   2004/12/21
#		- ignore "try" in MPlayer filename
# version 0.6.5	  2004/11/15
#		- added information about the saved traffic
#		- fix: use NORMAL color after first waiting for retry
#		  and QUEUETIMEOUT works now (thanks to Bodo Thiesen for the patch)
#		- ignore "PR" in filename if the filename starts with firefox
# version 0.6.4   2004/11/08
#		- inserted "break" to the TSTAMP>=QTMOUNT condition, too
#		  (reported by Torsten Veller)
# version 0.6.3   2004/11/08
#		- added "^bash" and "^gtk-engines" to the default 
#		  do_not_remove file
#		- inserted a "break" to prevent infinite looping
#		  when the server returns a queueposition higher than
#		  the allowed number (as reported by James Rowe and others)
# version 0.6.2   2004/10/22
#		- changed QUERY_URL to get the last URL instead the first
#		  since that's the original server (not a mirror)
# version 0.6.1	  2004/10/18
#		- give better original URL to the server
#		- enhanced detection of former version (thanks to Jimmy Wennlund)
#		- the COLOR variable didn't work since 0.5.3, because 
#		  the config file was not read before evaluating the variable
#		- check, if the user have set RESUMECOMMAND to getdelta.sh
#		  and if so complain about this
#
# version 0.6	  2004/10/12
#		- dropped the client-side mirror-detection
#		- Jimmy Wennlund <jimmy@jw.dyndns.org> sent me patch to 
#                 make getdelta.sh work in an own tempdir and to 
#		  remove any temporary files even when user pressed 
#		  ctrl-c -- I really like that. Thanks, Jimmy.
# version 0.5.4   2004/10/11
#		- fixed a security leak (possible symlink attack)
#		  thanks to Raimund Specht <raimund@spemaus.de> for
#		  reporting the problem and sending some possible solutions.
# version 0.5.3.5 2004/10/02
#		- the DO_NOT_REMOVE-file was overwritten with defaults
#                 fixed.
# version 0.5.3.4 2004/09/20
#		- fixed wrong path-detection with thirdpartymirrors
# version 0.5.3.3 2004/09/12
#		- changed the way the script finds the mirror-group to use
#		- setting GENTOO_MIRRORS="" is *not* necessary anymore 
#                 removed check and warning about that
# version 0.5.3.2 2004/09/12
#		- fixed a bug in the ouput of remove() (thx to wiebel)
# version 0.5.3.1 2004/09/12
#		- fixed a typo (FILESDIR) 
#		- fixed a missing "]"
# version 0.5.3	2004/09/12		
#		- some code cleanups
#		- use a separated config file now
#		- old file in DISTDIR is tested on corruption before trying to download a dtu
#		  (thanks to pkunk)
#		- check for GENTOO_MIRRORS=""
#		- new LOCAL_MIRROR to check *before* requesting a dtu
#		- non existing DO_NOT_REMOVE-file is created with some defaults
#		- found a severe bug in finding candidates when updating files beginning with "lib"
#		- added MAXIMUM_ACCEPTABLE_QUEUEPOS
# version 0.5.2.3 2004/09/06
#		- new variable QUERY_RETRY
#		- dont remove file added 
# version 0.5.2.2 2004/08/30
#		- fixed a typo
# version 0.5.2.1 2004/08/29
#		- fixed "too many arguments" as suggested by NoUseForAName
#		  in posting http://forums.gentoo.org/viewtopic.php?p=1480776#1480776
# version 0.5.2 2003/08/27
#		- server sends a queued-message including queue-position now
#		  show this.
# version 0.5.1 2003/08/24
#		- for some reason a "broken pipe" message appears when 
#		  this script is called by portage/python, caused by 
#	          "ls -c|head -n1" - Ok, that *IS* a broken pipe, "head"
#		  would not read anything more than 1 line, but I do not
#		  really understand, why it does not happen when the script
#		  is called manually -- ANY use of "head" in a pipe-construction
#		  would result in a "broken-pipe", but bash itself never  
#		  complains about that. a cosmetic change to make the 
#		  output clean and the script-code ugly :-/
# version 0.5.0 2003/08/21
#		- the exception handling for kde changed to the server
#		- this script now checks if it got a dtu or xdelta
#		- added timeout (to prevent endless loops in case of problems)
#
# version 0.4.0 2003/07/06
#		the deltup-server queues requests now
#		and sends back a document "deltup-queued"
#		the client then waits 10 seconds and tries
#		again until it either gets the dtu or a file 
#		named *.failed
# version 0.3.3 2003/05/06
#		transmit version to server
#		receive important messages from server
# version 0.3.2 2003/05/05
#		correct handle of src-archives of X11-org
# version 0.3.1 2003/04/26
#		fixed path to kde-sources on kde-mirror
# version 0.3.0 2004/04/20
#		exception: get kde-version as xdelta-files from kde-mirror
#
# version 0.2.4 2004/04/15
#		colors are now optional
#		candidates named lib* are found faster now
#		little enhancements on verbosity
# version 0.2.3 2004/04/14
#		colorized verbosity
#		fixed a bug that leaded to wrong candidates and error-outputs
# version 0.2.2 2004/04/14
#		verbosity added by wiebel
#		initialize frontmatch / backmatch with 0
# version 0.2.1 2004/04/14
#               ignore spaces and "+" in filename-mask, too
#		option REMOVE_OLD added
# version 0.2   2004/04/13
#		old files can differ by one char from the wanted file
#		to catch versions with letters in it
#
# version 0.1.1 2004/04/08
#		changed method to determine which mirror to use
#
# version 0.1
#             initial version 2004/04/06
#
#
####################################################
# NO variables to set here in the script anymore   #
# we use a config-file instead which is created    #
# and filled with some default values on first run #
# This file:                                       #
####################################################

GETDELTA_CONFIGFILE=/etc/deltup-paludis/getdelta.rc
#

splitversion(){
# $1: the version string
# output: the splitted version (1.2.3 -> 1 2 3, 10.11.12b -> 10 11 12 b)
	local vstr=$1
	shopt -s extglob
	while [ -n "$vstr" ]
	do
		case ${vstr:0:1} in
			[[:digit:]])
					echo "${vstr%%[^[:digit:]]*}"
					vstr="${vstr##+([[:digit:]])}"
					;;
			[[:alpha:]])
					nomatch="${vstr##+([[:alpha:]])*([[:digit:]])}"
					echo "${vstr:0:$((${#vstr} - ${#nomatch}))}"
					vstr="${nomatch}"
					;;
			*)		vstr="${vstr:1}"
					;;
		esac
	done
	shopt -u extglob
}

ver2ser(){
	local x=$(splitversion $1)
	x=($x)
	vser=""
	shopt -s extglob
	for ((i=0;i<${#x[@]};i++))
	do
		case ${x[$i]:0:1} in
			[[:digit:]])
				#	let ad=${x[$i]##+(0)}+1
					[ "${x[$i]##+(0)}" ] && let ad=${x[$i]##+(0)} || ad=0
					vs=$(printf "%02x" ${ad})
					vser="${vser}${vs}"
					;;
			[[:alpha:]])
					calced=0
					if [ "${x[$i]:0:3}" = "pre" ] 
					then
						vs=${x[$i]:3}
						let vser=0x${vser}00-40+${vs:-0}
						vser=$(printf "%02x" $vser)
						calced=1
					fi
					if [ "${x[$i]:0:2}" = "rc" ] 
					then
								vs=${x[$i]:2}
								let vser=0x${vser}00-40+${vs:-0}
								vser=$(printf "%02x" $vser)
								calced=1
					fi
					if [ "${x[$i]:0:5}" = "alpha" ]
					then
								vs=${x[$i]:5}
								let vser=0x${vser}00-80+${vs:-0}
								vser=$(printf "%02x" $vser)
								calced=1
					fi 
					if [ "${x[$i]:0:4}" = "beta" ]
					then
								vs=${x[$i]:4}
								let vser=0x${vser}00-60+${vs:-0}
								vser=$(printf "%02x" $vser)
								calced=1
					fi
					if [ "$calced" = "0" ] 
					then
							vs=$(echo -n ${x[$i]} | od -t x1 | head -n1| cut -d" " -f2-| tr -d " ")
							vser="${vser}${vs}"
					fi
		esac
	done
	shopt -u extglob
	let m=${#vser}%2
	[ "$m" = "1" ] && vser="0${vser}"
	echo $vser
}


# some colors for colored output
output() {
	${VERBOSITY} && echo -e "$1${NORMAL}" | tee -a $LOGFILE
}

# this checks for a variable in our config-file and adds it if does not exist
# $1 is the name of the variable, $2 the default content of the variable
# $3 a description line for the variable
add_to_configfile() {
	GETDELTA_CONFIGDIR=$(dirname $GETDELTA_CONFIGFILE )
	[ -e $GETDELTA_CONFIGFILE ] || ( mkdir -p $GETDELTA_CONFIGDIR && touch $GETDELTA_CONFIGFILE )
	if ! grep -q "$1" $GETDELTA_CONFIGFILE
	then
		echo -e "\n# ${3}\n${1}=\"${2}\"" >>$GETDELTA_CONFIGFILE
		output "${CYAN}Added new variable ${YELLOW}$1${CYAN} to config file ${GETDELTA_CONFIGFILE}\n"
		output "please check if it fits your needs\n" 
	fi
}

# this checks for an entry in our do_not_remove-file and adds it if does not exist
# $1 is the name (as grep regexp) of the file not to be removed
add_to_donotremove() {
       	
	if ! grep -q "^${1}" $DO_NOT_REMOVE
	then
		echo  "${1}" >>$DO_NOT_REMOVE
		output "${CYAN}Added new grep-regex \"${1}\" to config file ${DO_NOT_REMOVE}\n"
	fi
}
	

remove() {
	output "${GREEN}You have chosen to remove ${CYAN}$1\n"
	pushd ${DISTDIR} >/dev/null 2>&1
	removeme=true
	for n in $(grep -v "^#" ${DO_NOT_REMOVE})
	do
       		grep -q $n <<< "$1"  && removeme=false && output "${CYAN}${1}${RED} is not deleted, since it matches ${n} in ${DO_NOT_REMOVE}"
	done
	$removeme && rm -f $1
	popd >/dev/null 2>&1
}


mask_name() {
	MASK_FILENAME=$1
	# do some "blackmagic" with the src-files of xorg

	if [ $(cut -c 1-6 <<< $MASK_FILENAME) = "X11R6." ]
	then
		MASK_FILENAME=$(sed -e "s/src1/srcAAA/g" \
			-e "s/src2/srcBBB/g" \
			-e "s/src3/srcCCC/g" \
			-e "s/src4/srcDDD/g" \
			-e "s/src5/srcEEE/g" \
			-e "s/src6/srcFFF/g" \
			-e "s/src7/srcGGG/g" <<< $MASK_FILENAME)
	fi
	
	# ignore PR for src-files of firefox
	if [ $(cut -c 1-7 <<< $MASK_FILENAME) = "firefox" ]
	then
		MASK_FILENAME=$(sed -e "s/PR//g" <<< $MASK_FILENAME)
	fi
	
	# ignore "try" with new mplayer
	if [ $(cut -c 1-7 <<< $MASK_FILENAME) = "MPlayer" ]
	then
		MASK_FILENAME=$(sed -e "s/try//g" <<< $MASK_FILENAME)
	fi
	
	
	# ignore some strings in any filename
	echo $(sed -e "s/\.bz2$//g" \
		   -e "s/\.gz$//g" \
		   -e "s/[0-9]//g" \
		   -e "s/pre//g" \
		   -e "s/preview//g" \
		   -e "s/beta//g" \
		   -e "s/rc//g" \
		   -e "s/[\._-]//g" \
		   -e "s/\+//g" \
		   -e "s/ //g" <<< $MASK_FILENAME)
}

# create or update a config-file

add_to_configfile KDE_MIRROR "ftp://ftp.kde.org/pub/kde/stable" "we de not get kde-deltas from a delta-up-server, since kde provides own xdelta-files"
add_to_configfile LOCAL_MIRROR "" "set this to one or more (space separated) URI ending with '/' if you want to check one or more local mirror(s) first\n# most people just leave it empty."
add_to_configfile DELTUP_SERVER "http://linux01.gwdg.de/~nlissne/deltup.php" "deltup-server to use"
add_to_configfile FETCH "/usr/bin/wget -t 1 --passive-ftp" "command to use for downloading"
add_to_configfile QUEUERETRY 15 "number of seconds to wait before a queued request is retried"
add_to_configfile MAXIMUM_ACCEPTABLE_QUEUEPOS "15" "the maximum queuepos you would accept (if higher download full archive instead)"
add_to_configfile QUEUETIMEOUT 900 "when a dtu-request is queued - how long should we wait max. before downloading the original archive instead (in seconds)"
add_to_configfile CHECK_OLD_FILE "false" "set to \"true\", if you want getdelta.sh to use Pkunk's integrity check for the old file before downloading dtu-files"
add_to_configfile REMOVE_OLD "false" "set to \"true\", if you want getdelta.sh to delete the old file, if patch was succesful"
add_to_configfile DO_NOT_REMOVE "/etc/deltup/do_not_remove" "a list of files not to be removed by REMOVE_OLD feature"
add_to_configfile REMOVE_INCOMPLETE_OLD_FILES "false" "set this to \"true\" if you want getdelta.sh to delete old versions that seems to be corrupt,\n# or to \"false\" if you want to delete them manually\n# note: getdelta.sh will not use these files anyway"
add_to_configfile VERBOSITY true "set to \"true\", if you want verbose outputs (later to be set to a level [0-3])"
add_to_configfile COLOR true "set to \"true\", if you want colorful messages, \"false\" if not."
add_to_configfile LOGFILE "/var/log/getdelta.log" "set to a writable file (or to \"/dev/null\" if you do not want this) this is not used, if VERBOSITY is false"
add_to_configfile DELETE_LOG true "set to \"true\" if you want a temporarily log only (deleted when getdelta is finished)"
add_to_configfile SEPARATED_WINDOW "false" "set to \"true\", if you want messages from this script in a separate window\n# set to \"false\", if you do not start getdelta.sh from an Xsession or if you \n#                 do not have permissions to open terminals on the Xserver"
add_to_configfile TERM_APP "aterm -tr -trsb -fg white -bg black -sh 70 -e tail -f ${LOGFILE}" "the terminal application to use for the separated window"
add_to_configfile BANDWIDTH 1 "the bandwidth in bytes per second. configure this if you want to reduce timeouts on small files"

source $GETDELTA_CONFIGFILE

# create or update DO_NOT_REMOVE file
# these files have "old" versions that are needed to build the new versions 
# so they should never removed by the REMOVE_OLD feature
DO_NOT_REMOVE_DIR=$(dirname $DO_NOT_REMOVE)
if [ ! -e $DO_NOT_REMOVE ] 
then 
	mkdir -p $DO_NOT_REMOVE_DIR 
	echo "# This file contains regexp in 'grep-style' for files that should not be removed" >$DO_NOT_REMOVE
	echo "# if REMOVE_OLD is set to 'true'" >>$DO_NOT_REMOVE
	echo "# Some examples (actually these files are known to result" >>$DO_NOT_REMOVE
 	echo "# in problems if getdelta.sh is used with REMOVE_OLD=true" >>$DO_NOT_REMOVE
fi
add_to_donotremove "^font-arial-iso-8859"
add_to_donotremove "^libtool"
add_to_donotremove "^readline"
add_to_donotremove "^gtk-engines"
add_to_donotremove "^bash"
add_to_donotremove "^openssl"
add_to_donotremove "^curl"
add_to_donotremove "^festvox"
add_to_donotremove "^rp-pppoe"


if [ -z $1 ]
then
	COLOR=true
	echo -e "${YELLOW}getdelta.sh version ${VERSION}"
	echo "This script has to be called like this:"
	echo -e "${CYAN}$0 <URI>"
	echo -e "\n${YELLOW}To use it, you should just put the following line into your /etc/make.conf"
	echo -e "${GREEN}FETCHCOMMAND=\"$0 \\\${URI}\""
	echo -e "\n${YELLOW}There is a config-file ${CYAN}${GETDELTA_CONFIGFILE}${YELLOW} with some variables to control the behaviour of this script."
	echo -e "Edit it to your needs.${NORMAL}"
	exit 1
fi 
# include variables from gentoo make.globals and make.conf
source /etc/make.globals
source /etc/make.conf


if ${COLOR} 
then
	RED="\033[01;31m"
	GREEN="\033[01;32m"
	YELLOW="\033[01;33m"
	BLUE="\033[01;34m"
	MAGENTA="\033[01;35m"
	CYAN="\033[01;36m"
	NORMAL="\033[00m"
else
	RED=""
	GREEN=""
	YELLOW=""
	BLUE=""
	MAGENTA=""
	CYAN=""
	NORMAL=""
fi
grep -q "getdelta.sh" <<< "${RESUMECOMMAND}" && 
	output "${RED}do NOT set RESUMECOMMAND to use getdelta.sh" && 
	output "use getdelta.sh for your FETCHCOMMAND, only." &&
	sleep 5 && exit 1

pushd $DISTDIR >/dev/null 2>/dev/null
ORIG_URI=$1
NEW_FILE=$(basename $ORIG_URI)

# repoman downloads metadata.dtd with FETCHCOMMAND
# this should not be done with getdelta - so just fetch the file and exit

# Check if env.variable GETDELTA is set to 0 to disable fetching of
# dtu files.
if [ "${NEW_FILE}" = "metadata.dtd" ] || [ "$GETDELTA" = "0" ]
then
	$FETCH -O ${NEW_FILE}.-PARTIAL- $ORIG_URI
	exit $?
fi


[ -e deltup-server.msg ] && rm -f deltup-server.msg

# if output should go to an additional window start it
if $SEPARATED_WINDOW
then
	touch $LOGFILE
	$TERM_APP &
	termpid=$!
	echo -e "\x1b]1;\x07\x1b]2;getdelta.sh trying to get dtu for ${NEW_FILE}\x07"
fi

# First of all: check if LOCAL_MIRROR is set and provides the file in question already
for localn in $LOCAL_MIRROR
do
	output "${YELLOW}Trying to get ${CYAN}${NEW_FILE}${YELLOW} from local mirror ${CYAN}${localn}\n"
	if $FETCH -O ${NEW_FILE}.-PARTIAL- "${localn}${NEW_FILE}" 
	then 
		output "${GREEN}success.\n"
		exit 0
	else
		output "${RED}failed${YELLOW}\n"
	fi
done

#
# find an old file in $DISTDIR that matches the new one. This is tricky,
# and probably it will fail sometimes.
#
# we just ignore any occurence of 
# "pre","rc","[0-9]","_","-","." in the filenames and test
# if they are the same (or VERY similar (differ only in 1 char)).
# to reduce the files to check, we only check files 
# with the same beginning 
#
output "${GREEN}Searching for a previously downloaded file in ${YELLOW}${DISTDIR}\n"

first_chars=$(sed 's/[[:digit:]][[:print:]]*$//' <<< $NEW_FILE)
length_first_chars=$(wc -c <<< $first_chars)
[ $length_first_chars -lt 3 ] && first_chars=$(cut -c 1-2 <<< $NEW_FILE)

# if filename is lib* use first 4 letters to increase performance
[ "$( cut -c 1-3 <<< $NEW_FILE )" = "lib" ] && 
[ $length_first_chars -lt 5 ] && first_chars=$(cut -c 1-4 <<< $NEW_FILE)
 
mask=$(mask_name "${NEW_FILE}")
let len1=$(wc -c <<< $mask)-1
filelist=""

for name in $( ls ${first_chars}* 2>/dev/null )
do
	mask2=$(mask_name "${name}")
	# add any file, that results in the same mask or differ not more than two letters
	let len2=$(wc -c <<< $mask2)-1
	if [ $len1 -gt $len2 ] 
	then
		max=${len1}
		let min=${len2}
	else
		let min=${len1}
		max=${len2}
	fi
	let df=${max}-${min} 
	
	# if masks differ in length more than 1 they cannot match
	if [ $df -le 1 ] 
	then
		let frontmatch=0
		let backmatch=0
		for ((ch=1;ch<=min;ch++))
		do
			if [ $(cut -c ${ch} <<< ${mask}) = $(cut -c ${ch} <<< ${mask2}) ] 
			then frontmatch=${ch}
			else break
			fi
		done
		
		# now backwards
		mask=$(rev <<< ${mask})
		mask2=$(rev <<< ${mask2})
		for ((ch=1;ch<=min;ch++))
		do
			if [ $(cut -c ${ch} <<< ${mask} ) = $(cut -c ${ch} <<< ${mask2}) ]
			then backmatch=${ch}
			else break
			fi
		done
		
		# forwards for mask again (need this for the next run of the loop)
		mask=$(rev <<< ${mask})
					
		let matchall=${frontmatch}+${backmatch}
		let minmatch=${min}-1
		[ ${matchall} -ge ${minmatch} ] && filelist="${filelist} $name"
	fi
done

if ! [ -z "$filelist" ] 
then 
	# we have got a list of candidates in $filelist now. find the best match .
	output "${GREEN}We have the following candidates to choose from \n${YELLOW}`sed -e \"s/\ /\\n/g\" <<< $filelist` \n"

	# find matching part of filename - first: frontmatch
	x=0;
	a=($NEW_FILE $filelist)
	match=""
	while [ -z "$match" ]
	do
		for ((i=0;i<${#a[@]};i++))
		do
			[ ${a[0]:${x}:1} != ${a[$i]:${x}:1} ] &&  match=$x
		done
		((x++))
	done
	frontmatch=${a[0]:0:${match}}

	# find matching part of filename - second: backmatch
	x=1;
	match=""
	while [ -z "$match" ]
	do
		for ((i=0;i<${#a[@]};i++))
		do
			[ ${a[0]:${#a[0]}-${x}:1} != ${a[$i]:${#a[$i]}-${x}:1} ] &&  match=$x
		done
		((x++))
	done
	((match--))
	backmatch=${a[0]:${#a[0]}-${match}}
	
	# isolate version from filename (foobar-1.2.3.tar.gz -> 1.2.3)
	new_version=${NEW_FILE#${frontmatch}}
	new_version=${new_version%${backmatch}}
	new_serial=$(ver2ser $new_version)
	# find length for comparison
	maxlength=0
	for name in $filelist
	do
		old_version=${name#${frontmatch}}
		old_version=${old_version%${backmatch}}
		old_serial=$(ver2ser $old_version)
		cm1=$new_serial
		cm2=$old_serial
		while [ ${#cm1} -gt ${#cm2} ] ; do cm2="${cm2}00" ; done
		while [ ${#cm2} -gt ${#cm1} ] ; do cm1="${cm1}00" ; done
		[ ${#cm1} -gt ${maxlength} ] && maxlength=${#cm1}
	done
	# add 00 until length of serial matches maxlength
	while [ ${#new_serial} -lt ${maxlength} ] ; do new_serial="${new_serial}00"; done
	# now find the candidate with the lowest difference to new_serial
	for name in $filelist
	do
		old_version=${name#${frontmatch}}
		old_version=${old_version%${backmatch}}
		old_serial=$(ver2ser $old_version)
		while [ ${#old_serial} -lt ${maxlength} ] ; do old_serial="${old_serial}00"; done
		let new_s=0x${new_serial}
		let old_s=0x${old_serial}
		if [ $new_s -gt $old_s ]
		then
			let serial_diff=0x${new_serial}-0x${old_serial}
		else
			let serial_diff=0x${old_serial}-0x${new_serial}
		fi
		if [ $serial_diff -le ${minimal_diff:-${serial_diff}} ] 
		then
			best_candidate="$name"
			minimal_diff=${serial_diff}
		fi
	done

	output "${GREEN}The best of all is ... ${CYAN}${best_candidate}\n"
	output "${YELLOW}Checking if this file is OK.\n"
	
	# this part is based on Pkunk's code posted on http://bugs.gentoo.org/show_bug.cgi?id=63525
	# but with some changes
	FILE_IS_CORRUPT=false
	if $CHECK_OLD_FILE 
	then
		file_digest=$(grep -h ${best_candidate} ${FILESDIR}/digest-* | sed -n 1p)
		if [ ! -z "$file_digest" ]
		then
			file_md5=$(cut -d ' ' -f2 <<< $file_digest) 
			file_origsize=$(cut -d ' ' -f4 <<< $file_digest)
			file_currentsize=$(stat -c %s ${best_candidate})
			if [ $file_currentsize -ne $file_origsize ]
			then
				output "${RED}Found ${best_candidate}, but filesize ${CYAN}${file_currentsize} ${RED} does not match ${CYAN}${file_origsize} (found in digest-file)\n"
				FILE_IS_CORRUPT=true
			fi
		else
			if [ $(rev <<< ${best_candidate} | cut -d. -f2 | rev) = "tar" ]
			then
				output "${YELLOW}Could not find a digest-file for ${CYAN}${best_candidate}${YELLOW}. Testing file integrity with tar.\n"
				case $(rev <<< ${best_candidate} | cut -d. -f1 | rev) in
					gz) tarparm=z
						;;
					bz2) tarparm=j
						;;
				esac
			
				if ! tar -${tarparm}tf ${best_candidate} >/dev/null
				then
					output "${RED}reported an error while testing ${CYAN}${best_candidate}${RED} - so this file is unusable.\n"
					FILE_IS_CORRUPT=true
				fi
			
				if $FILE_IS_CORRUPT && $REMOVE_INCOMPLETE_OLD_FILES
				then
					output "${YELLOW}You have chosen to automatically delete such broken files from your distfiles-directory, so here we go...\n"
					remove ${best_candidate}
				fi
			fi
		fi
	fi
	# end of file-corruption check for $best_candidate found in distfiles
	if ! $FILE_IS_CORRUPT
	then
		
		QUERY_URL=$(GENTOO_MIRRORS="" emerge -fp =${CATEGORY}/${PF} 2>&1 | 
			    sed -e "s/ /\\n/g" | egrep "(http|ftp)://" | 
			    grep "${NEW_FILE}" | tail -n 1)
		query="?have=${best_candidate}&want=${NEW_FILE}&url=${QUERY_URL}&version=${VERSION}&time=$(date +%s)"
		output "${GREEN}Trying to download ${YELLOW}${best_candidate}-${NEW_FILE}.dtu\n"

		# Remember where we are, and go to a new dir there we can work
		tmp_dwn_dest="${DISTDIR}/.getdelta-`date +%N`-tmp"
		mkdir ${tmp_dwn_dest}
		# If user abort Ctrl+C (signal 2), remove tmp-dir; enabable trap again and send it again to stop wget
		trap "rm -r ${tmp_dwn_dest}; trap 2; kill -2 $$" 2
		pushd ${tmp_dwn_dest} >/dev/null 2>&1

		# thanks to MATSUI Fe2+ Tetsushi for idea and patch
		FILESIZE=$(stat -c %s "${DISTDIR}/${best_candidate}")
		let TIMELIMIT=${FILESIZE}/${BANDWIDTH}
		[[ $TIMELIMIT -lt $QUEUETIMEOUT ]] && QUEUETIMEOUT=$TIMELIMIT
			
		if $FETCH "${DELTUP_SERVER}${query}"
		then
			# thanks to deelkar for this much more elegant solution to the "broken pipe" problem with "head -n1"
			GOTFILE=$(ls -c | sed -n 1p) 
			output "${YELLOW}GOT ${CYAN}${GOTFILE}\n"
			
			# There are some possibilities what the deltup-server
			# may have sento to us.
			
			# first: the request have been queued
			if [ "${GOTFILE}" = "deltup-queued" ]
			then 
				let QTMOUT=$(date +%s)+QUEUETIMEOUT
				while [ -f deltup-queued ]
				do
					output "${GREEN}destination file: ${CYAN}${NEW_FILE}\n"
					output "${YELLOW}$(cat deltup-queued)"
					QUEUEPOS=$(grep "has been queued" deltup-queued | cut -d. -f2 | cut -d")" -f1)
					rm -f deltup-queued
					TSTAMP=$(date +%s)
					if ((TSTAMP<QTMOUT)) && ((QUEUEPOS<=MAXIMUM_ACCEPTABLE_QUEUEPOS))
					then
						for ((sec=QUEUERETRY;sec>0;sec--))
						do
							if ((sec>1)) 
							then
							  ${VERBOSITY} && echo -n -e "${YELLOW}  I will try again in ${sec} seconds.  \r" 
							else
							  ${VERBOSITY} && echo -n -e "${YELLOW}  I will try again in ${sec} second.  \r" 
							fi
							sleep 1
						done
						echo -n -e "${NORMAL}"
						$FETCH "${DELTUP_SERVER}${query}"
						GOTFILE=$(ls -c | sed -n 1p)
					else
						if ((TSTAMP>=QTMOUT))
						then 
							GOTFILE="timeout"
							output "\n${RED}TIMEOUT exceeded.\n"
							break
						fi
						if ((QUEUEPOS>MAXIMUM_ACCEPTABLE_QUEUEPOS))
						then
							GOTFILE="unacceptable"
							output "\n${RED}You have configured getdelta.sh not to accept this queue-position.\n"
							output "${YELLOW}We are going to download the ${RED}full archive${YELLOW} instead.\n"
							break
						fi 
					fi
				done
			fi
			
			if [ -f ${best_candidate}-${NEW_FILE}.failed ]
			then
				output "\n${RED}The server could not build the dtu-file for ${NEW_FILE}\n" 
				output "${YELLOW}reason:\n${RED}$(cat ${best_candidate}-${NEW_FILE}.failed)\n" 
				rm -rf ${best_candidate}-${NEW_FILE}.failed
			fi

			if [ -f ${best_candidate}-${NEW_FILE}.dtu ]
			then
				output "${GREEN}Successfully fetched the dtu-file - let's build ${NEW_FILE}...\n" 
				downloadsize=$(stat -c %s  ${best_candidate}-${NEW_FILE}.dtu)
				if deltup -p -v -D ${DISTDIR} ${best_candidate}-${NEW_FILE}.dtu 
				then 
					newsize=$(stat -c %s ${NEW_FILE})
					let savedsize=${newsize}-${downloadsize}
					let percent=${savedsize}*100/${newsize}
					unit="bytes"
					[ $savedsize -gt 1024 ] && let savedsize=$savedsize/1024 && unit="kB"
					[ $savedsize -gt 1024 ] && let savedsize=$savedsize/1024 && unit="MB"
					
					case $unit in
					bytes) UCOLOR=${RED}
						;;
					kB)	UCOLOR=${YELLOW}
						;;
					MB)	UCOLOR=${GREEN}
						;;
					esac
					output "${YELLOW}This dtu-file saved ${UCOLOR}${savedsize} ${unit} (${percent}%)${YELLOW} download size.\n"
				fi
				mv -f ${NEW_FILE} ${DISTDIR} &&
				${REMOVE_OLD}  && remove "${best_candidate}"
			fi

			FILEEXT=$(rev <<< $GOTFILE | cut -c 1-11 | rev)
			if [ $FILEEXT = ".tar.xdelta" ]
			then
				# we haven't received a dtu-file, but an xdelta instead 
				# this means the deltup-server redirected us to ftp.kde.org
				# to get the official delta-file from there
				output "${GREEN}This is an xdelta from ftp.kde.org...\n" 
				output "${GREEN}Applying...\n" 

				bunzip2 ${DISTDIR}/${best_candidate}
				xdelta patch $GOTFILE
				if ${REMOVE_OLD}
				then
					remove "$(rev <<< ${best_candidate} | cut -c 5- | rev)"
				else
					bzip2 $(rev <<< ${best_candidate} | cut -c 5- | rev)
				fi
				bzip2 $(rev <<< $NEW_FILE | cut -c 5- | rev)
				rm -f $GOTFILE
				mv -f ${NEW_FILE} ${DISTDIR}
				output "${GREEN}Succesfully done\n" 
			fi
		fi # if $FETCH "${DELTUP_SERVER}${query}"
		
		# Clean up.
		# We might got an important message
		if [ -f ${tmp_dwn_dest}/deltup-server.msg ]
		then
			echo -e "${RED}IMPORTANT MESSAGE FROM DELTUP-SERVER${YELLOW}$(cat  ${tmp_dwn_dest}/deltup-server.msg)\n" 
			for ((i=1;i<=5;i++)) 
			do
				echo -n -e "\a"
				sleep 1
			done
			echo -e "${YELLOW}PRESS ENTER TO DOWNLOAD FROM ORIGINAL URL"
			echo -e "${GREEN}or CTRL-C to cancel${NORMAL}"
			read
		fi
		popd >/dev/null 2>&1
		rm -rf ${tmp_dwn_dest}
		#stop respond to trap2
		trap 2
	fi # if ! FILE_IS_CORRUPT
else # if ! [ -z "$filelist" ] 
	# No filelist - probably we do not have an old version of the file
	output "${RED}No old version of the requested file found.\n" 	
fi

	
# Ok, once we are here, we should have got the delta (and used it)
# or we still have to download the full file
if ! [ -f ${DISTDIR}/${NEW_FILE} ] 
then
	output "${RED}The dtu could not be fetched,${YELLOW} downloading full file from original URL\n"
	$FETCH -O ${NEW_FILE}.-PARTIAL- $ORIG_URI
# remember we had a fallback to use correct exitcode for portage
	FALLBACK=$?
fi


if $SEPARATED_WINDOW 
then
	sleep 3
	kill $termpid
fi

$DELETE_LOG && : >$LOGFILE

popd >/dev/null 2>&1


if ! [ -z $FALLBACK ]
then
	exit $FALLBACK
fi
