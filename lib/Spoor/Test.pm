package Spoor::Test;

use strict;
use Exporter::Lite;
use YAML qw(LoadFile);
use Carp;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Spoor::Auth;
use Spoor::Schema;

our @EXPORT = qw(
  get_test_schema
  get_test_url
  load_fixture_data
);
our @EXPORT_OK = qw(
);

sub get_test_schema {
  Spoor::Schema->connect( Spoor::Auth::dsn_test ) 
    or die "db connect failed: $!";
}

sub get_test_url {
  return 'http://localhost:3001';
}

# Truncate and load fixture data, returning a hash of loaded records
sub load_fixture_data {
  my ($schema, $table) = @_;

  # Load fixture data
  my $datafile = "$Bin/fixtures/\L$table.yml";
  die "Cannot find fixture data '$datafile'" unless -f $datafile;
  my $data = LoadFile($datafile);
  return () unless keys %$data;

  # Truncate data
  $schema->resultset($table)->delete;

  # Load data
  my %rows;
  for my $name (keys %$data) {
    my $create_data = $data->{$name};
    my $row = $schema->resultset($table)->create($create_data)
      or die "Fixture data create failed: $!";
    $rows{$name} = $row->get_from_storage;
  };

  return wantarray ? %rows : \%rows;
}

1;

