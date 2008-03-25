package Sys::RunAlone;

# version info
$VERSION = '0.08';

# make sure we're strict and verbose as possible
use strict;
use warnings;

# make sure we know how to lock
use Fcntl ':flock';

# satisfy -require-
1;

#---------------------------------------------------------------------------
#
# Standard Perl functionality
#
#---------------------------------------------------------------------------

INIT {
    no warnings;

    # skipping
    if ( my $skip = $ENV{SKIP_SYS_RUNALONE} ) {
        print STDERR "Skipping " . __PACKAGE__ . " check for '$0'\n"
          if $skip > 1;
    }

    # no data handle, we're screwed
    elsif ( tell( *main::DATA ) == -1 ) {
        print STDERR "Add __END__ to end of script '$0'"
          . " to be able use the features of Sys::RunALone\n";
        exit 2;
    }

    # we're not alone!
    elsif ( !flock main::DATA, LOCK_EX | LOCK_NB ) {
        print STDERR "A copy of '$0' is already running\n";
        exit 1;
    }
} #INIT

#---------------------------------------------------------------------------

__END__

=head1 NAME

Sys::RunAlone - make sure only one invocation of a script is active at a time

=head1 SYNOPSIS

 use Sys::RunAlone;
 # code of which there may only be on instance running on system

=head1 DESCRIPTION

Provide a simple way to make sure the script from which this module is
loaded, is only running once on the server.

=head1 VERSION

This documentation describes version 0.08.

=head1 METHODS

There are no methods.

=head1 THEORY OF OPERATION

The functionality of this module depends on the availability of the DATA
handle in the script from which this module is called (more specifically:
in the "main" namespace).

At INIT time, it is checked whethere there is a DATA handle: if not, it
exits with an error message on STDERR and an exit value of 2.

If the DATA handle is available, and it cannot be C<flock>ed, it exits
with an error message on STDERR and an exit value of 1.

If there is a DATA handle, and it could be C<flock>ed, execution continues
without any further interference.

=head1 OVERRIDING CHECK

In some cases, the same script may need to be run simultaneously with another
incarnation (but possibly with different parameters).  In order to simplify
this type of usage, it is possible to specify the environment variable
C<SKIP_SYS_RUNALONE> with a true value.

 SKIP_SYS_RUNALONE=1 yourscript.pl

will run the script always.

 SKIP_SYS_RUNALONE=2 yourscript.pl

will actually be verbose about this and say:

 Skipping Sys::RunAlone check for 'yourscript.pl'

=head1 REQUIRED MODULES

 Fcntl (any)

=head1 CAVEATS

=head2 symlinks

Execution of scripts that are (sym)linked to another script, will all be seen
as execution of the same script, even though the error message will only show
the specified script name.  This could be considered a bug or a feature.

=head2 changing a running script

If you change the script while it is running, the script will effectively
lose its lock on the file.  Causing any subsequent run of the same script
to be successful, causing two instances of the same script to run at the
same time (which is what you wanted to prevent by using Sys::RunAlone in
the first place).  Therefore, make sure that no instances of the script are
running (and won't be started by cronjobs while making changes) if you really
want to be 100% sure that only one instance of the script is running at the
same time.

=head1 ACKNOWLEDGEMENTS

Inspired by Randal Schwartz's mention of using the DATA handle as a semaphore
on the London PM mailing list.

=head1 SEE ALSO

L<Sys::RunAlways>.

=head1 AUTHOR

 Elizabeth Mattijsen

=head1 COPYRIGHT

Copyright (c) 2005, 2006, 2008 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
