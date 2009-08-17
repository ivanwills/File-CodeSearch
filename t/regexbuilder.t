#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 10 + 1;
use Test::NoWarnings;
use Term::ANSIColor qw/:constants/;
use File::CodeSearch::RegexBuilder;

simple();
whole();
array();
array_all();
array_words();
complex();

sub simple {
	my $re = File::CodeSearch::RegexBuilder->new(
		re             => ['test'],
	);
	$re->make_regex;
	is($re->regex, '(?-xism:test)', 'simple');

	$re = File::CodeSearch::RegexBuilder->new(
		re             => ['(test)'],
	);
	$re->make_regex;
	is($re->regex, '(?-xism:(test))', 'simple');

}

sub whole {
	my $re = File::CodeSearch::RegexBuilder->new(
		re             => ['test'],
		whole          => 1,
	);
	$re->make_regex;
	is($re->regex, '(?-xism:(?<!\w)test(?!\w))', 'whole');

}

sub array {
	my $re = File::CodeSearch::RegexBuilder->new(
		re             => ['test', 'words'],
	);
	$re->make_regex;
	is($re->regex, '(?-xism:test words)', 'words concatinated with spaces');

	$re = File::CodeSearch::RegexBuilder->new(
		re             => ['test', 'words'],
		whole          => 1,
	);
	$re->make_regex;
	is($re->regex, '(?-xism:(?<!\w)test(?!\w) (?<!\w)words(?!\w))', 'simple');

}

sub array_words {
	my $re = File::CodeSearch::RegexBuilder->new(
		re             => ['test', 'words'],
		words          => 1,
	);
	$re->make_regex;
	is($re->regex, '(?-xism:test.*words)', 'words');

	$re = File::CodeSearch::RegexBuilder->new(
		re             => ['test', 'words'],
		words          => 1,
		whole          => 1,
	);
	$re->make_regex;
	is($re->regex, '(?-xism:(?<!\w)test(?!\w).*(?<!\w)words(?!\w))', 'simple');

}

sub array_all {
	my $re = File::CodeSearch::RegexBuilder->new(
		re             => ['test', 'words'],
		all            => 1,
	);
	$re->make_regex;
	is($re->regex, '(?-xism:test.*words|words.*test)', 'all');

	$re = File::CodeSearch::RegexBuilder->new(
		re             => ['test', 'words'],
		all            => 1,
		whole          => 1,
	);
	$re->make_regex;
	is($re->regex, '(?-xism:(?<!\w)test(?!\w).*(?<!\w)words(?!\w)|(?<!\w)words(?!\w).*(?<!\w)test(?!\w))', 'simple');

}

sub complex {
	my $re = File::CodeSearch::RegexBuilder->new(
		re             => ['test'],
	);
	$re->make_regex;
	is($re->regex, '(?-xism:test)', 'words concatinated with spaces');

}

