#
# Spoor Forwarder base class, for building forwarders to remote endpoints
# 
# Old-school OO class so we don't have to require stuff like Moose
#

package Spoor::Forwarder;

use strict;
use XML::Atom;
use Encode 2.43;
use URI;
use Time::Piece;
use YAML;
use Carp;

use FindBin qw($Bin);
use Spoor::Config;
use XML::Atom::Ext::GeoRSS;

# Force utf-8 decoding on input
$XML::Atom::ForceUnicode = 1;

sub init {
  my ($self, %arg) = @_;

  $self->{$_} = $arg{$_} foreach keys %arg;

  $self->{target}
    or croak "Missing required 'target' argument";
  $self->{config}
    or croak "Missing required 'config' argument";

  $self->{state_dir} = "$Bin/../var";
  $self->{state_file} = "$self->{state_dir}/forwarder_$self->{target}.dat";

  $self->{spoor_config} = Spoor::Config->new
    or die "Cannot load spoor config\n";
}

sub new {
  bless {}, shift;
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

  my $spoor_config = $self->{spoor_config};
  my $url = $self->{spoor_config}->get('url')
    or die "Spoor config 'url' not found - cannot generate feed url\n";
  $url =~ s! /+ $ !!x;
  my $feed_uri = $self->{config}->{tag} ? "$url/tag/$self->{config}->{tag}.atom" : "$url/index.atom";
  $feed_uri = URI->new($feed_uri);
  $feed_uri->userinfo($spoor_config->get('username') . ':' . $spoor_config->get('password'))
    if $spoor_config->get('username') && $spoor_config->get('password');

  $self->{feed} = XML::Atom::Feed->new( $feed_uri )
    or die "Loading feed '$feed_uri' failed.\n";
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

    # Finish if next published date is in the future (for publish_delay handling)
    if ($entry->published gt gmtime->strftime('%Y-%m-%dT%TZ')) {
      printf STDERR "+ next item to publish is in the future, skipping: [%s] %s: %s\n",
        $entry->{id} || '', $entry->{published} || '', $entry->{title} || ''
          if $self->{verbose};
      last;
    }

    # New entry - process
    printf STDERR "+ processing new item: [%s] %s\n", $id, $entry->title || ''
      if $self->{verbose};

    my $post = $self->process_post($entry->title, $entry->content);
    printf STDERR "+ processed: [%s] %s\n", $entry->published, $post
      if ! ref $post && $self->{verbose};

    if ($self->forward_post( $post, $entry )) {
      # Update state
      $st->{published} = $entry->published;
      $st->{id} = $id;
      $st->{title} = encode_utf8 $entry->title;
      $st->{title} =~ s/[\r\n]+/ /g;
      $self->{state_changed}++;
    }

    last if ++$i >= $self->{count};
  }

  $self->{state}->write( $self->{state_file} )
    if $self->{state_changed} && ! $self->{noop};
}

# Process post content, returning the content string to forward (a scalar)
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

# Process entry, returning true on success (indicating forwarded or skipped)
# Should be overridden by subclasses
sub forward_post {
  my ($self, $post, $entry) = @_;
  warn "Error: forward_post not overridden - unable to forward\n";
  return 0;
}

sub run {
  my $self = shift;
  $self->_load_state;
  $self->_load_feed;
  $self->_process_feed;
}

1;

