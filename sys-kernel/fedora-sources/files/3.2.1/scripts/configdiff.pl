#! /usr/bin/perl

my @args=@ARGV;
my @configoptions;
my @configvalues;
my @alreadyprinted;
my $configcounter = 0;

# first, read the override file

open (FILE,"$args[0]") || die "Could not open $args[0]";
while (<FILE>) {
	my $str = $_;
	if (/\# ([\w]+) is not set/) {
		$configoptions[$configcounter] = $1;
		$configvalues[$configcounter] = $str;
		$alreadprinted[$configcounter] = 0;
		$configcounter ++;
	} else {
		if (/([\w]+)=/) {
			$configoptions[$configcounter] = $1;
			$configvalues[$configcounter] = $str;
			$alreadprinted[$configcounter] = 0;
			$configcounter ++;
		} else {
			$configoptions[$configcounter] = "$_";
			$configvalues[$configcounter] = $str;
			$alreadprinted[$configcounter] = 0;
			$configcounter ++;
		}
	}
};

# now, read and output the entire configfile, except for the overridden
# parts... for those the new value is printed.
# O(N^2) algorithm so if this is slow I need to look at it later

open (FILE2,"$args[1]") || die "Could not open $args[1]";
while (<FILE2>) {
	my $nooutput;
	my $counter;
	my $configname="$_";
	my $match;

	if (/\# ([\w]+) is not set/) {
		$configname = $1;
	} else {
		if (/([\w]+)=/) {
			$configname  = $1;
		} 
	}

	$counter = 0;
	$nooutput = 0;
	$match = 0;
#	print "C : $configname";
	while ($counter < $configcounter) {	
		if ("$configname" eq "$configoptions[$counter]") {	
			if ( ("$_" eq "$configvalues[$counter]") || ("$configname" eq "") ) {
				$match = 1;
			} else {
				$alreadyprinted[$configcounter] = 1;
				print "$_";
				$match = 1;
			}
		}
		$counter++;
	}
	if ($match == 0) {
		print "$_";
	}

}


1;
