package File::CodeSearch::Files;

# Created on: 2009-08-11 06:20:53
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use warnings;
use version;
use Readonly;
use Data::Dumper qw/Dumper/;
use Carp;
use English qw/ -no_match_vars /;

our $VERSION     = version->new('0.0.1');

has ignore => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
	default => sub{[qw{.git .bzr .svn CVS logs?(?:$|/) cover_db .orig$ .copy$ ~\d*$ _build blib \\.sw[po]$}]},
);
has include => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
);
has exclude => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
);
has types => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
	default => sub{[]},
);
has notypes => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
	default => sub{[]},
);

Readonly my %TYPE_SUFFIXES => (
		perl => {
			definite => [qw/ pl pm pod /],
			possible => [qw/ t cgi /],
			none     => 1,
		},
		php => {
			definite => ['php'],
			possible => [qw/ lib pkg /],
		},
		html => {
			definite => [qw/ html xhtml /],
			possible => [qw/xml/],
		},
		css => {
			definite => ['css'],
		},
		javascript => {
			definite => ['js'],
			possible => [qw/ lib pkg /],
		},
		web => {
			other_types => [qw/ html css javascript /],
		},
	);


sub file_ok {
	my ($self, $file) = @_;

	for my $ignore (@{ $self->ignore }) {
		return 0 if $file =~ /$ignore/;
	}

	for my $type (@{ $self->types }) {
		return 0 if !$self->types_match($file, $type);
	}

	for my $type (@{ $self->notypes }) {
		return 0 if $self->types_match($file, $type);
	}

	if ($self->include) {
		my $matches = 0;
		for my $include (@{ $self->include }) {
			$matches ||= $file =~ /$include/;
		}
		return 0 if !$matches;
	}

	if ($self->exclude) {
		for my $exclude (@{ $self->exclude }) {
			return 0 if $file =~ /$exclude/;
		}
	}

	return 1;
}

sub types_match {
	my ($self, $file, $type) = @_;

}

1;

__END__

=head1 NAME

File::CodeSearch::Files - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to File::CodeSearch::Files version 0.1.


=head1 SYNOPSIS

   use File::CodeSearch::Files;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION


=head1 SUBROUTINES/METHODS

=head2 C<file_ok ($file)>

Determines weather B<$file> should be searched

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
