package Spoor::Auth;

use strict;
use File::Basename;

my $SPOOR_HOME = dirname dirname dirname $INC{'Spoor/Auth.pm'};

sub dsn      { "dbi:SQLite:dbname=$SPOOR_HOME/var/spoor.db" }
sub dsn_test { "dbi:SQLite:dbname=$SPOOR_HOME/var/spoor_test.db" }

1;

