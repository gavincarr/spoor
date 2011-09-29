# Spoor::Util tests

use Test::More;

use_ok('Spoor::Util');

my ($str);

for my $i (0 .. 9) {
  like($str = Spoor::Util::ts_human_inflect($i, 'minute'), $i == 1 ? qr/minute\b/ : qr/minutes\b/,
    "ts_human_inflect for count $i ok: $str");
}

done_testing;

