#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;
use Term::ANSIColor qw/:constants/;
use File::CodeSearch::Highlighter;

regexes();
highlights();
done_testing();

sub highlights {
    my $hl = File::CodeSearch::Highlighter->new(
        re             => ['test'],
        before_match   => '',
        after_match    => '',
        before_nomatch => '',
        after_nomatch  => '',
    );
    $hl->make_highlight_re;
    is($hl->highlight('this test string'), 'this test string' . RESET . "\\N\n", 'no extra text gives back string');

    $hl = File::CodeSearch::Highlighter->new(
        re             => ['test'],
        before_match   => '-',
        after_match    => '=',
        before_nomatch => '*',
        after_nomatch  => '#',
    );
    is($hl->highlight('this test string'), '*this #-test=* string#' . RESET . "\\N\n", 'the appropriate higlights are put in');

    $hl = File::CodeSearch::Highlighter->new(
        re             => ['test'],
        before_match   => '-',
        after_match    => '=',
        before_nomatch => '*',
        after_nomatch  => '#',
    );
    is($hl->highlight('this test string with test again'), '*this #-test=* string with #-test=* again#' . RESET . "\\N\n", 'the appropriate higlights are put in');
}

sub regexes {
    my $hl = File::CodeSearch::Highlighter->new( re => ['test'] );
    $hl->make_regex;
    $hl->make_highlight_re;
    is($hl->highlight_re, qr/test/, 'simple re returns simple string');

    $hl = File::CodeSearch::Highlighter->new( re => ['(test)'] );
    $hl->make_highlight_re;
    is($hl->highlight_re, qr/(?:test)/, 'simple re returns simple string');

    $hl = File::CodeSearch::Highlighter->new( re => ['(?:test)'] );
    $hl->make_highlight_re;
    is($hl->highlight_re, qr/(?:test)/, 'simple re returns simple string');

    $hl = File::CodeSearch::Highlighter->new( re => ['(?xmsi:test)'] );
    $hl->make_highlight_re;
    is($hl->highlight_re, qr/(?xmsi:test)/, 'simple re returns simple string');

    return;
}
