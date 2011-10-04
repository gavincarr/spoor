package Spoor::Auth;

use strict;
use File::Basename;

sub dsn      { "dbi:SQLite:dbname=$ENV{SPOOR_HOME}/var/spoor.db" }
sub dsn_test { "dbi:SQLite:dbname=$ENV{SPOOR_HOME}/var/spoor_test.db" }

1;

