#!/usr/bin/perl -w
#
# Script to rediff all patches in the spec
# Usage: perl -w rediffall.pl < kernel-2.4.spec
#
# $workdir is where the new rediff'ed patches are created
# $origdir is where the original patches and tarball are located
#
# Note that both $workdir and $origdir must be absolute path names.
# Suggestion: create a /kernel symbolic link to the top of your CVS tree.

my $workdir = "/dev/shm/redifftree";
my $origdir = "/home/davej/devel";
my $kernver = "linux-2.6.17";
my $datestrip = "s/^\\(\\(+++\\|---\\) [^[:blank:]]\\+\\)[[:blank:]].*/\\1/";
my $patchindex = 0;
my @patchlist;

# phase 1: create a tree
print "Extracting pristine source..\n";
system("mkdir -p $workdir");
system("rm -rf $workdir/*");
chdir("$workdir");
system("tar -jxvf $origdir/$kernver.tar.bz2 > /dev/null");
system("cp -al $kernver linux-$patchindex");

# phase 2: read the spec from stdin and store all patches
print "Reading specfile..\n";

while (<>) {
	my $line = $_;
	if ($line =~ /^Patch([0-9]+)\: ([a-zA-Z0-9\-\_\.\+]+\.patch)/) {
		$patchlist[$1] = $2;
	} else {
		if ($line =~ /^Patch([0-9]+)\: ([a-zA-Z0-9\-\_\.]+\.bz2)/) {
			$patchlist[$1] = $2;
		}
	}

	if ($line =~ /^%patch([0-9]+) -p1/) {
		# copy the tree, apply the patch, diff and remove the old tree
		my $oldindex = $patchindex;
		$patchindex = $1;

		print "rediffing patch number $patchindex: $patchlist[$patchindex]\n";

		system("cp -al linux-$oldindex linux-$patchindex");
		chdir("linux-$patchindex");
		if ($patchlist[$patchindex] =~ /bz2/) {
			system("bzcat $origdir/$patchlist[$patchindex] | patch -p1 &>/dev/null");
		} else {
			system("cat $origdir/$patchlist[$patchindex] | patch -p1 &>/dev/null");
		}
		chdir("$workdir");
		system("rm -f `find -name \"*orig\"`");
		if ($patchlist[$patchindex] =~ /bz2/) {
		} else {
			system("diff -urNp --exclude-from=/home/davej/.exclude linux-$oldindex linux-$patchindex | sed '$datestrip' > $patchlist[$patchindex]");
		}
		system("rm -rf linux-$oldindex");
	}
};

1;
