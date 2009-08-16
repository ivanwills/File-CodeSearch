package File::CodeSearch::Files;

# Created on: 2009-08-11 06:20:53
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
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

has ignore => (
	is  => 'rw',
	isa => 'ArrayRef',
	default => sub{[qw/.git .bzr .svn CVS logs? cover_db .orig$ .copy$ ~\d*$ _build blib/]},
);

sub file_ok {
	my ($self, $file) = @_;

	for my $ignore (@{ $self->ignore }) {
		return 0 if $file =~ /$ignore/;
	}

	return 1;
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
