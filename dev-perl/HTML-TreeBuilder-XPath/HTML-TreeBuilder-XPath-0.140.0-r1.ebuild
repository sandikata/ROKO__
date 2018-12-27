# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

MODULE_AUTHOR="MIROD"
MODULE_VERSION=0.14
inherit perl-module

DESCRIPTION="Add XPath support to HTML::TreeBuilder"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
perl_eumm_configure() {
	#perl 5.006
	#ExtUtils::MakeMaker
	echo virtual/perl-ExtUtils-MakeMaker
}
perl_eumm_prereq_pm() {
	# XML::XPathEngine 0.12
	echo '>=dev-perl/XML-XPathEngine-0.120.0'
	# HTML::TreeBuilder
	echo dev-perl/HTML-Tree
	# List::Util
	echo virtual/perl-Scalar-List-Utils

}
RDEPEND="$(perl_eumm_prereq_pm)"
DEPEND="
	$(perl_eumm_configure)
	$(perl_eumm_prereq_pm)
"
