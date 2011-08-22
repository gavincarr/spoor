# Spoor Forwarder base class, for building forwarders to remote endpoints
# 
# This is an old-school OO class so we don't have to require stuff like Moose
#

package Spoor::Forwarder;

use strict;
use File::Basename;
use Getopt::Long qw(:config no_ignore_case bundling);
use FindBin qw($Bin);
use Config::Tiny;
use XML::Atom::Feed;
use URI;
use Time::Piece;
use YAML;

sub _init {
  my $self = shift;

  $self->{me} = basename($0);
  $self->{short} = basename($0);
  $self->{short} =~ s/^forwarder_?//;
  $self->{config_file} = "$Bin/../conf/forwarder.conf";
  $self->{state_dir} = "$Bin/../var";
  $self->{state_file} = "$self->{state_dir}/$self->{me}.dat";

  return $self;
}

sub usage { 
  my $self = shift;
  die "usage: $self->{me} [-v] [-c <count>] [--noop]\n";
}

# Process command-line options
sub _process_options {
  my $self = shift;
  my $store_option_sub = sub { my ($k, $v) = @_; $self->{$k} = $v };

  my $help;
  $self->{verbose} = 0;
  usage unless GetOptions(
    'help|h|?'    => \$help,
    'count|c=i'   => $store_option_sub,
    'noop|n'      => $store_option_sub,
    'verbose|v+'  => $store_option_sub,
  );
  usage if $help;
  $self->{verbose} ||= 1 if $self->{noop};
}

# Load config from $self->{short} section in $self->{config_file}
sub _load_config {
  my $self = shift;

  -f $self->{config_file} 
    or  die "Cannot find forwarder config file '$self->{config_file}'\n";
  -r $self->{config_file} 
    or  die "Cannot read forwarder config file '$self->{config_file}'\n";

  my $config = Config::Tiny->read( $self->{config_file} );
  exists $config->{$self->{short}}
    or die "Cannot find '$self->{short}' section in forwarder config file\n";
  $self->{config_obj} = $config;
  $self->{config} = $config->{$self->{short}};
}

sub _load_state {
  my $self = shift;

  -d $self->{state_dir}
    or die "Cannot find state directory '$self->{state_dir}'\n";
  -w $self->{state_dir}
    or die "Cannot write to state directory '$self->{state_dir}'\n";

  if (-f $self->{state_file}) {
    $self->{state} = Config::Tiny->read($self->{state_file})
      or die "Cannot load state file '$self->{state_file}'\n";
  }
  else {
    $self->{state} = Config::Tiny->new;
    $self->{state}->{_} ||= {};
  }
  $self->{state_changed} = 0;
}

# Load feed from config 'feed' uri
sub _load_feed {
  my $self = shift;

  $self->{feed} = XML::Atom::Feed->new( URI->new($self->{config}->{feed}) )
    or die "Loading feed '$self->{config}->{feed}' failed: $!\n";
}

# Process all entries in feed
sub _process_feed {
  my $self = shift;

  my $st = $self->{state}->{_};
  printf STDERR "+ last item published: [%s] %s: %s\n", 
    $st->{id} || '', $st->{published} || '', $st->{title} || ''
      if $self->{verbose};
  my $i = 0;
  for my $entry (reverse $self->{feed}->entries) {
    # Skip entries we've already seen
    my $id = $entry->id;
    $id =~ s!^.*/post/!!;
    next if $id <= $st->{id};
#   next if $st->{published} && $entry->published lt $st->{published};

    # Finish if next published date is in the future
    last if $entry->published gt gmtime->strftime('%Y-%m-%dT%TZ');

    # New entry - process
    printf "+ processing new item: [%s] %s\n", $st->{id}, $st->{title} || ''
      if $self->{verbose};
    if ($self->process_entry( $entry )) {
      # Update state
      $st->{published} = $entry->published;
      $st->{id} = $id;
      $st->{title} = $entry->title;
      $st->{title} =~ s/[\r\n]+/ /g;
      $self->{state_changed}++;
    }

    last if ++$i >= $self->{count};
  }

  $self->{state}->write( $self->{state_file} ) if $self->{state_changed};
}

# Process entry, returning true on success (forwarded or skipped)
sub process_entry {
  my ($self, $entry) = @_;

  my $post = $self->process_post($entry->title, $entry->content);
  printf "[%s] %s\n", $entry->published, $post if ! ref $post && $self->{verbose};

  warn "Error: process_entry not overridden - unable to forward\n";
  return 0;
}

# Process post content, returning the content to forward (usually a scalar)
sub process_post {
  my ($self, $title, $content) = @_;
  if (my $pp = $self->{config}->{process_post}) {
    if (ref $pp && ref $pp eq 'ARRAY') {
      eval "\$title =~ $_" foreach @$pp;
    }
    elsif (! ref $pp) {
      eval "\$title =~ $pp";
    }
  }
  return $title;
}

sub new {
  my $self = bless {}, shift;
  $self->_init;
}

sub run {
  my $self = shift;
  $self = $self->new if ! ref $self;
  $self->_process_options;
  $self->_load_config;
  $self->_load_state;
  $self->_load_feed;
  $self->_process_feed;
}

1;

