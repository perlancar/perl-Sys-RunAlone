
BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use Test::More tests => 14;
use strict;
use warnings;
sub slurp ($) { open( my $handle,$_[0] ); local $/; <$handle> }

ok( open( my $handle,'>script' ),"Create script #1: $!" );
print $handle <<'EOD';
$| = 1;
use Sys::RunAlone;
<>;
EOD
ok( close( $handle ),"Close script #1: $!" );

ok( open( my $stdin,"| $^X -I$INC[-1] script 2>2" ),"Run script #1: $!" );
chomp( my $error = slurp 2 );
is( $error,"Add __END__ to end of script 'script'","Error message #1" );
ok( !close( $stdin ),"Close pipe #1: $!" );

ok( open( $handle,'>script' ),"Create script #2: $!" );
print $handle <<'EOD';
$| = 1;
use Sys::RunAlone;
<>;
__END__
EOD
ok( close( $handle ),"Close script #2: $!" );

ok( open( my $stdin1,"| $^X -I$INC[-1] script 2>2" ),"Run script #2: $!" );
sleep 2;
chomp( my $error1 = slurp 2 );
is( $error1,"","Error message #2" );

ok( open( my $stdin2,"| $^X -I$INC[-1] script 2>2" ),"Run script #2: $!" );
sleep 2;
chomp( my $error2 = slurp 2 );
is( $error2,"A copy of 'script' is already running","Error message #2a" );
ok( !close( $stdin2 ),"Close pipe #2a: $!" );

print $stdin1 $/;
ok( close( $stdin1 ),"Close pipe #2: $!" );

is( 2,unlink( qw(script 2) ),"Cleanup" );
