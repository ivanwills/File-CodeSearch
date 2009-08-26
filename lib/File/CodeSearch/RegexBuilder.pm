package File::CodeSearch::RegexBuilder;

# Created on: 2009-08-07 18:41:21
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

has regex => (
	is  => 'rw',
);
has re => (
	is  => 'ro',
	isa => 'ArrayRef',
);
has whole => (
	is  => 'ro',
	isa => 'Bool',
);
has all => (
	is  => 'ro',
	isa => 'Bool',
);
has words => (
	is  => 'ro',
	isa => 'Bool',
);
has files => (
	is  => 'rw',
	isa => 'HashRef',
	default => sub{{}},
);
has current_file => (
	is  => 'rw',
);
has current_count => (
	is  => 'rw',
	isa => 'Int',
	default => 0,
);
has sub_matches => (
	is  => 'rw',
	isa => 'ArrayRef',
);
has sub_match => (
	is  => 'rw',
	isa => 'Bool',
);

sub make_regex {
	my ($self) = @_;
	my $re;
	my $words = $self->re;

	if ($self->whole) {
		@{$words} = map { "(?<!\\w)$_(?!\\w)" } @{$words};
	}

	if ($self->all) {
		if (@{ $words } == 2 ) {
			$re = "$words->[0].*$words->[1]|$words->[1].*$words->[0]";
		}
	}
	elsif ( $self->words ) {
		$re = join '.*', @{ $words };
	}
	else {
		$re = join ' ', @{ $words };
	}

	return $self->regex(qr/$re/);
}

sub match {
	my ($self, $line) = @_;
	my $re = $self->regex || $self->make_regex;

	$self->check_sub_matches($line);
	my $match = $line =~ /$re/;

	if ($match) {
		$self->current_count( $self->current_count + 1 );
	}

	return $match;
}

sub check_sub_matches {
	my ($self, $line) = @_;
	my $matches = $self->sub_matches;
	my $match = 0;

	return if !$matches || !ref $matches;
	return if $self->sub_match;

	for my $match (@$matches) {
		$match ||= $line =~ /$match/;
	}

	$self->sub_match($match);

	return undef;
}

sub reset_file {
	my ($self, $file) = @_;
	if ( $self->current_count() && $self->current_file ) {
		$self->files->{$self->current_file} = $self->current_count;
	}

	$self->sub_match(0);
	$self->current_count(0);
	$self->current_file($file);

	return;
}


1;

__END__

=head1 NAME

File::CodeSearch::RegexBuilder - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to File::CodeSearch::RegexBuilder version 0.1.


=head1 SYNOPSIS

   use File::CodeSearch::RegexBuilder;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).


=head1 SUBROUTINES/METHODS

=head2 C<make_regex ()>

=head2 C<match ($line)>

=head2 C<sub_matches ($line)>

=head2 C<reset_file ()>

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
