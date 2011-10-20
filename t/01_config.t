# Spoor::Config tests

use Test::More;
use Test::Deep;
use File::Basename;
use FindBin qw($Bin);
use YAML qw(Dump LoadFile);

use_ok('Spoor::Config');

my ($c);

my %expected = ();
for (glob "$Bin/t01/*yml") {
  (my $name = basename $_) =~ s/.yml$//;
  $expected{$name} = LoadFile($_);
}

ok($c = Spoor::Config->new(config_file => "$Bin/t01/spoor.conf"), 'construction ok: ' . $c);
is_deeply($c->elsewhere, $expected{elsewhere}, 'elsewhere data matches');

ok($c = Spoor::Config->new(config_file => "$Bin/t01/spoor2.conf"), 'construction2 ok: ' . $c);
is_deeply($c->elsewhere, $expected{elsewhere2}, 'elsewhere2 data matches');

done_testing;

