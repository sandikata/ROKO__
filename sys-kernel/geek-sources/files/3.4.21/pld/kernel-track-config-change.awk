# $Id: kernel-track-config-change.awk,v 1.5 2009/03/27 11:46:01 glen Exp $

BEGIN {
	if (!infile) {
		print "infile= must be specified" > "/dev/stderr"
		exit 1
	}

	file = ""
	while ((rc = getline < infile) > 0) {
		name = ""
		if ( match($0, /^# CONFIG_[A-Za-z0-9_]+ is not set$/)) {
			name = $2
			value = "n"
		} else if (match($0, /^CONFIG_[A-Za-z0-9_]+=/)) {
			name = value = $1

			sub(/=.*$/, "", name)
			sub(/^[^=]*=/, "", value)
		} else if (match($0, /^# file:/)) {
			file = $3
		}
		if (length(name)) {
			optionArray[name] = value
			optionFile[name] = file
		}
	}
	if (rc == -1) {
		printf("Error reading infile='%s'\n", infile) > "/dev/stderr"
		exit 1
	}

	foundErrors = 0
}


{
	name = ""
}

/^# CONFIG_[A-Za-z0-9_]+ is not set$/ {
	name = $2
	value = "n"
}

/^CONFIG_[A-Za-z0-9_]+=/ {
	name = value = $1

	sub( /=.*$/, "", name )
	sub( /^[^=]*=/, "", value )
}

{
	if ( ! length( name ) )
		next;

	orig = optionArray[ name ]
	if ( ! orig ) {
		#print "Warning: new option " name " with value " value
	} else {
		if ( value != orig ) {
			print "ERROR (" optionFile[ name ] "): " name \
			      " redefined from `" orig "' to `" value "'" > "/dev/stderr"
			foundErrors++
		}
	}
}

END {
	if ( foundErrors ) {
		print "There were " foundErrors " errors" > "/dev/stderr"
		if ( dieOnError )
			exit 1
	}
}
