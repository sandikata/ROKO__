# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_64 )

inherit desktop multilib-build pax-utils unpacker xdg

QA_PREBUILT="/opt/viber/Viber
	/opt/viber/libexec/QtWebEngineProcess
	/opt/viber/plugins/*/*.so
	/opt/viber/lib/*
	/opt/viber/qml/*"

DESCRIPTION="Free text and calls"
HOMEPAGE="http://www.viber.com"
SRC_URI="http://download.cdn.viber.com/cdn/desktop/Linux/${PN}.deb -> ${P}.deb"

LICENSE="viber"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+abi_x86_64 apulse +pulseaudio"
REQUIRED_USE="^^ ( apulse pulseaudio )"
RESTRICT="bindist mirror"

RDEPEND="dev-libs/expat[${MULTILIB_USEDEP}]
	dev-libs/glib:2[${MULTILIB_USEDEP}]
	dev-libs/nspr[${MULTILIB_USEDEP}]
	dev-libs/nss[${MULTILIB_USEDEP}]
	dev-libs/openssl-compat[${MULTILIB_USEDEP}]
	dev-libs/wayland[${MULTILIB_USEDEP}]
	media-libs/alsa-lib[${MULTILIB_USEDEP}]
	media-libs/fontconfig:1.0[${MULTILIB_USEDEP}]
	media-libs/freetype:2[${MULTILIB_USEDEP}]
	media-libs/gst-plugins-base:1.0[${MULTILIB_USEDEP}]
	media-libs/gstreamer:1.0[${MULTILIB_USEDEP}]
	net-print/cups[${MULTILIB_USEDEP}]
	sys-apps/dbus[${MULTILIB_USEDEP}]
	sys-libs/zlib:0/1[${MULTILIB_USEDEP}]
	x11-libs/libdrm[${MULTILIB_USEDEP}]
	x11-libs/libICE[${MULTILIB_USEDEP}]
	x11-libs/libSM[${MULTILIB_USEDEP}]
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libxcb:0/1.12[${MULTILIB_USEDEP}]
	x11-libs/libXcomposite[${MULTILIB_USEDEP}]
	x11-libs/libXcursor[${MULTILIB_USEDEP}]
	x11-libs/libXdamage[${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXfixes[${MULTILIB_USEDEP}]
	x11-libs/libXi[${MULTILIB_USEDEP}]
	x11-libs/libXrandr[${MULTILIB_USEDEP}]
	x11-libs/libXrender[${MULTILIB_USEDEP}]
	x11-libs/libXScrnSaver[${MULTILIB_USEDEP}]
	x11-libs/libXtst[${MULTILIB_USEDEP}]
	x11-libs/xcb-util-image[${MULTILIB_USEDEP}]
	x11-libs/xcb-util-keysyms[${MULTILIB_USEDEP}]
	x11-libs/xcb-util-renderutil[${MULTILIB_USEDEP}]
	x11-libs/xcb-util-wm[${MULTILIB_USEDEP}]
	apulse? ( media-sound/apulse[${MULTILIB_USEDEP}] )
	pulseaudio? ( media-sound/pulseaudio[${MULTILIB_USEDEP}] )"
BDEPEND="sys-apps/fix-gnustack"

S="${WORKDIR}"

src_prepare() {
	default

	if use apulse ; then
		sed -i '/Exec=/s|/opt|apulse /opt|' \
			usr/share/applications/viber.desktop || die "sed failed"
	fi

	# remove hardcoded path
	sed -i '/Icon/s|/usr/share/pixmaps/viber.png|viber|' \
		usr/share/applications/viber.desktop \
		|| die "sed failed for viber.desktop"
}

src_install() {
	fix-gnustack -f opt/viber/lib/libQt5WebEngineCore.so.5 > /dev/null \
		|| die "removing execstack flag failed"

	newicon -s scalable usr/share/icons/hicolor/scalable/apps/Viber.svg \
		viber.svg
	for size in 16x16 24x24 32x32 48x48 64x64 96x96 128x128 256x256; do
		newicon -s "${size%%x*}" usr/share/viber/"${size}".png viber.png
	done
	dosym ../icons/hicolor/96x96/apps/viber.png \
		/usr/share/pixmaps/viber.png

	domenu usr/share/applications/viber.desktop

	insinto /opt/viber
	doins -r opt/viber/.

	pax-mark -m "${ED}"/opt/viber/Viber \
			"${ED}"/opt/viber/QtWebEngineProcess

	fperms -R +x /opt/viber/Viber \
		/opt/viber/libexec/QtWebEngineProcess \
		/opt/viber/plugins/{audio,generic,geoservices,imageformats,mediaservice,platforminputcontexts,platforms,printsupport,sqldrivers,xcbglintegrations}/ \
		/opt/viber/qml/Qt/labs/animation/liblabsanimationplugin.so \
		/opt/viber/qml/Qt/labs/calendar/libqtlabscalendarplugin.so \
		/opt/viber/qml/Qt/labs/folderlistmodel/libqmlfolderlistmodelplugin.so \
		/opt/viber/qml/Qt/labs/location/liblocationlabsplugin.so \
		/opt/viber/qml/Qt/labs/lottieqt/liblottieqtplugin.so \
		/opt/viber/qml/Qt/labs/platform/libqtlabsplatformplugin.so \
		/opt/viber/qml/Qt/labs/qmlmodels/liblabsmodelsplugin.so \
		/opt/viber/qml/Qt/labs/settings/libqmlsettingsplugin.so \
		/opt/viber/qml/Qt/labs/sharedimage/libsharedimageplugin.so \
		/opt/viber/qml/Qt/labs/wavefrontmesh/libqmlwavefrontmeshplugin.so \
		/opt/viber/qml/QtGraphicalEffects/private/libqtgraphicaleffectsprivate.so \
		/opt/viber/qml/QtGraphicalEffects/libqtgraphicaleffectsplugin.so \
		/opt/viber/qml/QtLocation/libdeclarative_location.so \
		/opt/viber/qml/QtMultimedia/libdeclarative_multimedia.so \
		/opt/viber/qml/QtPositioning/libdeclarative_positioning.so \
		/opt/viber/qml/QtQml/Models.2/libmodelsplugin.so \
		/opt/viber/qml/QtQml/RemoteObjects/libqtqmlremoteobjects.so \
		/opt/viber/qml/QtQml/StateMachine/libqtqmlstatemachine.so \
		/opt/viber/qml/QtQml/WorkerScript.2/libworkerscriptplugin.so \
		/opt/viber/qml/QtQml/libqmlplugin.so \
		/opt/viber/qml/QtQuick/Controls/Styles/Flat/libqtquickextrasflatplugin.so \
		/opt/viber/qml/QtQuick/Controls/libqtquickcontrolsplugin.so \
		/opt/viber/qml/QtQuick/Controls.2/Fusion/libqtquickcontrols2fusionstyleplugin.so \
		/opt/viber/qml/QtQuick/Controls.2/Imagine/libqtquickcontrols2imaginestyleplugin.so \
		/opt/viber/qml/QtQuick/Controls.2/Material/libqtquickcontrols2materialstyleplugin.so \
		/opt/viber/qml/QtQuick/Controls.2/Universal/libqtquickcontrols2universalstyleplugin.so \
		/opt/viber/qml/QtQuick/Controls.2/libqtquickcontrols2plugin.so \
		/opt/viber/qml/QtQuick/Dialogs/Private/libdialogsprivateplugin.so \
		/opt/viber/qml/QtQuick/Dialogs/libdialogplugin.so \
		/opt/viber/qml/QtQuick/Extras/libqtquickextrasplugin.so \
		/opt/viber/qml/QtQuick/Layouts/libqquicklayoutsplugin.so \
		/opt/viber/qml/QtQuick/LocalStorage/libqmllocalstorageplugin.so \
		/opt/viber/qml/QtQuick/Particles.2/libparticlesplugin.so \
		/opt/viber/qml/QtQuick/PrivateWidgets/libwidgetsplugin.so \
		/opt/viber/qml/QtQuick/Scene2D/libqtquickscene2dplugin.so \
		/opt/viber/qml/QtQuick/Scene3D/libqtquickscene3dplugin.so \
		/opt/viber/qml/QtQuick/Shapes/libqmlshapesplugin.so \
		/opt/viber/qml/QtQuick/Templates.2/libqtquicktemplates2plugin.so \
		/opt/viber/qml/QtQuick/Timeline/libqtquicktimelineplugin.so \
		/opt/viber/qml/QtQuick/VirtualKeyboard/Settings/libqtquickvirtualkeyboardsettingsplugin.so \
		/opt/viber/qml/QtQuick/VirtualKeyboard/Styles/libqtquickvirtualkeyboardstylesplugin.so \
		/opt/viber/qml/QtQuick/VirtualKeyboard/libqtquickvirtualkeyboardplugin.so \
		/opt/viber/qml/QtQuick/Window.2/libwindowplugin.so \
		/opt/viber/qml/QtQuick/XmlListModel/libqmlxmllistmodelplugin.so \
		/opt/viber/qml/QtQuick.2/libqtquick2plugin.so \
		/opt/viber/qml/QtWebChannel/libdeclarative_webchannel.so \
		/opt/viber/qml/QtWebEngine/libqtwebengineplugin.so

	dosym ../../opt/viber/Viber /usr/bin/Viber
}
