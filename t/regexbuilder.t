#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;
use Term::ANSIColor qw/:constants/;
use File::CodeSearch::RegexBuilder;

simple();
whole();
array();
array_all();
array_words();
match();
sub_match();
reset_file();
done_testing();

sub simple {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test'],
    );
    $re->make_regex;
    is($re->regex, qr/test/, 'simple');

    $re = File::CodeSearch::RegexBuilder->new(
        re             => ['(test)'],
    );
    $re->make_regex;
    is($re->regex, qr/(test)/, 'simple');

}

sub whole {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test'],
        whole          => 1,
    );
    $re->make_regex;
    is($re->regex, qr/(?<!\w)test(?!\w)/, 'whole');

}

sub array {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test', 'words'],
    );
    $re->make_regex;
    is($re->regex, qr/test words/, 'words concatinated with spaces');

    $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test', 'words'],
        whole          => 1,
    );
    $re->make_regex;
    is($re->regex, qr/(?<!\w)test(?!\w) (?<!\w)words(?!\w)/, 'simple');

}

sub array_words {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test', 'words'],
        words          => 1,
    );
    $re->make_regex;
    is($re->regex, qr/test.*words/, 'words');

    $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test', 'words'],
        words          => 1,
        whole          => 1,
    );
    $re->make_regex;
    is($re->regex, qr/(?<!\w)test(?!\w).*(?<!\w)words(?!\w)/, 'simple');

}

sub array_all {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test', 'words'],
        all            => 1,
    );
    $re->make_regex;
    is($re->regex, qr/test.*words|words.*test/, 'all');

    $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test', 'words'],
        all            => 1,
        whole          => 1,
    );
    $re->make_regex;
    is($re->regex, qr/(?<!\w)test(?!\w).*(?<!\w)words(?!\w)|(?<!\w)words(?!\w).*(?<!\w)test(?!\w)/, 'simple');

}

sub match {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test'],
    );
    ok($re->match('this is a test'), 'matches "this is a test"');
    ok($re->match('testter'), 'matches "testter"');
    ok($re->match('intestter'), 'matches "intestter"');
    ok(!$re->match('intes'), 'matches "intes"');
    ok(!$re->match('estter'), 'matches "estter"');

    $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test', 'this'],
        all            => 1,
    );
    ok($re->match('test this'), 'test this');
    ok($re->match('this test'), 'this test');
    ok(!$re->match('test'), 'test');
    ok(!$re->match('this'), 'this');

    return;
}

sub sub_match {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test'],
    );
    $re->sub_matches(['a']);

    return;
}

sub reset_file {
    my $re = File::CodeSearch::RegexBuilder->new(
        re             => ['test'],
    );
    $re->reset_file('');
    is($re->current_count, 0, 'count zero');
    $re->match('testter');
    is($re->current_count, 1, 'count one');
    $re->reset_file('');
    is($re->current_count, 0, 'reset count zero');

    return;
}
