
		Kernel package tips & tricks.
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The kernel is one of the more complicated packages in the distro, and
for the newcomer, some of the voodoo in the spec file can be somewhat scary.
This file attempts to document some of the magic.


Speeding up make prep
---------------------
The kernel is nearly 500MB of source code, and as such, 'make prep'
takes a while. The spec file employs some trickery so that repeated
invocations of make prep don't take as long.  Ordinarily the %prep
phase of a package will delete the tree it is about to untar/patch.
The kernel %prep keeps around an unpatched version of the tree,
and makes a symlink tree clone of that clean tree and than applies
the patches listed in the spec to the symlink tree.
This makes a huge difference if you're doing multiple make preps a day.
As an added bonus, doing a diff between the clean tree and the symlink
tree is slightly faster than it would be doing two proper copies of the tree.


build logs.
-----------
There's a convenience helper script in scripts/grab-logs.sh
that will grab the build logs from koji for the kernel version reported
by make verrel


config heirarchy.
-----------------
Instead of having to maintain a config file for every arch variant we build on,
the kernel spec uses a nested system of configs.  At the top level, is
config-generic. Add options here that should be present in every possible
config on all architectures.

Beneath this are per-arch overrides. For example config-x86-generic add
additional x86 specific options, and also _override_ any options that were
set in config-generic.

The heirarchy looks like this..

                           config-generic
                                 |
                         config-x86-generic
                         |                |
             config-x86-32-generic   config-x86-64-generic

An option set in a lower level will override the same option set in one
of the higher levels.


There exist two additional overrides, config-debug, and config-nodebug,
which override -generic, and the per-arch overrides. It is documented
further below.


debug options.
--------------
This is a little complicated, as the purpose & meaning of this changes
depending on where we are in the release cycle.
If we are building for a current stable release, 'make release' has
typically been run already, which sets up the following..
- Two builds occur, a 'kernel' and a 'kernel-debug' flavor.
- kernel-debug will get various heavyweight debugging options like
  lockdep etc turned on.

If we are building for rawhide, 'make debug' has been run, which changes
the status quo to:
- We only build one kernel 'kernel'
- The debug options from 'config-debug' are always turned on.
This is done to increase coverage testing, as not many people actually
run kernel-debug.

To add new debug options, add an option to _both_ config-debug and config-nodebug,
and also new stanzas to the Makefile 'debug' and 'release' targets.

Sometimes debug options get added to config-generic, or per-arch overrides
instead of config-[no]debug. In this instance, the options should have no
discernable performance impact, otherwise they belong in the debug files.

