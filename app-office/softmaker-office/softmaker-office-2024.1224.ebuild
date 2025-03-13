# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg-utils

DESCRIPTION="SoftMaker Office - an office suite featuring a word processor (TextMaker), spreadsheets (PlanMaker) and slides software (Presentations)"
HOMEPAGE="https://www.softmaker.com/en/softmaker-office"

SRC_URI="https://www.softmaker.net/down/softmaker-office-${PV//\./-}-amd64.tgz"

LICENSE="SoftMakerOffice"
SLOT="0"

# empty keywords = hardmask
# reason: Products got split, subscription no longer unlocks 2024 but the separate NX product.
#         I have the subscription so I cannot maintain this ebuild any more.
#         Use app-office/softmaker-office-nx instead if you have the subscription.
#         The ebuild is still here for reference if someone wants to pick it up, I was already
#         done adapting it before I noticed that my product key does not unlock the installation.
#KEYWORDS=""

KEYWORDS="~amd64"

# .deb dependencies as of 20 Jun 2023, version 2024-1200:
#
#   DEBIAN                                        GENTOO
#
#   libcurl4 | libcurl3 (>= 7.16.2)            => net-misc/curl
#   libc6 (>= 2.17)                            => sys-libs/glibc
#   libgcc1 (>= 1:4.2)                         => sys-devel/gcc
#   libgl1-mesa-glx | libgl1                   => virtual/opengl
#   libglib2.0-0 (>= 2.12.0)                   => dev-libs/glib *
#   libgstreamer1.0-0 (>= 1.0.0)               => media-libs/gstreamer *
#   libgstreamer-plugins-base1.0-0 (>= 1.0.0)  => media-libs/gst-plugins-base
#   libstdc++6 (>= 5.2)                        => sys-devel/gcc
#   libx11-6                                   => x11-libs/libX11
#   libxext6                                   => x11-libs/libXext
#   libxmu6                                    => x11-libs/libXmu
#   libxrandr2 (>= 2:1.2.99.3)                 => x11-libs/libXrandr
#   libxrender1                                => x11-libs/libXrender

DEPEND="
	app-arch/tar
	app-arch/xz-utils
"
RDEPEND="${DEPEND}
	net-misc/curl
	sys-libs/glibc
	sys-devel/gcc
	virtual/opengl
	dev-libs/glib
	media-libs/gstreamer
	media-libs/gst-plugins-base
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXmu
	x11-libs/libXrandr
	x11-libs/libXrender
"

S="${WORKDIR}"

INNER_ARCHIVE="office2024.tar.lzma"
EXTRACTED_INNER_ARCHIVE="${WORKDIR}/extracted"

FINAL_INSTALL_DIR="/opt/softmaker-office"
INSTALL_DIR="${D}${FINAL_INSTALL_DIR}"

# disable QA check for pre-stripped binaries
QA_PRESTRIPPED="
	${FINAL_INSTALL_DIR}/dpf3/libCSegmentation.so
	${FINAL_INSTALL_DIR}/dpf3/libCTokenizer.so
	${FINAL_INSTALL_DIR}/dpf3/libDpfDict.so
	${FINAL_INSTALL_DIR}/dpf3/libgamorphDpf.so
	${FINAL_INSTALL_DIR}/dpf3/libSGAnalyseSP.so
	${FINAL_INSTALL_DIR}/dpf3/libsprt4-7-0-instance-01.so
	${FINAL_INSTALL_DIR}/dpf3/libsprt4-7-0-instance-02.so
	${FINAL_INSTALL_DIR}/dpf3/libsprt4-7-0-instance-03.so
	${FINAL_INSTALL_DIR}/dpf3/libsprt4-7-0.so
	${FINAL_INSTALL_DIR}/dpf3/libsx.so
	${FINAL_INSTALL_DIR}/textmaker
	${FINAL_INSTALL_DIR}/presentations
	${FINAL_INSTALL_DIR}/planmaker
"

