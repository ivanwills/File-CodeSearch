package File::CodeSearch;

# Created on: 2009-08-07 18:32:44
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use warnings;
use version;
use English qw/ -no_match_vars /;
use IO::Handle;
use File::chdir;
use File::CodeSearch::Files;
use Clone qw/clone/;
use Path::Class qw/file dir/;

our $VERSION     = version->new('0.5.0');

has regex => (
    is       => 'rw',
    isa      => 'File::CodeSearch::RegexBuilder',
    required => 1,
);
has files => (
    is      => 'rw',
    isa     => 'File::CodeSearch::Files',
    default => sub { File::CodeSearch::Files->new },
);
has recurse => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
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
has suround_before => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);
has suround_after => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);
has limit => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);
has links => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub{{}},
);
has found => (
    is      => 'ro',
    isa     => 'Int',
    default => 0,
    writer  => '_found',
);
has replace => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

sub search {
    my ($self, $search, @dirs) = @_;

    for my $dir (@dirs) {
        $self->_find($search, $dir);
    }

    return;
}

sub _find {
    my ($self, $search, $dir, $parent) = @_;
    my @files;
    $dir =~ s{/$}{};

    return if !-d $dir;

    {
        local $CWD = $dir;
        opendir my $dirh, '.' or warn "Could not open the directory '$dir': $OS_ERROR ($CWD)\n" and return;
        @files = sort _alpha_num grep { $_ ne '.' && $_ ne '..' } readdir $dirh;

        if ($self->breadth) {
            @files = sort _breadth @files;
        }
        elsif ($self->depth) {
            @files = sort _depth @files;
        }
    }

    $dir = $dir eq '.' ? '' : "$dir/";

    FILE:
    for my $file (@files) {
        next FILE if !$self->files->file_ok("$dir$file");
        last FILE if $self->limit && $self->found >= $self->limit;

        if (-l "$dir$file") {
            next FILE if !$self->files->symlinks;

            my $real = -f "$dir$file" ? file("$dir$file") : dir("$dir$file");
            $real = $real->absolute->resolve;
            $self->links->{$real} ||= 0;

            next FILE if $self->links->{$real}++;
        }
        if (-d "$dir$file") {
            if ($self->recurse) {
                $self->_find( $search, "$dir$file", $parent || $dir );
            }
        }
        else {
            $self->search_file( $search, "$dir$file", $parent || $dir );
        }
    }

    return;
}

sub _alpha_num {
    my $a1 = $a;
    my $b1 = $b;
    $a1 =~ s/(\d+)/sprintf "%5d", $1/exms;
    $b1 =~ s/(\d+)/sprintf "%5d", $1/exms;
    return $a1 cmp $b1;
}
sub _breadth {
    return
          -f $a && -d $b ? 1
        : -d $a && -f $b ? -1
        :                                0;
}
sub _depth {
    return
          -f $a && -d $b ? -1
        : -d $a && -f $b ? 1
        :                                0;
}

sub search_file {
    my ($self, $search, $file, $parent) = @_;

    open my $fh, '<', $file or warn "Could not open the file '$file': $OS_ERROR\n" and return;

    $self->regex->reset_file;
    $self->regex->current_file($file);
    my $before_max = $self->suround_before;
    my $after_max  = $self->suround_after;
    my @before;
    my @after;
    my @lines;
    my $found = undef;
    my %args = ( before => \@before, after => \@after, lines => \@lines, parent => $parent );
    my @sub_matches;

    LINE:
    while ( my $line = <$fh> ) {
        if ( $self->replace ) {
            push @lines, $line;
        }
        if (!defined $found) {
            push @before, $line;
            shift @before if @before > $before_max + 1;
        }
        elsif ($found) {
            push @after, $line;
            if (@after > $after_max) {
                undef $found;
            }
        }
        else {
        }

        last LINE if @{$self->regex->sub_not_matches} && $self->regex->sub_not_match;

        next LINE if !$self->regex->match($line);

        pop @before;
        pop @after if $args{last_line_no} && $fh->input_line_number - $args{last_line_no} > $after_max - 1;

        if (@{$self->regex->sub_matches}) {
            push @sub_matches, clone [ $line, $file, $fh->input_line_number, %args ];
        }
        else {
            $self->_found( $self->found + 1 );
            $search->($line, $file, $fh->input_line_number, codesearch => $self, %args);
            last LINE if $self->limit && $self->found >= $self->limit;
        }

        $args{last_line_no} = $fh->input_line_number;
        @after = ();
        $found = 1;
    }

    if ( @{$self->regex->sub_matches} && $self->regex->sub_match ) {
        SUB:
        for my $args (@sub_matches) {
            $self->_found( $self->found + 1 );
            $search->( @$args, codesearch => $self );
            last SUB if $self->limit && $self->found >= $self->limit;
        }
    }
    # check if the line is an after match
    if (@after && ( ! @{$self->regex->sub_matches} || $self->regex->sub_match ) ) {
        pop @after if $args{last_line_no} && $fh->input_line_number - $args{last_line_no} > $after_max - 1;
        @before = ();
        $self->_found( $self->found + 1 );
        $search->(undef, $file, $fh->input_line_number, codesearch => $self, %args);
    }

    return;
}

1;

__END__

=head1 NAME

File::CodeSearch - Search file contents in code repositories

=head1 VERSION

This documentation refers to File::CodeSearch version 0.5.0.

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

=head1 SUBROUTINES/METHODS

=head2 C<serach ( $search, @dirs )>

Param: C<$search> - code ref - subroutine to be executed each time a match is found

Param: C<@dir> - paths - an array of the directory paths to search through

Description:

=head2 C<serach_file ( $search, $file, $parent )>

Param: C<$search> - code ref - subroutine to be executed each time a match is found

Param: C<$file> - file - A file to search through line by line

Param: C<$parent> - path - The directory from @dirs which the file was found in

Description:

=over 4

=item search

=item search_file

=back

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
