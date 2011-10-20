# Spoor::Forwarder tests

use strict;
use Test::More 0.88;
use FindBin qw($Bin);
use YAML qw(LoadFile Dump);
use Data::Dump qw(pp);

use_ok('Spoor::ForwarderFactory');

my @targets = qw(identica status twitter delicious pinboard);

my ($f);

for my $target (@targets) {
  ok($f = Spoor::ForwarderFactory->new(config => "$Bin/t20/forwarder.conf", target => $target),
    "$target forwarder instantiated ok: $f");
  is($f->{target}, $target, "target set: $target");
  ok($f->{config}->{forwarder}, "forwarder set: $f->{config}->{forwarder}");
  ok($f->{config}->{tag}, "tag set: $f->{config}->{tag}");
  ok($f->{spoor_config}, "spoor_config set: $f->{spoor_config}");
  ok($f->{spoor_config}->get('url'), "spoor_config url set: " . $f->{spoor_config}->get('url'));
}

done_testing;