# disable QA checks for upstream .desktop files
QA_DESKTOP_FILE="
	usr/share/applications/planmaker-2024.desktop
	usr/share/applications/presentations-2024.desktop
	usr/share/applications/textmaker-2024.desktop
"

src_unpack() {
	unpack ${A} || "Failed to unpack outer archive"

	mkdir ${EXTRACTED_INNER_ARCHIVE}
	cd ${EXTRACTED_INNER_ARCHIVE} || die "Failed to switch to extraction directory"

	tar xJf ${WORKDIR}/${INNER_ARCHIVE} || die "Failed to extract ${INNER_ARCHIVE}"
}

src_prepare() {
	## extract all lines defining functions from original install script so we can import it
	# first make sure we actually have the expected revision
	expected_hash="e3640f93e074c49bb5504ff0827213e7"
	actual_hash=$(md5sum "${WORKDIR}/installsmoffice" | cut -c'-32')
	[[ "${actual_hash}" == "${expected_hash}" ]] || die "Unexpected file hash on install script, unable to extract functions. Expected MD5 ${expected_hash}, got: ${actual_hash}"

	# extract
	tail -n 1592 ${WORKDIR}/installsmoffice | head -n 1354 >${WORKDIR}/smoffice-install-functions.sh

	# mandatory since EAPI 6
	eapply_user
}

src_compile() {
	. ${WORKDIR}/smoffice-install-functions.sh

	# set variables needed by original install script
	APPBINPATH="${WORKDIR}" # install script function will write there during installation
	SRCPATH="${EXTRACTED_INNER_ARCHIVE}" # install script function will read from there during installation
	APPPATH="${FINAL_INSTALL_DIR}" # generated script will run files from there after installation

	## create_script
	UNINSTALLSCRIPT="${APPBINPATH}/uninstall_smoffice2024" # irrelevant but function will generate that file nevertheless
	REMOVEICONSSCRIPT="${APPBINPATH}/remove_icons.sh" # also irrelevant but needed

	# somehow the base file for the (irrelevant) uninstall script does not exist after unpacking, replace by dummy
	echo '#dummy' >$SRCPATH/mime/uninst1

	# run original create_script function
	# arg 1 = version
	# arg 2 = fixed to "1" by original install script
	# arg 3 = empty to indicate global installation
	(set -e; create_script 2024 "1" "") || die "Failed to run original create_script"

	## create_desktop1 to create .desktop files
	# run original create_desktop functions
	# arg 1 = version
	# arg 2 = "0" assumes /usr/bin for installation, "1" uses APPBINPATH which would be wrong for this ebuild
	(set -e; create_desktop1 2024 "0") || die "Failed to run original create_desktop1"

	## do not run create_desktop2 as it would install the files (this will be done separately by this ebuild)
}

