#! /usr/bin/perl

my @args=@ARGV;
my @configoptions;
my @configvalues;
my @common;
my $configcounter = 0;

# first, read the 1st file

open (FILE,"$args[0]") || die "Could not open $args[0]";
while (<FILE>) {
	my $str = $_;
	if (/\# ([\w]+) is not set/) {
		$configoptions[$configcounter] = $1;
		$configvalues[$configcounter] = $str;
		$common[$configcounter] = 1;
		$configcounter ++;
	} else {
		if (/([\w]+)=/) {
			$configoptions[$configcounter] = $1;
			$configvalues[$configcounter] = $str;
			$common[$configcounter] = 1;
			$configcounter ++;
		} else {
			$configoptions[$configcounter] = "foobarbar";
			$configvalues[$configcounter] = $str;
			$common[$configcounter] = 1;
			$configcounter ++;
		}
	}
};

# now, read all configfiles and see of the options match the initial one.
# if not, mark it not common
my $cntr=1;


while ($cntr < @ARGV) {
	open (FILE,$args[$cntr]) || die "Could not open $args[$cntr]";	
	while (<FILE>) {
		my $nooutput;
		my $counter;
		my $configname;

		if (/\# ([\w]+) is not set/) {
			$configname = $1;
		} else {
			if (/([\w]+)=/) {
				$configname  = $1;
			} 
		}

		$counter = 0;
		$nooutput = 0;
		while ($counter < $configcounter) {	
			if ("$configname" eq "$configoptions[$counter]") {	
				if ("$_" eq "$configvalues[$counter]") {
					1;
				} else {
					$common[$counter] = 0;
				}
			}
			$counter++;
		}
	}

	$cntr++;
}

# now print the common values
my $counter = 0;

while ($counter < $configcounter) {	
	if ($common[$counter]!=0) {
		print "$configvalues[$counter]";
	}
	$counter++;
}

1;

