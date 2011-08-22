package Spoor::Auth;

use strict;
use File::Basename;

# Set $SPOOR_HOME to our grandparent directory
my $SPOOR_HOME = dirname dirname dirname $INC{"Spoor/Auth.pm"};

sub dsn      { "dbi:SQLite:dbname=$SPOOR_HOME/var/spoor.db" }
sub dsn_test { "dbi:SQLite:dbname=$SPOOR_HOME/var/spoor_test.db" }

1;