src_install() {
	# all pre-built binaries should go into /opt and be symlinked to usr/bin etc.

	# copy everything from inner archive to /opt install dir
	insinto ${FINAL_INSTALL_DIR}
	doins -r ${EXTRACTED_INNER_ARCHIVE}/*

	# redo the executables (otherwise they miss permission)
	exeinto ${FINAL_INSTALL_DIR}
	doexe ${EXTRACTED_INNER_ARCHIVE}/planmaker
	doexe ${EXTRACTED_INNER_ARCHIVE}/presentations
	doexe ${EXTRACTED_INNER_ARCHIVE}/textmaker

	# install the original wrapper scripts to /usr/bin
	dobin ${WORKDIR}/planmaker24
	dobin ${WORKDIR}/presentations24
	dobin ${WORKDIR}/textmaker24

	# symlink .desktop entries
	for app in planmaker presentations textmaker; do
		dosym ${FINAL_INSTALL_DIR}/mime/${app}-2024.desktop /usr/share/applications/${app}-2024.desktop
	done

	# MIME definition
	# TODO: split to separate files?
	# TODO: separate SoftMaker Office's own from generic definitions? (generic = MS Office etc.)
	insinto /usr/share/mime/application/
	doins ${EXTRACTED_INNER_ARCHIVE}/mime/softmaker-office-2024.xml

	## icons (see original copy_icons function)
	# TODO: do not install what we do not need when separated
	# FIXME: 1024 is not supported by desktop eclass yet

	# app icons
	for app in prl tml pml; do
		for size in 16 24 32 48 64 128 256 512 1024; do
			newicon -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/${app}_${size}.png" "application-x-${app}24.png"
		done
	done

	# MIME icons
	for size in 16 24 32 48 64 128 256 512 1024; do
		## text documents
		# SoftOffice => tmd icon
		for mime in application-x-tmd application-x-tmv; do
			newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/tmd_${size}.png" ${mime}.png
		done

		# MS Office => tmd_mso icon
		for mime in application-rtf text-rtf application-msword application-msword-template application-vnd.ms-word application-x-doc application-x-pocket-word application-vnd.openxmlformats-officedocument.wordprocessingml.document application-vnd.openxmlformats-officedocument.wordprocessingml.template application-vnd.ms-word.document.macroenabled.12 application-vnd.ms-word.template.macroenabled.12; do
			newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/tmd_mso_${size}.png" ${mime}.png
		done

		# OpenDocument => tmd_oth icon
		for mime in application-x-pocket-word application-vnd.oasis.opendocument.text text-rtf application-vnd.sun.xml.writer application-vnd.sun.xml.writer.template application-vnd.wordperfect application-vnd.oasis.opendocument.text-template application-vnd.oasis.opendocument.text application-vnd.sun.xml.writer application-vnd.sun.xml.writer.template application-x-dbf; do
			newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/tmd_oth_${size}.png" ${mime}.png
		done

		## spreadsheet documents
		# SoftOffice? => pmd icon
		for mime in application-x-pmd application-x-pmv application-x-pmdx application-x-pagemaker; do
			newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/pmd_${size}.png" ${mime}.png
		done

		# MS Office => pmd_mso icon
		for mime in application-x-sylk application-excel application-x-excel application-x-ms-excel application-x-msexcel application-x-xls application-xls application-vnd.ms-excel application-vnd.openxmlformats-officedocument.spreadsheetml.sheet application-vnd.openxmlformats-officedocument.spreadsheetml.template application-vnd.ms-excel.sheet.macroenabled.12 application-vnd.ms-excel.template.macroenabled.12 text-spreadsheet; do
			newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/pmd_mso_${size}.png" ${mime}.png
		done

		# OpenDocument and generic? => pmd_oth icon
		for mime in text-csv application-x-dif application-x-prn application-vnd.stardivision.calc; do
			newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/pmd_oth_${size}.png" ${mime}.png
		done

		## presentations
		# SoftOffice => prd icon
		for mime in application-x-prd application-x-prs application-x-prv; do
			newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/prd_${size}.png" ${mime}.png
		done

		# MS Office => prd_mso icon
		for mime in application-ppt application-mspowerpoint application-vnd.ms-powerpoint application-vnd.ms-powerpoint.presentation.macroenabled.12 application-vnd.ms-powerpoint.slideshow.macroEnabled.12 application-vnd.openxmlformats-officedocument.presentationml.presentation application-vnd.openxmlformats-officedocument.presentationml.template application-vnd.openxmlformats-officedocument.presentationml.slideshow; do
			newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/prd_mso_${size}.png" ${mime}.png
		done

		## trailing in original function
		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/tmd_${size}.png" application-x-tmd.png
		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/tmd_mso_${size}.png" application-x-tmd-mso.png
		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/tmd_oth_${size}.png" application-x-tmd-oth.png

		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/pmd_${size}.png" application-x-pmd.png
		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/pmd_mso_${size}.png" application-x-pmd-mso.png
		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/pmd_oth_${size}.png" application-x-pmd-oth.png

		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/prd_${size}.png" application-x-prd.png
		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/prd_mso_${size}.png" application-x-prd-mso.png
		newicon -c mimetypes -s ${size} "${EXTRACTED_INNER_ARCHIVE}/icons/prd_oth_${size}.png" application-x-prd-oth.png
	done

	# TODO: what about the provided fonts, theres no global registration in the original install script?
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

