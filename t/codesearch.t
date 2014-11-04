#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings qw/warning/;
use Term::ANSIColor qw/:constants/;
use FindBin qw/$Bin/;
use File::CodeSearch::Highlighter;
use File::CodeSearch;

simple();
message();
done_testing();

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

sub message {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test'],
    );
    my $cs = File::CodeSearch->new(
        regex  => $re,
    );

    is warning { $cs->_message(qw/type name error/) }, "Could not open the type 'name': error\n";
    $cs->quiet(1);

    # the test warnings will pick this up if it warns
    $cs->_message(qw/type name error/);
}
