package Spoor::Auth;

sub dsn      { "dbi:SQLite:dbname=$ENV{SPOOR_HOME}/var/spoor.db" }
sub dsn_test { "dbi:SQLite:dbname=$ENV{SPOOR_HOME}/var/spoor_test.db" }

1;

