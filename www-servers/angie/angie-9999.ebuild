# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck disable=SC2016

EAPI=8

AUTOTOOLS_AUTO_DEPEND="no"
GENTOO_DEPEND_ON_PERL="no"
PYTHON_COMPAT=( python3_{11..13} )
SSL_DEPS_SKIP=1

inherit autotools edo git-r3 multiprocessing python-any-r1 ssl-cert toolchain-funcs perl-module systemd

ANGIE_MODULES_HTTP_STD="access api auth_basic autoindex browser charset docker empty_gif
	fastcgi geo grpc gzip limit_req limit_conn map memcached mirror
	prometheus proxy referer rewrite scgi ssi split_clients upstream_hash
	upstream_ip_hash upstream_keepalive upstream_least_conn upstream_random
	upstream_sticky upstream_zone userid uwsgi"
ANGIE_MODULES_HTTP_OPT="acme addition auth_request dav degradation flv geoip gunzip
	gzip_static image_filter mp4 perl random_index realip secure_link
	slice stub_status sub xslt"
ANGIE_MODULES_STREAM_STD="access geo limit_conn map pass return set split_clients
	upstream_hash upstream_least_conn upstream_random upstream_sticky upstream_zone"
ANGIE_MODULES_STREAM_OPT="acme geoip mqtt_preread rdp_preread realip ssl_preread"
ANGIE_MODULES_MAIL="imap pop3 smtp"

DESCRIPTION="Efficient, powerful and scalable reverse proxy and web server"
HOMEPAGE="https://github.com/webserver-llc/angie"
EGIT_REPO_URI="https://github.com/webserver-llc/${PN}.git"

LICENSE="BSD-2"
SLOT="0"
IUSE="aio debug +http +http2 http3 +http-cache ipv6 libatomic pcre +pcre2 pcre-jit rtmp selinux ssl test threads vim-syntax"

for mod in $ANGIE_MODULES_HTTP_STD ; do IUSE="${IUSE} +angie_modules_http_${mod}" ; done
for mod in $ANGIE_MODULES_HTTP_OPT ; do IUSE="${IUSE} angie_modules_http_${mod}" ; done
for mod in $ANGIE_MODULES_STREAM_STD ; do IUSE="${IUSE} angie_modules_stream_${mod}" ; done
for mod in $ANGIE_MODULES_STREAM_OPT ; do IUSE="${IUSE} angie_modules_stream_${mod}" ; done
for mod in $ANGIE_MODULES_MAIL ; do IUSE="${IUSE} angie_modules_mail_${mod}" ; done

REQUIRED_USE="angie_modules_stream_acme? ( angie_modules_http_acme )
	test? ( angie_modules_http_addition angie_modules_http_auth_basic angie_modules_http_auth_request
		angie_modules_http_dav angie_modules_http_flv angie_modules_http_geoip angie_modules_http_gunzip
		angie_modules_http_gzip_static angie_modules_http_image_filter angie_modules_http_mp4
		angie_modules_http_perl angie_modules_http_random_index angie_modules_http_secure_link
		angie_modules_http_slice angie_modules_http_stub_status angie_modules_http_sub
		angie_modules_http_uwsgi angie_modules_http_xslt angie_modules_mail_imap angie_modules_mail_pop3
		angie_modules_mail_smtp angie_modules_stream_access angie_modules_stream_acme
		angie_modules_stream_geo angie_modules_stream_geoip angie_modules_stream_limit_conn
		angie_modules_stream_map angie_modules_stream_mqtt_preread angie_modules_stream_pass
		angie_modules_stream_rdp_preread angie_modules_stream_realip angie_modules_stream_return
		angie_modules_stream_set angie_modules_stream_split_clients
		angie_modules_stream_upstream_hash angie_modules_stream_upstream_least_conn
		angie_modules_stream_upstream_random angie_modules_stream_upstream_sticky
		angie_modules_stream_upstream_zone angie_modules_stream_ssl_preread debug http3 )"
RESTRICT="!test? ( test )"

CDEPEND="acct-group/angie
	acct-user/angie
	virtual/libcrypt:=
	pcre? ( dev-libs/libpcre:= )
	pcre2? ( dev-libs/libpcre2:= )
	pcre-jit? ( dev-libs/libpcre:=[jit] )
	ssl? ( dev-libs/openssl:0= )
	http2? ( >=dev-libs/openssl-1.0.1c:0= )
	http-cache? ( dev-libs/openssl:0= )
	angie_modules_http_geoip? ( dev-libs/geoip )
	angie_modules_http_gunzip? ( virtual/zlib:0= )
	angie_modules_http_gzip? ( virtual/zlib:0= )
	angie_modules_http_gzip_static? ( virtual/zlib:0= )
	angie_modules_http_image_filter? ( media-libs/gd:=[jpeg,png] )
	angie_modules_http_perl? ( >=dev-lang/perl-5.8:= )
	angie_modules_http_rewrite? ( dev-libs/libpcre:= )
	angie_modules_http_secure_link? ( dev-libs/openssl:0= )
	angie_modules_http_xslt? ( dev-libs/libxml2:= dev-libs/libxslt )
	angie_modules_stream_geoip? ( dev-libs/geoip )"
