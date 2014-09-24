#!/usr/bin/perl -w
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# Charbel Antouny (z3462611) 2014

# Check if any files have been provided as arguments, else read from STDIN
if (!@ARGV) {
    push @ARGV, "-";
}

sub perlVar {
    my $var = $_[0];
    return "\$$var";
}

my %vars = ();
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
        } elsif ($line =~ m/^\s*print\s*([a-zA-Z][a-zA-Z0-9_]*)\s*$/) {
            # print var instead of string

            #check if var exists in hash then print
        } elsif ($line =~ m/^\s*([a-zA-Z][a-zA-Z0-9_]*)\s*=\s*([0-9]*)/) {
            # captures numeric variables
            printf "%s = $2;\n", perlVar($1);

            # add var to hash
        } else {
            # Lines we can't translate are turned into comments
            print "#$line\n";
        }
    }
}