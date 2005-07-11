package Sys::RunAlone;

# Set version
# Make sure we're strict
# Make sure we know how to lock

$VERSION = '0.04';
use strict;
use Fcntl ':flock';

# Satisfy -require-

1;

#---------------------------------------------------------------------------
#
# Standard Perl functionality
#
#---------------------------------------------------------------------------

# Run this when we start executing
#  Let the world know if there's no DATA handle and quit
#  Let the world know if the script is already running and quit

INIT {
    print( STDERR "Add __END__ to end of script '$0'\n" ),exit 2
     if tell( *main::DATA ) == -1;
    print( STDERR "A copy of '$0' is already running\n"), exit 1
     unless flock main::DATA,LOCK_EX | LOCK_NB;
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

=head1 REQUIRED MODULES

 Fcntl (any)

=head1 CAVEATS

Execution of scripts that are (sym)linked to another script, will all be seen
as execution of the same script, even though the error message will only show
the specified script name.  This could be considered a bug or a feature.

=head1 ACKNOWLEDGEMENTS

Inspired by Randal Schwartz's mention of using the DATA handle as a semaphore
on the London PM mailing list.

=head1 SEE ALSO

L<Sys::RunAlways>.

=head1 AUTHOR

 Elizabeth Mattijsen

=head1 COPYRIGHT

Copyright (c) 2005 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
