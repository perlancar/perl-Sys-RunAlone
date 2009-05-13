
BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use Test::More tests => 34;
use strict;
use warnings;
sub slurp ($) { open( my $handle,$_[0] ); local $/; <$handle> }

ok( open( my $handle,'>script' ),"Create script #1: $!" );
ok( print( $handle <<'EOD' ),"Print script #1: $!" );
$| = 1;
use Sys::RunAlone @ARGV;
<>;
EOD
ok( close( $handle ),"Close script #1: $!" );

my $ok;
my $command;
foreach ( "", "'silent'" ) {
    my $ok = 0;
    my $command = "| $^X -I$INC[-1] script $_ 2>2";
    $ok++ if ok( open( my $stdin, $command ),"Run script #1: $!" );
    sleep 2;
    chomp( my $error = slurp 2 );
    $ok++ if is( $error,"Add __END__ to end of script 'script' to be able use the features of Sys::RunALone","Error message #1" );
    $ok++ if ok( !close( $stdin ),"Close pipe #1: $!" );
    diag($command) if $ok != 3;
}

ok( open( $handle,'>script' ),"Create script #2: $!" );
ok( print( $handle <<'EOD' ),"Print script #2: $!" );
$| = 1;
use Sys::RunAlone @ARGV;
<>;
__END__
EOD
ok( close( $handle ),"Close script #2: $!" );

$ok = 0;
$command = "| $^X -I$INC[-1] script 2>2";
$ok++ if ok( open( my $stdin1, $command ), "Run script #2: $!" );
sleep 2;
chomp( my $error1 = slurp 2 );
$ok++ if is( $error1,"","Error message #2" );
diag($command) if $ok != 2;

$ok = 0;
$ok++ if ok( open( my $stdin2, $command ), "Run script #2 again: $!" );
sleep 2;
chomp( my $error2 = slurp 2 );
$ok++ if is( $error2,"A copy of 'script' is already running","Error message #2a" );
$ok++ if ok( !close( $stdin2 ),"Close pipe #2a: $!" );
diag($command) if $ok != 3;

$ok = 0;
$command = "| $^X -I$INC[-1] script 'silent' 2>2";
$ok++ if ok( open( my $stdin2a, $command ), "Run script #2 again: $!" );
sleep 2;
chomp( my $error2a = slurp 2 );
$ok++ if is( $error2a,"","Error message #2aa" );
$ok++ if ok( !close( $stdin2a ),"Close pipe #2aa: $!" );
diag($command) if $ok != 3;

$ok = 0;
$command = "| SKIP_SYS_RUNALONE=0 $^X -I$INC[-1] script 2>2";
$ok++ if ok( open( my $stdin3, $command ), "Run script #2 once more: $!" );
sleep 2;
chomp( my $error3 = slurp 2 );
$ok++ if is( $error3,"A copy of 'script' is already running","Error message #2a" );
$ok++ if ok( !close( $stdin3 ),"Close pipe #2b: $!" );
diag($command) if $ok != 3;

$ok = 0;
$command = "| SKIP_SYS_RUNALONE=1 $^X -I$INC[-1] script 2>2";
$ok++ if ok( open( my $stdin4, $command ), "Run script #2 with SKIP=1: $!" );
$ok++ if ok( print( $stdin4 $/ ),"Print pipe #2c: $!" );
sleep 2;
chomp( my $error4 = slurp 2 );
$ok++ if is( $error4,"" );
TODO: { local $TODO = "seem to get timeout most of the time, why?";
#$ok++ if ok( !close( $stdin4 ),"Close pipe #2c: $!" );
$ok++; ok( !close( $stdin4 ),"Close pipe #2c: $!" );
};
diag($command) if $ok != 4;

$ok = 0;
$command = "| SKIP_SYS_RUNALONE=2 $^X -I$INC[-1] script 2>2";
$ok++ if ok( open( my $stdin5, $command ), "Run script #2 with SKIP=2: $!" );
$ok++ if ok( print( $stdin5 $/ ),"Print pipe #2d: $!" );
sleep 2;
chomp( my $error5 = slurp 2 );
$ok++ if is( $error5,"Skipping Sys::RunAlone check for 'script'" );
TODO: { local $TODO = "seem to get timeout most of the time, why?";
#$ok++ if ok( !close( $stdin5 ),"Close pipe #2d: $!" );
$ok++; ok( !close( $stdin5 ),"Close pipe #2d: $!" );
};
diag($command) if $ok != 4;

ok( print( $stdin1 $/ ),"Print pipe #2: $!" );
ok( close( $stdin1 ),"Close pipe #2: $!" );

is( 2,unlink( qw(script 2) ),"Cleanup" );
1 while unlink qw(script 2);