RDEPEND="${CDEPEND}
	>=app-misc/mime-types-2.1.54-r1[angie]
	selinux? ( sec-policy/selinux-nginx )
	!www-servers/nginx:mainline
	!www-servers/nginx:stable
    !www-servers/nginx:0
    !www-servers/nginx:live"
DEPEND="${CDEPEND}
	libatomic? ( dev-libs/libatomic_ops )"
BDEPEND="test? ( dev-lang/perl
		dev-perl/Cache-Memcached
		dev-perl/Cache-Memcached-Fast
		dev-perl/CryptX
		dev-perl/FCGI
		dev-perl/GD
		dev-perl/IO-Socket-SSL
		dev-perl/JSON
		dev-perl/Protocol-WebSocket
		dev-perl/SCGI
		dev-perl/Test-Deep
		dev-perl/Test-Most
		dev-perl/TimeDate
		media-video/ffmpeg[x264]
		net-dns/bind
		net-dns/dnsmasq
		net-misc/memcached
		$(python_gen_any_dep 'www-servers/uwsgi[python,ssl,${PYTHON_USEDEP}]') )"

PDEPEND="vim-syntax? ( app-vim/nginx-syntax )"

DOCS=( CHANGES README.rst )

PATCHES=( "${FILESDIR}/${PN}-1.4.1-fix-perl-install-path.patch"
	"${FILESDIR}/${PN}-httpoxy-mitigation-r1.patch" )

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	default

	# don't rename etc files, remove useless files
	sed -i  -e 's/.default//' \
		-e '/koi-/d' \
		-e '/win-/d' \
		-e '/$NGX_HTML/d' \
		-e '/NGX_PREFIX\/html/d' \
		-e '/"\$NGX_PID_PATH/d' \
		auto/install || die "sed failed for install"

	# don't install to /etc/angie/ if not in use
	local module
	for module in fastcgi scgi uwsgi ; do
		if ! use angie_modules_http_${module}; then
			sed -i -e "/${module}/d" auto/install \
				|| die "sed failed for auto/install"
		fi
	done

	# remove tests require ipv6
	use ipv6 || eapply "${FILESDIR}/${PN}"-1.10.2-tests-no-ipv6.patch
	# decrease path to unix socket api.sock
	sed -i '/"angie-/s|ngie-test|-|' tests/lib/Test/Nginx.pm \
		|| die "sed failed for Nginx.pm"
	# specify python plugin version
	sed -i "/push @uwsgiopts/s|python3|${EPYTHON/./}|" \
		tests/uwsgi{,_body,_ssl,_ssl_verify}.t || die "sed failed for uwsgi"
}

