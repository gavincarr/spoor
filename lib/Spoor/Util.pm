package Spoor::Util;

use strict;
use Exporter::Lite;
use Time::Piece;
use Regexp::Common qw(microsyntax);
use Lingua::EN::Inflect qw(PL);

use Spoor::Auth;
use Spoor::Schema;

our @EXPORT = ();
our @EXPORT_OK = qw(
  get_schema
  extract_target_hashtags
  default_target_hashtags
  ts2tp
  ts2tp_offset
  ts2iso8601
  ts2iso8601_offset
  ts_human_inflect
  tp2human_duration
);

sub get_schema 
{
  my $env = shift || $ENV{SPOOR_ENV} || '';
  Spoor::Schema->connect(
    $env eq 'test' ? Spoor::Auth::dsn_test : Spoor::Auth::dsn,
    '',
    '',
    { sqlite_unicode => 1 },
  ) or die "db connect failed: $!";
}

# Return the set of database default target hashtags
sub default_target_hashtags 
{
  my ($schema) = @_;

  $schema->resultset('Tag')->search({
    type                => '#',
    target_b            => 1,
    default_target_b    => 1,
  })->all;
}

# Return the set of database target hashtags (if any) present in the given text
sub extract_target_hashtags 
{
  my ($schema, $text) = @_;

  my @hashtags = map { substr $_, 1 } ($text =~ m/$RE{microsyntax}{hashtag}/og);

  my @tags = $schema->resultset('Tag')->search({
    type        => '#',
    tag         => \@hashtags,
    target_b    => 1,
  })->all;
  return @tags if @tags;

  return default_target_hashtags($schema);
}

# Convert a sqlite timestamp to a Time::Piece object
sub ts2tp {
  Time::Piece->strptime(shift, '%Y-%m-%d %T');
}

# Format a Time::Piece time as ISO8601 (UTC)
sub tp2iso8601 {
  shift->strftime('%Y-%m-%dT%TZ');
}

# Format sqlite timestamp as iso8601 date (in UTC)
sub ts2iso8601 {
  my $tp = ts2tp(shift);
  tp2iso8601($tp);
}

# Add an offset to given sqlite timestamp
sub ts2tp_offset {
  my ($ts, $offset) = @_;
  my $tp = ts2tp($ts);
  $tp += $offset;
  return $tp;
}

# Add an offset to given sqlite timestamp, and format as iso8601 (in UTC)
sub ts2iso8601_offset {
  my ($ts, $offset) = @_;
  my $tp = ts2tp($ts);
  $tp += $offset;
  tp2iso8601($tp);
}

sub ts_human_inflect {
  my ($count, $unit) = @_;
  sprintf "%d %s ago", $count, PL($unit, int $count);
}

# Can't find anything on CPAN to carve this up the right way
sub tp2human_duration {
  my ($tp, $now) = @_;
  $now ||= localtime;

  my $delta = $now - $tp;
  my $seconds = $delta->seconds;

  my $ts_human;
  if ($seconds < 1) {
    $ts_human = 'Just now';
  }
  elsif ($seconds < 60) {
    $ts_human = ts_human_inflect($seconds, 'second');
  }
  elsif ($seconds < 3600) {
    $ts_human = ts_human_inflect($seconds / 60, 'minute');
  }
  elsif ($seconds < 24 * 3600) {
    $ts_human = ts_human_inflect($seconds / 3600, 'hour');
  }
  elsif ($seconds < 3 * 24 * 3600) {
    $ts_human = ts_human_inflect($seconds / (24 * 3600), 'day');
  }
  elsif ($tp->year == $now->year) {
    $ts_human = $tp->strftime('%d %b');
  }
  else {
    $ts_human = $tp->strftime('%d %b %Y');
  }

  return $ts_human;
}

1;

