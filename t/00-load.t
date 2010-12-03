#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 5 + 1;
use Test::NoWarnings;

BEGIN {
    use_ok( 'File::CodeSearch' );
    use_ok( 'File::CodeSearch::Files' );
    use_ok( 'File::CodeSearch::Highlighter' );
    use_ok( 'File::CodeSearch::RegexBuilder' );
    use_ok( 'File::CodeSearch::Replacer' );
}

diag( "Testing File::CodeSearch $File::CodeSearch::VERSION, Perl $], $^X" );
