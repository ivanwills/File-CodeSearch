#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 00 + 1;
use Test::NoWarnings;
use Term::ANSIColor qw/:constants/;
use FindBin qw/$Bin/;
use File::CodeSearch::Highlighter;
use File::CodeSearch;

simple();

sub simple {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test'],
    );
    my $cs = File::CodeSearch->new(
        regex  => $re,
    );
    $cs->search(sub{}, $Bin);
    $cs->depth(1);
    $cs->search(sub{}, $Bin);
    $cs->breadth(1);
    $cs->search(sub{}, $Bin);
}
