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
	default => sub{[qw{.git .bzr .svn CVS logs?(?:$|/) cover_db .orig$ .copy$ ~\d*$ _build blib \\.sw[po]$ [.]png$ [.]jpe?g$ [.]gif$ [.]swf$ [.]ttf$ }]},
);
has include => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
);
has exclude => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
);
has include_type => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
	default => sub{[]},
);
has exclude_type => (
	is  => 'rw',
	isa => 'ArrayRef[Str]',
	default => sub{[]},
);
has symlinks => (
	is  => 'rw',
	isa => 'Bool',
	default => 0,
);

Readonly my %TYPE_SUFFIXES => (
		perl => {
			definite => [qw/ [.]pl$ [.]pm$ [.]pod$ [.]PL$ /],
			possible => [qw/ [.]t$ [.]cgi$ /],
			other_types => [qw/  /],
			none     => 1,
		},
		php => {
			definite => [qw/ [.]php$ /],
			possible => [qw/ [.]lib$ [.]pkg$ [.]t$ /],
			other_types => [qw/  /],
			none     => 0,
		},
		c => {
			definite => [qw/ [.]c$ [.]cpp$ [.]c++$ [.]h$ [.]hpp$ [.]hxx$ [.]h++$ /],
			possible => [qw/  /],
			other_types => [qw/  /],
			none     => 0,
		},
		html => {
			definite => [qw/ [.]html$ [.]xhtml$ /],
			possible => [qw/ [.]xml$ /],
			other_types => [qw/  /],
			none     => 0,
		},
		test => {
			definite => [qw/ [.]t$ /],
			possible => [qw/  /],
			other_types => [qw/  /],
			none     => 0,
		},
		svg => {
			definite => [qw/ svg /],
			possible => [qw/  /],
			other_types => [qw/  /],
			none     => 0,
		},
		sql => {
			definite => [qw/ [.]sql$ [.]plsql$ /],
			possible => [qw/  /],
			other_types => [qw/  /],
			none     => 0,
		},
		css => {
			definite => [qw/ [.]css$ /],
			possible => [qw/  /],
			other_types => [qw/  /],
			none     => 0,
		},
		javascript => {
			definite => [qw/ [.]js$ /],
			possible => [qw/ /],
			other_types => [qw/  /],
			none     => 0,
		},
		js => {
			definite => [qw/  /],
			possible => [qw/  /],
			other_types => [qw/ javascript /],
			none     => 0,
		},
		xml => {
			definite => [qw/xml$ [.]xsd$ [.]xslt$ [.]dtd/],
			possible => [qw/  /],
			other_types => [qw/  /],
			none     => 0,
		},
		web => {
			definite => [qw/  /],
			possible => [qw/  /],
			other_types => [qw/ html svg css javascript /],
			none     => 0,
		},
		scripting => {
			definite => [qw/  /],
			possible => [qw/  /],
			other_types => [qw/ perl php javascript /],
			none     => 0,
		},
		package => {
			definite => [qw/ [.]PL$ MANIFEST$ MANIFEST.SKIP$ Meta.yml$ README$ Changes$ /],
			possible => [qw/  /],
			other_types => [qw/  /],
			none     => 0,
		},
		config => {
			definite => [qw/  /],
			possible => [qw/ rc$ tab$ [.]cfg$ [.]conf$ [.]config$  [.]yml$ /],
			other_types => [qw/  /],
			none     => 0,
		},
		binary => {
			definite => [qw/ [.]jpe?g$ [.]png$ [.]gif$ [.]bmp$ [.]swf$ [.]psd$ [.]exe$ /],
			possible => [qw/  /],
			other_types => [qw/  /],
			none     => 0,
		},
	);


sub file_ok {
	my ($self, $file) = @_;

	return 0 if !$self->symlinks && -l $file;

	for my $ignore (@{ $self->ignore }) {
		return 0 if $file =~ /$ignore/;
	}

	return 1 if -d $file;

	my $possible = 0;
	my $matched = 0;
	for my $type (@{ $self->include_type }) {
		my $match = $self->types_match($file, $type);
		return 0 if !$match;
		$possible-- if $match == 2;
		$matched++;
	}

	if (!$matched) {
		for my $type (@{ $self->exclude_type }) {
			my $match = $self->types_match($file, $type);
			return 0 if $match && $match != 2;
			$possible++ if $match == 2;
		}
		return 0 if $possible > 0;
	}

	if ($self->include) {
		my $matches = 0;
		for my $include (@{ $self->include }) {
			$matches ||= $file =~ /$include/;
			last if $matches;
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

	my $types = \%TYPE_SUFFIXES;

	return 0 if !exists $types->{$type};

	for my $suffix ( @{ $types->{$type}{definite} } ) {
		return 3 if $file =~ /$suffix/;
	}

	for my $suffix ( @{ $types->{$type}{possible} } ) {
		return 2 if $file =~ /$suffix/;
	}

	return 1 if $types->{$type}{none} && $file !~ m{ [^/] [.] [^/]+ $}xms;

	for my $other ( @{ $types->{$type}{other_types} } ) {
		my $match = $self->types_match($file, $other);
		return $match if $match;
	}

	return 0;
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
