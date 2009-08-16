package File::CodeSearch::Highlighter;

# Created on: 2009-08-07 18:42:16
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
use Term::ANSIColor qw/:constants/;

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();
#our @EXPORT      = qw//;

extends 'File::CodeSearch::RegexBuilder';

has highlight_re => (
	is  => 'rw',
);
has before_match => (
	is      => 'rw',
	isa     => 'Str',
	default => BOLD . RED,
);
has after_match => (
	is      => 'rw',
	isa     => 'Str',
	default => RESET,
);
has before_nomatch => (
	is      => 'rw',
	isa     => 'Str',
	default => BOLD,
);
has after_nomatch => (
	is      => 'rw',
	isa     => 'Str',
	default => RESET,
);

sub make_highlight_re {
	my ($self) = @_;
	my $re = $self->regex || $self->make_regex;

	# make sure that all brackets are for non capture groups
	$re =~ s/ [(] (?! [?] ) /(?:/gxms;

	return $self->highlight_re($re);
}

sub highlight {
	my ($self, $string) = @_;
	my $re  = $self->highlight_re || $self->make_highlight_re;
	my $out = '';

	my @parts = split /($re)/, $string;

	for my $i ( 0 .. @parts - 1 ) {
		if ( $i % 2 ) {
			$out .= $self->before_match . $parts[$i] . $self->after_match;
		}
		else {
			$out .= $self->before_nomatch . $parts[$i] . $self->after_nomatch;
		}
	}

	return $out;
}

1;

__END__

=head1 NAME

File::CodeSearch::Highlighter - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to File::CodeSearch::Highlighter version 0.1.


=head1 SYNOPSIS

   use File::CodeSearch::Highlighter;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head3 C<highlight ( $search, )>

Param: C<$search> - type (detail) - description

Return: File::CodeSearch::Highlighter -

Description:

=head3 C<make_highlight_re ( $search, )>

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
