# Spoor::Forwarder tests

use Test::More 0.88;
use FindBin qw($Bin);
use YAML qw(LoadFile Dump);
use Data::Dump qw(pp);

use_ok('Spoor::ForwarderFactory');

my @sections = qw(identica status twitter delicious pinboard);

my ($f);

for my $section (@sections) {
  ok($f = Spoor::ForwarderFactory->new(config => "$Bin/t20/forwarder.conf", section => $section),
    "$section forwarder instantiated ok: $f");
  is($f->{section}, $section, "section set: $section");
  ok($f->{forwarder}, "forwarder set: $f->{forwarder}");
  ok($f->{tag}, "tag set: $f->{tag}");
  ok($f->{spoor_config}, "spoor_config set: $f->{spoor_config}");
  ok($f->{spoor_config}->get('url'), "spoor_config url set: " . $f->{spoor_config}->get('url'));
}

done_testing;