src_configure() {
	local myconf=() http_enabled='' mail_enabled='' stream_enabled=''

	use aio       && myconf+=( --with-file-aio )
	use debug     && myconf+=( --with-debug )
	use http2     && myconf+=( --with-http_v2_module )
	use http3     && myconf+=( --with-http_v3_module )
	use libatomic && myconf+=( --with-libatomic )
	use pcre      && myconf+=( --with-pcre --without-pcre2 )
	use pcre-jit  && myconf+=( --with-pcre-jit )
	use threads   && myconf+=( --with-threads )

	# HTTP modules
	for mod in $ANGIE_MODULES_HTTP_STD ; do
		if use angie_modules_http_"${mod}" ; then
			http_enabled=1
		else
			myconf+=( --without-http_"${mod}"_module )
		fi
	done

	for mod in $ANGIE_MODULES_HTTP_OPT ; do
		if use angie_modules_http_"${mod}" ; then
			http_enabled=1
			myconf+=( --with-http_"${mod}"_module )
		fi
	done

	if use angie_modules_http_fastcgi ; then
		myconf+=( --with-http_realip_module )
	fi

	if use http || use http-cache || use http2 || use http3 ; then
		http_enabled=1
	fi

	if [ $http_enabled ] ; then
		use http-cache || myconf+=( --without-http-cache )
		use ssl && myconf+=( --with-http_ssl_module )
	else
		myconf+=( --without-http --without-http-cache )
	fi

	# Stream modules
	for mod in $ANGIE_MODULES_STREAM_STD ; do
		if use angie_modules_stream_"${mod}" ; then
			stream_enabled=1
		else
			myconf+=( --without-stream_"${mod}"_module )
		fi
	done

	for mod in $ANGIE_MODULES_STREAM_OPT ; do
		if use angie_modules_stream_"${mod}" ; then
			stream_enabled=1
			myconf+=( --with-stream_"${mod}"_module )
		fi
	done

	if [ $stream_enabled ] ; then
		myconf+=( --with-stream )
		use ssl && myconf+=( --with-stream_ssl_module )
	fi

	# MAIL modules
	for mod in $ANGIE_MODULES_MAIL ; do
		if use angie_modules_mail_"${mod}" ; then
			mail_enabled=1
		else
			myconf+=( --without-mail_"${mod}"_module )
		fi
	done

	if [ $mail_enabled ] ; then
		myconf+=( --with-mail )
		use ssl && myconf+=( --with-mail_ssl_module )
	fi

	# https://bugs.gentoo.org/286772
	export LANG=C LC_ALL=C
	tc-export AR CC

	if ! use prefix; then
		myconf+=( --user=angie )
		myconf+=( --group=angie )
	fi

	# econf?
	./configure --with-compat \
		--prefix="${EPREFIX}"/usr \
		--conf-path="${EPREFIX}"/etc/angie/angie.conf \
		--error-log-path="${EPREFIX}"/var/log/angie/error_log \
		--pid-path="${EPREFIX}"/run/angie/angie.pid \
		--lock-path="${EPREFIX}"/run/lock/"${PN}".lock \
		--with-cc-opt="-I${ESYSROOT}/usr/include" \
		--with-ld-opt="-L${ESYSROOT}/usr/$(get_libdir)" \
		--http-log-path="${EPREFIX}"/var/log/angie/access_log \
		--http-client-body-temp-path="${EPREFIX}"/var/lib/angie/tmp/client \
		--http-proxy-temp-path="${EPREFIX}"/var/lib/angie/tmp/proxy \
		--http-fastcgi-temp-path="${EPREFIX}"/var/lib/angie/tmp/fastcgi \
		--http-scgi-temp-path="${EPREFIX}"/var/lib/angie/tmp/scgi \
		--http-uwsgi-temp-path="${EPREFIX}"/var/lib/angie/tmp/uwsgi \
		--http-acme-client-path="${EPREFIX}"/etc/angie/acme_client \
		"${myconf[@]}" || die "configure failed"

	# A purely cosmetic change that makes angie -V more readable. This can be
	# good if people outside the gentoo community would troubleshoot and
	# question the users setup.
	sed -i "s|${WORKDIR}|external_module|g" objs/ngx_auto_config.h \
		|| die "sed failed for ngx_auto_config.h"
}

src_test() {
	edo prove -v -j "$(makeopts_jobs)" tests
}

src_compile() {
	# https://bugs.gentoo.org/286772
	export LANG=C LC_ALL=C
	emake LINK="${CC} ${LDFLAGS}" OTHERLDFLAGS="${LDFLAGS}"
}

src_install() {
	emake DESTDIR="${D}" install

	insinto /etc/angie
	doins "${FILESDIR}"/angie.conf
	newinitd "${FILESDIR}"/angie.initd angie
	newconfd "${FILESDIR}"/angie.confd angie
	systemd_dounit "${FILESDIR}"/angie.service
	doman man/angie.8
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/angie.logrotate angie

	keepdir /var/log/angie /var/www/localhost /var/lib/angie/tmp/client
	fperms 0700 /var/lib/angie/tmp/client
	fowners angie:angie /var/lib/angie/tmp/client
	fperms 0750 /var/lib/angie/tmp
	fowners angie:0 /var/lib/angie/tmp
	fperms 0710 /var/log/angie
	fowners 0:angie /var/log/angie

	if use angie_modules_http_fastcgi ; then
		keepdir /var/lib/angie/tmp/fastcgi
		fperms 0700 /var/lib/angie/tmp/fastcgi
		fowners angie:angie /var/lib/angie/tmp/fastcgi
	fi

	if use angie_modules_http_proxy ; then
		keepdir /var/lib/angie/tmp/proxy
		fperms 0700 /var/lib/angie/tmp/proxy
		fowners angie:angie /var/lib/angie/tmp/proxy
	fi

	if use angie_modules_http_scgi ; then
		keepdir /var/lib/angie/tmp/scgi
		fperms 0700 /var/lib/angie/tmp/scgi
		fowners angie:angie /var/lib/angie/tmp/scgi
	fi

	if use angie_modules_http_uwsgi ; then
		keepdir /var/lib/angie/tmp/uwsgi
		fperms 0700 /var/lib/angie/tmp/uwsgi
		fowners angie:angie /var/lib/angie/tmp/uwsgi
	fi

	if use angie_modules_http_acme ; then
		keepdir /var/lib/angie/tmp/acme
		fperms 0700 /var/lib/angie/tmp/acme
		fowners angie:angie /var/lib/angie/tmp/acme
	fi

	if use angie_modules_http_perl ; then
		edo pushd objs/src/http/modules/perl
		emake DESTDIR="${D}" INSTALLDIRS=vendor
		perl_delete_localpod
		edo popd
	fi
}
