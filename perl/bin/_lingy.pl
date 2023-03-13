#!/usr/bin/env perl

use strict; use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Lingy::REPL;

use Getopt::Long;

my $base = $Bin;

@ARGV = ('--shell') unless (@ARGV or not -t STDIN);

my $shell = '';
my $eval = '';
my $run = '';

GetOptions (
    "shell" => \$shell,
    "eval=s" => \$eval,
) or die("Error in command line arguments\n");

if (@ARGV) {
    $run = $ARGV[0];
    $run = '/dev/stdin' if $run eq '-';
} else {
    if (not -t STDIN) {
        $run = '/dev/stdin';
        unshift @ARGV, '<stdin>';
    } else {
        unshift @ARGV, 'NO_SOURCE_PATH';
    }
}

my $repl = Lingy::REPL->new;

if ($eval) {
    if ($shell) {
        $repl->rep(qq<(do $eval)>);
        $repl->repl;
    } else {
        $repl->rep(qq<(prn (do $eval))>);
    }

} elsif ($shell) {
    $repl->repl;

} elsif ($run) {
    if ($run ne '/dev/stdin') {
        -f $run or die "No such file '$run'";
        $run =~ /\.ly$/ or
            die "Don't know how to run '$run'";
    }
    $repl->rep(qq<(load-file "$run")>);

} else {
    $repl->repl;
}
