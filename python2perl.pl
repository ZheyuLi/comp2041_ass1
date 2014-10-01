#!/usr/bin/perl -w
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# Charbel Antouny (z3462611) 2014

# Check if any files have been provided as arguments, else read from STDIN
if (!@ARGV) {
    push @ARGV, "-";
}

# sub perlVar {
#     my $var = $_[0];
#     return "\$$var";
# }

$regexVar = "[a-zA-Z][a-zA-Z0-9_]*";
#my %vars = ();
foreach my $file (@ARGV) {
    open F, "<$file";
    while ($line = <F>) {
        if ($line =~ m/^#!/ && $. == 1) {
            # translate #! line 
            print "#!/usr/bin/perl -w\n";

        } elsif ($line =~ m/^\s*#/ || $line =~ /^\s*$/) {
            # Blank & comment lines can be passed unchanged
            print $line;

        } elsif ($line =~ m/^\s*print\s*"(.*)"\s*$/) {
            # Python's print print a new-line character by default
            # so we need to add it explicitly to the Perl print statement
            print "print \"$1\\n\";\n";

        } elsif ($line =~ m/^\s*print\s*($regexVar)\s*$/) {
            # print var instead of string
            print "print \"\$$1\\n\";", "\n";
            
        } elsif ($line =~ m/^\s*($regexVar)\s*(\+|-)?=\s*([0-9]+|$regexVar)/) {
            # captures numeric and variable assignment
            # also checks for += or -=
            my $var = "\$$1";
            my $operator = ($2) ? ("$2") : ("");
            my $value = "$3";
            if ($line =~ m/(([0-9]*|$regexVar)\s*(\+|-|\*|\/|%|\*\*)\s*([0-9]+|$regexVar))+/) {
                # captures arithmetic equations
                $value = "$&";
                $value =~ s/($regexVar)/\$$1/g;
                #$vars{"$var"} = eval "$value";
            }
            print "$var ${operator}= ${value};", "\n";
            #$vars{"$var"} = "$value" if (!defined $vars{"var"});

        } else {
            # Lines we can't translate are turned into comments
            print "#$line\n";
        }
    }
}