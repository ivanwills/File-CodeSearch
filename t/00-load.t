#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1 + 1;
use Test::NoWarnings;

BEGIN {
	use_ok( 'File::CodeSearch' );
}

diag( "Testing File::CodeSearch $File::CodeSearch::VERSION, Perl $], $^X" );
