# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit eutils linux-info versionator

EXPORT_FUNCTIONS pkg_postinst

# @FUNCTION: last_arg
# @USING: last_arg manyarguments
# @DESCRIPTION:
# print last argument
last_arg() {
	shift $(( $# - 1 ))
	echo $1
}

# @FUNCTION: rm_link_with_file
# @USING: rm_link_with_file filename
# @DESCRIPTION:
# delete the file, and if it is symbolic then delete the file,
# which point out a link
rm_link_with_file() {
	[[ -L $1 ]] && rm -f `readlink -f $1`
	rm -f $1
}

# @FUNCTION: cp_link_with_file
# @USING: cp_link_with_file filename suffix
# @DESCRIPTION:
# copy the file with the same name with the suffix, and if it is a symbolic
# link, then also copy the target file with the addition of the suffix
cp_link_with_file() {
	if [[ -L $1 ]]
	then
		rm -f `readlink -f ${1}`$2
		cp -aH ${1} `readlink -f ${1}`$2
		ln -sf `readlink ${1}`${2} ${1}${2}
	else
		rm -f ${1}${2}
		cp -aH ${1} ${1}${2}
	fi
}

# @FUNCTION: make_old_file
# @USAGE: make_old_file filename 
# @DESCRIPTION:
# wear out a file, copy the file, adding its name suffix ". old"
# support symbolic link
make_old_file() {
	if [[ -e $1 ]]
	then
		rm_link_with_file $1.old
		cp_link_with_file $1 .old
	fi
	rm_link_with_file $1
}

# @FUNCTION: update_file
# @USAGE: wear_out_file filename link
# @DESCRIPTION:
# update a file from filename-installed, and make old file if need
update_file() {
	# if newest file is absent
	[[ -e $1-installed ]] || return 1
	# link and filename exist
	if [[ `readlink -f $2` == `readlink -f $1` ]]
	then
		make_old_file $2
	else
		# rename link to link.old
		mv $2 $2.old &>/dev/null
		# make old filename
		make_old_file $1
		# fix link pointed to previous filename
		find -lname "$1" -exec ln -sf $1.old {} \;
	fi
	# make link to filename
	ln -sf `basename $1` $2
	# rename installed
	mv $1-installed $1
}

# @FUNCTION: detect_linux_shortname
# @USAGE: 
# @DESCRIPTION:
# Detect calculate linux shortname by /etc/make.profile
detect_linux_shortname() {
	local makeprofile=$(readlink ${ROOT}/etc/make.profile)
	local profile=
	local system=
	local shortname=
	while [[ $profile != "calculate" && $profile != "." ]]
	do
		shortname=$system
		system=$profile
		profile=$(basename $makeprofile)
		makeprofile=$(dirname $makeprofile)
	done
	if [[ $profile == "calculate" ]]
	then
		echo $shortname
	else
		echo "gentoo"
	fi
}

# @FUNCTION: calculate_update_kernel
# @USAGE: [kernelname] [kernelversion] [destination]
# @DESCRIPTION:
# Make symbolic link to vmlinuz, preserve old vmlinuz
# Copy initramfs to initrd and initrd-install
calculate_update_kernel() {
	kversion=$1
	dir=$2

	# update vmlinuz
	update_file ${dir}/vmlinuz-${kversion} ${dir}/vmlinuz
	# update initrd
	update_file ${dir}/initramfs-${kversion} ${dir}/initrd
	# update initrd-install
	update_file ${dir}/initramfs-${kversion}-install ${dir}/initrd-install
	# update System.map
	update_file ${dir}/System.map-${kversion} ${dir}/System.map
	# update config-{KV_FULL}
	make_old_file ${dir}/config-${kversion}
	mv ${dir}/config-${kversion}-installed ${dir}/config-${kversion}

	ebegin "Trying to optimize initramfs"
	( which calculate &>/dev/null && calculate --initrd ) && eend 0 || eend 1
	if [[ "$(md5sum ${ROOT}/boot/initrd | awk '{print $1}')" == \
		"$(md5sum ${ROOT}/boot/initrd-install | awk '{print $1}')" ]]
	then
		ewarn
		ewarn "Perform command after reboot for optimization initramfs:"
		ewarn "  calculate --initrd"
	fi
}

is_broken_link() {
	fname=$1
	[[ -n $( file $fname | grep "broken symbolic link" ) ]] &&
		return 0 ||	return 1
}

# @FUNCTION: calculate_restore_kernel
# @USAGE: [destination]
# @DESCRIPTION:
# Restore vmlinux.old and initrd.old in destination
calculate_restore_kernel() {
	dir=$1

	# restore vmlinuz
	is_broken_link ${dir}/vmlinuz && [ -f ${dir}/vmlinuz.old ] &&
		mv ${dir}/vmlinuz.old ${dir}/vmlinuz

	# resotre initrd
	is_broken_link ${dir}/initrd && [ -f ${dir}/initrd.old ] &&
		mv ${dir}/initrd.old ${dir}/initrd

	# restore System.map
	is_broken_link ${dir}/System.map && [ -f ${dir}/System.map.old ] &&
		mv ${dir}/System.map.old ${dir}/System.map
}

TMP_INITRAMFS=${T}/initramfs
SPLASH_DESCRIPTOR=/etc/splash/tty1/1024x768.cfg

# @FUNCTION: calculate_rm_modules_dir
# @USAGE: [CONTENTS]
# @DESCRIPTION:
# Remove installed files from lib/modules specified by CONTENTS file.
# For work need specify and create SLOT_T directory for .alreadydel flag file,
# which determined was or not file removing.
calculate_rm_modules_dir() {
	PKG_CONTENTS=$1
	[[ -f ${SLOT_T}/.alreadydel ]] && return 0 || 
		touch ${SLOT_T}/.alreadydel &>/dev/null
	addwrite "/lib/modules"
	DIRRM=$( sed -rn '/^dir.*lib\/modules/ s/^\S+\s+(\S+)\s*.*$/\1/p' \
		${PKG_CONTENTS} | sort -r)
	FILERM=$( sed -rn '/^(obj|sym).*lib\/modules/ s/^\S+\s+(\S+)\s+.*$/\1/p' ${PKG_CONTENTS} )
	if [[ -n ${FILERM} ]]
	then
		for f in ${FILERM}
		do
			rm -f $f 
		done
	fi
	if [[ -n ${DIRRM} ]]
	then
		for f in ${DIRRM}
		do
			rmdir $f &>/dev/null
		done
	fi
}

initramfs_unpack() {
	mkdir -p ${TMP_INITRAMFS}
	cd ${TMP_INITRAMFS}
	# select arch
	UNPACKER="gzip"
	lzma --force -t $1 &>/dev/null && UNPACKER="lzma"
	# unpack initramfs
	${UNPACKER} -dc $1 | cpio -di &>/dev/null
	return $?
}

initramfs_change_spalsh() {
	if [ -f ${ROOT}${SPLASH_DESCRIPTOR} ]
	then
		# get silentpic param
		SILENTPIC=$( sed -nr '/^silentpic/ s/^[^=]+=(.*)$/\1/p' \
			${ROOT}${SPLASH_DESCRIPTOR} )
		# get pic param
		PIC=$( sed -nr '/^pic/ s/^[^=]+=(.*)$/\1/p' \
			${ROOT}${SPLASH_DESCRIPTOR} )
		if [ -f ${ROOT}${SILENTPIC} ] && [ -f ${ROOT}${PIC} ]
		then
			cp ${ROOT}${SPLASH_DESCRIPTOR} \
					${TMP_INITRAMFS}${SPLASH_DESCRIPTOR} &&
				mkdir -p ${TMP_INITRAMFS}${SILENTPIC%$(basename $SILENTPIC)} &&
				cp ${ROOT}${SILENTPIC} ${TMP_INITRAMFS}${SILENTPIC} &&
				mkdir -p ${TMP_INITRAMFS}${PIC%$(basename $PIC)} &&
				cp ${ROOT}$PIC ${TMP_INITRAMFS}${PIC}
			return $?
		fi
	else
		return 1
	fi
}

initramfs_pack() {
	# pack new initramfs
	cd ${TMP_INITRAMFS}
	find * | cpio -o --quiet -H newc | gzip -9 >$1
}

# @FUNCTION: calculate_update_splash
# @USAGE: [initramfsfile]
# @DESCRIPTION:
# Install into initramfs splash data, which descripted by
# /etc/splash/tty1/1024x768.cfg
calculate_update_splash() {
	local initrdfile=$1
	if which splash_geninitramfs &>/dev/null && \
		[[ -e /etc/splash/tty1 ]]
	then
		ebegin "Update splash screen for $1"
		if [[ -L $initrdfile ]]
		then
			initrdfile=$(readlink -f $initrdfile)
		fi
		if [[ -f $initrdfile ]]
		then
			splash_geninitramfs -a $initrdfile tty1 &>/dev/null
			eend $?
		else
			eend 1
		fi
	fi 
}

# @FUNCTION: calculate_set_kernelversion
# @USAGE: KERNEL_DIR
# @DESCRIPTION:
# Change version in Makefile of kernel sources on version specified by
# variables KV_MAJOR KV_MINOR KV_PATCH KV_TYPE
calculate_set_kernelversion() {
	KERNEL_DIR=$1
	sed -ri "s/^VERSION = .*$/VERSION = $KV_MAJOR/" \
		${KERNEL_DIR}/Makefile
	sed -ri "s/^PATCHLEVEL = .*$/PATCHLEVEL = $KV_MINOR/" \
		${KERNEL_DIR}/Makefile
	sed -ri "s/^SUBLEVEL = .*$/SUBLEVEL = $KV_PATCH/" \
		${KERNEL_DIR}/Makefile
	sed -ri "s/^EXTRAVERSION = .*$/EXTRAVERSION = $KV_TYPE/" \
		${KERNEL_DIR}/Makefile
}

# FUNCTION: calculate_update_modules
# DESCRIPTION:
# It calls the update-modules utility. Get from linux-mod.
calculate_update_modules() {
	if [ -x /sbin/update-modules ] && \
		grep -v -e "^#" -e "^$" "${D}"/etc/modules.d/* >/dev/null 2>&1; then
		ebegin "Updating modules.conf"
		/sbin/update-modules
		eend $?
	elif [ -x /sbin/update-modules ] && \
		grep -v -e "^#" -e "^$" "${D}"/etc/modules.d/* >/dev/null 2>&1; then
		ebegin "Updating modules.conf"
		/sbin/update-modules
		eend $?
	fi
}

# FUNCTION: calculate_update_depmod
# DESCRIPTION:
# It updates the modules.dep file for the current kernel.
# Get from linux-mod.
calculate_update_depmod() {
	# if we haven't determined the version yet, we need too.
	get_version;

	ebegin "Updating module dependencies for ${KV_FULL}"
	if [ -r "${KV_OUT_DIR}"/System.map ]
	then
		depmod -ae -F "${KV_OUT_DIR}"/System.map -b "${ROOT}" -r ${KV_FULL}
		eend $?
	else
		ewarn
		ewarn "${KV_OUT_DIR}/System.map not found."
		ewarn "You must manually update the kernel module dependencies using depmod."
		eend 1
		ewarn
	fi
}

# FUNCTION: calculate_clean_firmwares
# DESCRIPTION:
# Workaround kernel issue with collising
# firmwares across different kernel versions
calculate_clean_firmwares() {
	for fwfile in `find "${ROOT}/tmp/firmware" -type f`; do
		sysfile="${ROOT}/lib/${fwfile/${ROOT}/tmp/}"
		if [ -f "${sysfile}" ]; then
			#ewarn "Removing duplicated: ${sysfile}"
			rm ${sysfile} || die "failed to remove ${sysfile}"
		fi
	done
}

# FUNCTION: get_value
# DESCRIPTION:
# Get the value of the variable from stdio.
get_value() {
	sed -rn "s/^(.*\s+)?+$1=\"?([^\" ]*)\"?(\s+.*|$)/\2/p"
}

# FUNCTION: set_value
# DESCRIPTION:
# Set the value to the variable in the file
set_value() {
	local var=$1
	local value=$2
	local filename=$3
	[[ -n $( get_value $var < $filename ) ]] &&
		sed -ri "s/^$var=(\"?[^\"]*\"?)$/$var=$value/" $filename ||
		echo "$var=$value" >>$filename
}

# @VARIABLE: CALCULATE_INI
# @DESCRIPTION:
# Fullpath to calculate.ini
CALCULATE_INI=${ROOT}/etc/calculate/calculate.ini
# @VARIABLE: LINUXVER
# @DESCRIPTION:
# The version of current operation system.
LINUXVER=
# @VARIABLE: ROOTDEV
# @DESCRIPTION:
# Boot device.
ROOTDEV=

# FUNCTION: change_issue
# DESCRIPTION:
# Change version in /etc/issue
change_issue() {
	sed -ri "s/${LINUXVER}/${PV}/" ${ROOT}/etc/issue
}

# FUNCTION: change_grub
# DESCRIPTION:
# Change version for grub
change_grub() {
	sed -ri "/^title/ {:f;N;s/\nkernel/&/;tc;bf;:c;s|root=${ROOTDEV}|&|;Te;s/ ${LINUXVER} / $PV /;:e}" /boot/grub/grub.conf
}

# FUNCTION: calculate_initvars
# DESCRIPTION:
# Init LINUXVER,ROOTDEV
calculate_initvars() {
	makeProfile=/etc/make.profile
	if [[ -f ${CALCULATE_INI} ]]
	then
		LINUXVER=$( get_value linuxver < ${CALCULATE_INI} )
	else
		LINUXVER=10
		if [[ $(readlink $makeProfile) =~ \
			.*(calculate/(server|desktop)/([^/]+)/).* ]]
		then
			CALCULATEDISTRO=$(echo ${BASH_REMATCH[3]} | tr [:upper:] [:lower:])
			metaPkgFile=/var/db/pkg/app-misc
			if [[ "$(ls $metaPkgFile | grep ${CALCULATEDISTRO}-meta)" =~ \
				${CALCULATEDISTRO}-meta-((.*?)-r[0-9]+|(.*?)) ]]
			then
				if [[ -n ${BASH_REMATCH[2]} ]]
				then
					LINUXVER=${BASH_REMATCH[2]}
				else
					LINUXVER=${BASH_REMATCH[3]}
				fi
			fi
		fi
	fi
	ROOTDEV=$( get_value root < ${ROOT}/proc/cmdline )
}

# FUNCTION: calculate_change_version
# DESCRIPTION:
# Change the version of the system in calculate.ini,issue,grub.conf
calculate_change_version() {
	calculate_initvars
	if [[ -n "${LINUXVER}" ]] && ! version_is_at_least ${PV} ${LINUXVER}
	then
		ebegin "Change version of operation system"
			change_issue &&
			change_grub
		eend $?
	fi
}

# FUNCTION: get_last_filename
# DESCRIPTION:
# Get latest regular file by name
get_last_filename() {
	findfiles=$(ls -d $1/$2*$3 2>/dev/null)
	if [[ -n $findfiles ]]
	then
		for line in $findfiles
		do
			if [[ $(LANG=C stat -c %F $line) == "regular file" ]]
			then
				echo $(stat -c %Y $line) $line
			fi
		done | sort | tail -1 | awk '{print $2}'
	fi
}

# FUNCTION: calculate_get_current_initrd
# DESCRIPTION:
# Get current initrd or initrd with suffix
calculate_get_current_initrd() {
	calculate_initvars
	local suffix=$1
	if [[ -f /boot/grub/grub.conf ]]
	then
		filename=$(sed -nr "/^title/{            #find title in grub.conf
		:readnextline;N;                         #read next line
		s/\ninitrd/&/;                           #if pattern not contents initrd 
		Treadnextline;                           #goto read next line
		s|root=${ROOTDEV}.*initrd.*${suffix}|&|; #if menuitem not for this system
		Tskipmenuitem;                           #then skip menuitem
		s|^.*initrd (.*)$|\1|p;                  #display initramfs
		q;
		:skipmenuitem;
		d;
		}" /boot/grub/grub.conf)
		if [[ -z $filename ]]
		then
			get_last_filename /boot initr ${suffix}
		else
			echo $filename
		fi
	else
		get_last_filename /boot initr ${suffix}
	fi
}

calculate_pkg_postinst() {
	case "${PN}" in 
		cld-themes|cmc-themes|cds-themes|cls-themes|cldg-themes|cldx-themes)
			local initrdfile=$(calculate_get_current_initrd)
			local initrdinstallfile=$(calculate_get_current_initrd -install)
			[[ -f ${ROOT}${initrdfile} ]] &&
				calculate_update_splash ${ROOT}${initrdfile}
			[[ -f ${ROOT}${initrdinstallfile} &&
				"${ROOT}${initrdinstallfile}" != "${ROOT}${initrdfile}" ]] &&
				calculate_update_splash ${ROOT}${initrdinstallfile}
			;;
	esac
}
