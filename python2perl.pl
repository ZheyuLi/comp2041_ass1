#!/usr/bin/perl -w
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# Charbel Antouny (z3462611) 2014

# Check if any files have been provided as arguments, else read from STDIN
if (!@ARGV) {
    push @ARGV, "-";
}

$regexVar = "[a-zA-Z][a-zA-Z0-9_]*";
my %keywords = ("print" =>1, "if" =>1, "while" =>1, "and" =>1, "or" =>1, "not" =>1);
foreach my $file (@ARGV) {
    open F, "<$file";
    while ($line = <F>) {
        if ($line =~ m/^#!/ && $. == 1) {
            # translate #! line 
            print "#!/usr/bin/perl -w\n";

        } elsif ($line =~ m/^\s*#/ || $line =~ /^\s*$/) {
            # blank & comment lines are passed unchanged
            print $line;

        } elsif ($line =~ m/^\s*print\s*"(.*)"\s*$/) {
            # print a string
            print "print \"$1\\n\";\n";

        } elsif ($line =~ m/^\s*print\s*($regexVar)/) {
            # print variable or arithmetic equation involving multiple variables
            my $var = "\"\$$1\"";
            if ($line =~ m/(${regexVar}\s*(\+|-|\*|\/|%|\*\*)\s*${regexVar})+/) {
                $var = "$&";
                $var =~ s/($regexVar)/\"\$$1\"/g;
            }
            print "print $var, \"\\n\";", "\n";
            
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
            }
            print "$var ${operator}= ${value};", "\n";

        } elsif ($line =~ m/\s*(if|while)\s*(.*?):\s*(.*?)$/) {
            # captures if/while statements
            my $keyword = "$1";
            my $cond = "$2";
            my $expr;
            if ($3) {
                $expr = "$3";
                my @exprWords = split / /, $expr;
                foreach my $word (@exprWords) {
                    if ($word =~ m/$regexVar/ and !defined $keywords{$word}) {
                        $word = "\$$word";
                    }
                }
                $expr = join " ", @exprWords;
                $expr .= ";";
            } else {
                $expr = "";
            }
            my @condWords = split / /, $cond;
            foreach my $word (@condWords) {
                if ($word =~ m/$regexVar/ and !defined $keywords{$word}) {
                    $word = "\$$word";
                }
            }
            $cond = join " ", @condWords;
            if ($expr ne "" and $expr =~ m/(print\s*.*?);/) {
                my $tmp = "$1";
                $expr =~ s/print\s*.*?;/${tmp}, "\\n";/g;
            }        
            ($expr ne "") ? (print "$keyword ($cond) { $expr }", "\n") : (print "$keyword ($cond) {\n");

        } elsif ($line =~ m/(break|continue)/) {
            # captures break and continue statements
            if ("$1" eq "break") {
                print "last;", "\n";
            } else {
                print "next;", "\n";
            }
            
        } else {
            # Lines that can't be translated are turned into comments
            print "#$line\n";
        }
    }
}