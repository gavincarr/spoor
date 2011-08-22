package Spoor::Delta;

use base 'DBIx::Delta';
use DBI;
use FindBin qw($Bin);

sub connect { 
  my $self = shift;
  my $env = $self->environment;
  $env = "_$env" if $env;
  DBI->connect( "dbi:SQLite:dbname=$Bin/../var/spoor$env.db" );
}

sub environment {
  my $self = shift;
  return $ENV{SPOOR_ENV} || '';
}

1;

