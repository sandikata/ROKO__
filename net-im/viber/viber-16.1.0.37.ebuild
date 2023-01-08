# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils unpacker xdg

DESCRIPTION="Free text and calls"
HOMEPAGE="https://www.viber.com/en/"
SRC_URI="https://download.cdn.viber.com/cdn/desktop/Linux/${PN}.deb -> ${P}.deb"

LICENSE="viber"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="apulse +pulseaudio"
REQUIRED_USE="^^ ( apulse pulseaudio )"
RESTRICT="bindist mirror"

RDEPEND="app-arch/brotli:0
	app-arch/snappy:0
	app-arch/zstd:0
	app-crypt/libb2
	app-crypt/mit-krb5
	dev-libs/double-conversion
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libpcre2:0
	dev-libs/libxml2:2
	dev-libs/libxslt:0
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0
	dev-libs/wayland
	media-gfx/qrencode:0
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/gst-plugins-bad:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/harfbuzz:0
	media-libs/lcms:2
	media-libs/libglvnd
	media-libs/libmng:0
	media-libs/libpng:0
	media-libs/libwebp:0
	media-libs/opus
	media-libs/tiff
	net-print/cups
	sys-apps/dbus
	sys-libs/zlib:0
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb:0
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libxshmfence
	x11-libs/libXtst
	x11-libs/tslib
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	apulse? ( media-sound/apulse )
	pulseaudio? (
		media-sound/pulseaudio
		media-plugins/gst-plugins-pulse )
	|| ( sys-apps/systemd sys-apps/systemd-utils )"
BDEPEND="sys-apps/fix-gnustack"

S="${WORKDIR}"

QA_PREBUILT="/opt/viber/Viber
	/opt/viber/libexec/QtWebEngineProcess
	/opt/viber/plugins/*/*.so
	/opt/viber/lib/*
	/opt/viber/qml/*"

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
	fix-gnustack -f opt/viber/lib/libQt6WebEngineCore.so.6 > /dev/null \
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
		/opt/viber/lib/lib{ViberRTC,qrencode}.so \
		/opt/viber/libexec/QtWebEngineProcess \
		/opt/viber/plugins/{generic,imageformats,platforminputcontexts,platforms,printsupport,sqldrivers,tls,xcbglintegrations}/ \
		/opt/viber/plugins/wayland-{decoration-client,graphics-integration-client,graphics-integration-server,shell-integration}/ \
		/opt/viber/qml/Qt/labs/animation/liblabsanimationplugin.so \
		/opt/viber/qml/Qt/labs/folderlistmodel/libqmlfolderlistmodelplugin.so \
		/opt/viber/qml/Qt/labs/platform/libqtlabsplatformplugin.so \
		/opt/viber/qml/Qt/labs/qmlmodels/liblabsmodelsplugin.so \
		/opt/viber/qml/Qt/labs/settings/libqmlsettingsplugin.so \
		/opt/viber/qml/Qt/labs/sharedimage/libsharedimageplugin.so \
		/opt/viber/qml/Qt/labs/wavefrontmesh/libqmlwavefrontmeshplugin.so \
		/opt/viber/qml/Qt5Compat/GraphicalEffects/libqtgraphicaleffectsplugin.so \
		/opt/viber/qml/Qt5Compat/GraphicalEffects/private/libqtgraphicaleffectsprivateplugin.so \
		/opt/viber/qml/QtMultimedia/libquickmultimediaplugin.so \
		/opt/viber/qml/QtQml/libqmlplugin.so \
		/opt/viber/qml/QtQml/Models/libmodelsplugin.so \
		/opt/viber/qml/QtQml/StateMachine/libqtqmlstatemachineplugin.so \
		/opt/viber/qml/QtQml/WorkerScript/libworkerscriptplugin.so \
		/opt/viber/qml/QtQml/XmlListModel/libqmlxmllistmodelplugin.so \
		/opt/viber/qml/QtQuick/libqtquick2plugin.so \
		/opt/viber/qml/QtQuick/Controls/libqtquickcontrols2plugin.so \
		/opt/viber/qml/QtQuick/Controls/Basic/libqtquickcontrols2basicstyleplugin.so \
		/opt/viber/qml/QtQuick/Controls/Basic/impl/libqtquickcontrols2basicstyleimplplugin.so \
		/opt/viber/qml/QtQuick/Controls/Fusion/libqtquickcontrols2fusionstyleplugin.so \
		/opt/viber/qml/QtQuick/Controls/Fusion/impl/libqtquickcontrols2fusionstyleimplplugin.so \
		/opt/viber/qml/QtQuick/Controls/Imagine/libqtquickcontrols2imaginestyleplugin.so \
		/opt/viber/qml/QtQuick/Controls/Imagine/impl/libqtquickcontrols2imaginestyleimplplugin.so \
		/opt/viber/qml/QtQuick/Controls/Material/libqtquickcontrols2materialstyleplugin.so \
		/opt/viber/qml/QtQuick/Controls/Material/impl/libqtquickcontrols2materialstyleimplplugin.so \
		/opt/viber/qml/QtQuick/Controls/Universal/libqtquickcontrols2universalstyleplugin.so \
		/opt/viber/qml/QtQuick/Controls/Universal/impl/libqtquickcontrols2universalstyleimplplugin.so \
		/opt/viber/qml/QtQuick/Controls/impl/libqtquickcontrols2implplugin.so \
		/opt/viber/qml/QtQuick/Dialogs/libqtquickdialogsplugin.so \
		/opt/viber/qml/QtQuick/Dialogs/quickimpl/libqtquickdialogs2quickimplplugin.so \
		/opt/viber/qml/QtQuick/Layouts/libqquicklayoutsplugin.so \
		/opt/viber/qml/QtQuick/LocalStorage/libqmllocalstorageplugin.so \
		/opt/viber/qml/QtQuick/NativeStyle/libqtquickcontrols2nativestyleplugin.so \
		/opt/viber/qml/QtQuick/Particles/libparticlesplugin.so \
		/opt/viber/qml/QtQuick/Shapes/libqmlshapesplugin.so \
		/opt/viber/qml/QtQuick/Templates/libqtquicktemplates2plugin.so \
		/opt/viber/qml/QtQuick/Window/libquickwindowplugin.so \
		/opt/viber/qml/QtQuick/tooling/libquicktoolingplugin.so \
		/opt/viber/qml/QtWayland/Client/TextureSharing/libwaylandtexturesharingplugin.so \
		/opt/viber/qml/QtWayland/Compositor/libqwaylandcompositorplugin.so \
		/opt/viber/qml/QtWayland/Compositor/IviApplication/libwaylandcompositoriviapplicationplugin.so \
		/opt/viber/qml/QtWayland/Compositor/TextureSharingExtension/libwaylandtexturesharingextensionplugin.so \
		/opt/viber/qml/QtWayland/Compositor/WlShell/libwaylandcompositorwlshellplugin.so \
		/opt/viber/qml/QtWayland/Compositor/XdgShell/libwaylandcompositorxdgshellplugin.so \
		/opt/viber/qml/QtWebChannel/libwebchannelplugin.so \
		/opt/viber/qml/QtWebEngine/libqtwebenginequickplugin.so \
		/opt/viber/qml/QtWebEngine/ControlsDelegates/libqtwebenginequickdelegatesplugin.so

	dosym ../../opt/viber/Viber /usr/bin/Viber
}
