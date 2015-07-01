#!/usr/bin/env perl

use strict;
use warnings;

my $regression = ($ARGV[0] && $ARGV[0] =~ /--regression/i);
my $exit = 0;
for (<tests/*.sil>, <examples/*.sil>, "documentation/sile.sil") {
    next if /macros.sil/;
    my $expectation = $_; $expectation =~ s/\.sil$/\.expected/;
    if (-f $expectation and $regression) {
        # Only test OSX specific regressions if running OSX
        if ($_ =~ /_darwin\.sil/ && $^O !~ 'darwin') {
            next;
        }
        print "### Regression testing $_\n";
        my $out = $_; $out =~ s/\.sil$/\.actual/;
        exit $? >> 8 if system qq{./sile -e 'require("core/debug-output")' $_ > $out};
        if (system("diff -U0 $expectation $out")) {
			$exit = 1;
        }
    } elsif (!$regression) {
        print "### Compiling $_\n";
        exit $? >> 8 if system("./sile", $_);
    }
}
exit $exit;
