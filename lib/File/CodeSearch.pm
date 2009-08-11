package File::CodeSearch;

# Created on: 2009-08-07 18:32:44
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use warnings;
use version;
use Carp;
use Scalar::Util;
use List::Util;
#use List::MoreUtils;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;

has regex => (
	is  => 'rw',
	isa => 'File::CodeSearch::RegexBuilder',
);
has files => (
	is      => 'rw',
	isa     => 'File::CodeSearch::Files',
	default => sub { File::CodeSearch::Files->new },
);
has breadth => (
	is      => 'rw',
	isa     => 'Bool',
	default => 0,
);
has depth => (
	is      => 'rw',
	isa     => 'Bool',
	default => 0,
);

sub search {
	my ($self, $search, @dirs) = blessed $_[0] ? @_ : __PACKAGE__->new, @_;

	for my $dir (@dirs) {
		$self->_find($search, $dir);
	}

	return;
}

sub _find {
	my ($self, $search, $dir) = @_;

	opendir my $dirh, $dir or warn "Could not open '$dir': $OS_ERROR\n" and return;
	my @files = grep { $_ ne '.' && $_ ne '..' } readdir $dirh;

	if ($self->breadth) {
		@files = sort \&_breadth @files;
	}
	elsif ($self->deapth) {
		@files = sort \&_deapth @files;
	}

	for my $file (@files) {
	}

	return;
}

sub _breadth {
	return
		  -f "$dir/$a" && -d "$dir/$b" ? 1
		: -d "$dir/$a" && -f "$dir/$b" ? -1
		:                                0;
}
sub _depth {
	return
		  -f "$dir/$a" && -d "$dir/$b" ? -1
		: -d "$dir/$a" && -f "$dir/$b" ? 1
		:                                0;
}

1;

__END__

=head1 NAME

File::CodeSearch - Search file contents in code repositories

=head1 VERSION

This documentation refers to File::CodeSearch version 0.1.

=head1 SYNOPSIS

   use File::CodeSearch;

   # Simple usage
   code_search {
	   my ($file, $line) = @_;
	   // do stuff
   },
   @dirs;

   # More control
   my $cs = File::CodeSearch->new();
   $cs->code_search(sub {}, @dirs);

=head1 DESCRIPTION

Module to search through directory trees ignoring certain directories,
like version controll directories or log directory, also skipping certain
files like backup files and binary file.

=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.


=head3 C<new ( $search, )>

Param: C<$search> - type (detail) - description

Return: File::CodeSearch -

Description:

=cut


=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)
<Author name(s)>  (<contact address>)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
