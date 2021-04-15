package File::Temp::Patch::VarOptions;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

use Module::Patch qw();
use base qw(Module::Patch);

my $wrap_tempfile = sub {
    my $ctx = shift;
    my $orig = $ctx->{orig};

    my $template;
    if (@_ % 2) { $template = shift }

    no warnings 'once';
    $orig->(
        TEMPLATE => $template // $File::Temp::TEMPLATE,
        DIR      => $File::Temp::DIR,
        SUFFIX   => $File::Temp::SUFFIX,
        UNLINK   => $File::Temp::UNLINK,
        OPEN     => $File::Temp::OPEN,
        TMPDIR   => $File::Temp::TMPDIR,
        EXLOCK   => $File::Temp::EXLOCK,
        @_,
    );
};

my $wrap_tempdir = sub {
    my $ctx = shift;
    my $orig = $ctx->{orig};

    my $template;
    if (@_ % 2) { $template = shift }

    no warnings 'once';
    $orig->(
        CLEANUP  => $File::Temp::CLEANUP,
        DIR      => $File::Temp::DIR,
        TMPDIR   => $File::Temp::TMPDIR,
        @_,
    );
};

sub patch_data {
    return {
        v => 3,
        config => {
        },
        patches => [
            {
                action      => 'wrap',
                mod_version => qr/^0\.*/,
                sub_name    => 'tempdir',
                code        => $wrap_tempdir,
            },
            {
                action      => 'wrap',
                mod_version => qr/^0\.*/,
                sub_name    => 'tempfile',
                code        => $wrap_tempfile,
            },
        ],
    };
}

1;
# ABSTRACT: Allow File::Temp's tempfile() and tempdir() to receive options via package variables

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

 use File::Temp::Patch::VarOptions;
 use File::Temp qw(tempfile tempdir);

 {
     local $File::Temp::SUFFIX = '.html';
     ($fh, $filename) = tempfile(); # use .html suffix
     ...
     ($fh, $filename) = tempfile('XXXXXXXX', SUFFIX=>''); # use empty suffix
 }
 ...
 ($fh, $filename) = tempfile(); # use empty suffi


=head1 DESCRIPTION

This patch allows L<File::Temp>'s C<tempfile()> to get options from package
variables:

 $File::Temp::TEMPLATE
 $File::Temp::DIR
 $File::Temp::SUFFIX
 $File::Temp::UNLINK
 $File::Temp::OPEN
 $File::Temp::TMPDIR
 $File::Temp::EXLOCK

and L<File::Temp>'s C<tempdir()> to get options from package variables:

 $File::Temp::CLEANUP
 $File::Temp::DIR
 $File::Temp::TMPDIR


=head1 SEE ALSO

A non-patch version of this functionality: L<File::Temp::VarOptions>

L<File::Temp>

=cut
