#!/usr/bin/perl -w
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# Charbel Antouny (z3462611) 2014

# Check if any files have been provided as arguments, else read from STDIN
if (!@ARGV) {
    push @ARGV, "-";
}

$regexVar = "[a-zA-Z][a-zA-Z0-9_]*";
my $indent = 0;
my $curIndent = 0;
my $indentSize = 0;
my %keywords = ("print" =>1, "if" =>1, "while" =>1, "for" =>1, "and" =>1, "or" =>1, "not" =>1);

foreach my $file (@ARGV) {
    open F, "<$file";
    while ($line = <F>) {
        # this block deals with printing indentation
        $line =~ m/^\s*/;
        $curIndent = length($&) if ($line !~ /^\s*$/);
        $indentSize = $curIndent if ($curIndent != 0 and $indentSize == 0);
        if ($curIndent > $indent) {
            $indent = $curIndent;
            for (1..$curIndent) { print " "; }
        } elsif ($curIndent == $indent) {
            for (1..$curIndent) { print " "; }
        } else {
            while ($indent > $curIndent) {
                $indent -= $indentSize;
                if ($indent == 0) { 
                    print "}\n";
                } else {
                    for (1..$indent) { print " "; }
                    print "}\n";
                }
            }
            for (1..$indent) { print " "; }
        }
        
        if ($line =~ m/^#!/ && $. == 1) {
            # translate #! line 
            print "#!/usr/bin/perl -w\n";

        } elsif ($line =~ m/^\s*#/ || $line =~ /^\s*$/) {
            # blank & comment lines are passed unchanged
            print $line;

        } elsif ($line =~ m/\s*print\s*"(.*)"\s*$/) {
            # print a string
            print "print \"$1\\n\";\n";

        } elsif ($line =~ m/\s*print\s*$/) {
            # print new line only
            print "print \"\\n\";", "\n";

        } elsif ($line =~ m/\s*($regexVar)\s*=\s*\[(.*?)\]/) {
            # list assignment
            print "\@$1 = ($2);", "\n";

        } elsif ($line =~ m/\s*print\s*($regexVar)/) {
            # print variable or arithmetic equation involving multiple variables
            my $var = "\"\$$1\"";
            if ($line =~ m/(${regexVar}\s*(\+|-|\*|\/|%|\*\*)\s*${regexVar})+/) {
                $var = "$&";
                $var =~ s/($regexVar)/\"\$$1\"/g;
            }
            print "print $var, \"\\n\";", "\n";
            
        } elsif ($line =~ m/\s*($regexVar)\s*(\+|-)?=\s*([0-9]+|$regexVar)/) {
            # captures numeric and variable assignment
            # also checks for += or -=
            my $var = "\$$1";
            my $operator = ($2) ? ("$2") : ("");
            my $value = "$3";
            if ($line =~ m/(([0-9]*|$regexVar)\s*(\+|-|\*|\/|%|\*\*)\s*([0-9]+|$regexVar))+/) {
                # captures arithmetic equations
                $value = "$&";
                $value =~ s/($regexVar)/\$$1/g;
            } elsif ($line =~ m/\s*sys\.stdin\.readline/) {
                # captures int casting and reading from STDIN
                $value = "<STDIN>";
            }
            print "$var ${operator}= ${value};", "\n";

        } elsif ($line =~ m/\s*(elif|if|while)\s*(.*?):\s*(.*?)$/) {
            # captures if/while statements
            my $keyword = "$1";
            if ($keyword eq "elif") { $keyword = "elsif"; }
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

        } elsif ($line =~ m/\s*for\s+(.*?)\s+in\s+(.*?):/) {
            # captures single and multi-line for statements
            my $var = "\$$1";
            my $seq = "$2";
            if ($seq =~ m/range\s*\((.*?),(.*?)\)/) {
                my $start = "$1";
                $start =~ s/($regexVar)/\$$1/g;
                my $end = "$2";
                $end =~ s/($regexVar)/\$$1/g;
                $end .= "-1";
                print "for $var (${start}..${end}) {";
            } elsif ($seq =~ m/("|')(.*?)("|')/) {
                print "for $var (split //, $2) {";
            } elsif ($seq =~ m/($regexVar)/) {
                my $list = "\@$1";
                if ($seq =~ m/\[\s*(\d|)\s*:\s*(\d|)\s*\]/) {
                    my $start = $1;
                    my $end = $2;
                    if (!$start) { $start = 0; }
                    if (!$end) { $end = 0; }
                    print 'for $var in (@a['."${start}..${end}]) {";
                } else {
                    print 'for '."$var ($list) {";
                }
            }
            if ($line =~ m/:\s*(.+?)$/) {
                my $expr = "$1";
                my @exprWords = split / /, "$expr";
                foreach my $word (@exprWords) {
                    if ($word =~ m/$regexVar/ and !defined $keywords{$word}) {
                        $word = "\$$word";
                    }
                }
                $expr = join " ", @exprWords;
                $expr .= ";";
                print " $expr }", "\n";
            } else {
                print "\n";
            }

        } elsif ($line =~ m/\s*sys\.stdout\.write\((.*?)\)/) {
            # captures sys.stdout.write() commands
            print "print ${1};", "\n";

        } elsif ($line =~ m/\s*(break|continue)/) {
            # captures break and continue statements
            if ("$1" eq "break") {
                print "last;", "\n";
            } else {
                print "next;", "\n";
            }

        } elsif ($line =~ m/\s*else\s*:/) {
            # captures else lines
            print "else {\n";

        } else {
            # Lines that can't be translated are turned into comments
            print "#$line";
        }
    }
}
# this block deals with any remaining } that must be printed
while ($curIndent > 0) {
    $curIndent -= $indentSize;
    if ($curIndent == 0) { 
        print "}\n";
    } else {
        for (1..$curIndent) { print " "; }
        print "}\n";
    }
}