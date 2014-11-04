#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Warnings;
use Term::ANSIColor qw/:constants/;
use File::CodeSearch::Files;

files_ok();
files_nok();
files_exclude();
done_testing();

sub files_ok {
    my $files = File::CodeSearch::Files->new();
    my @ok_files = qw{
        /blah/file
        /blah/file~other
        /blah/logo
        /blah/test.t
    };

    for my $file (@ok_files) {
        ok($files->file_ok($file), $file);
    }

    return;
}

sub files_nok {
    my $files = File::CodeSearch::Files->new();
    my @nok_files = qw{
        /blah/CVS
        /blah/CVS/thing
        /blah/file.copy
        /blah/file~
        /blah/.git
        /blah/logs
    };

    for my $file (@nok_files) {
        ok(!$files->file_ok($file), $file);
    }

    return;
}

sub files_exclude {
    my $files = File::CodeSearch::Files->new( exclude => [qw{/test/}] );

    ok($files->file_ok("perl/test"), 'not excluded');
    ok(!$files->file_ok("perl/test/"), 'excluded');

    return;
}
