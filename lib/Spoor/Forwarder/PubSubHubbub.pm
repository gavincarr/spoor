package Spoor::Forwarder::PubSubHubbub;

use strict;
use parent 'Spoor::Forwarder';
use Net::PubSubHubbub::Publisher;

# Process entry, returning true on success (forwarded or skipped)
sub forward_post {
  my ($self, $post, $entry) = @_;

  # Only ping once
  return if $self->{done};

  unless ($self->{noop}) {
    my $config = $self->{spoor_config};
    my $pub = Net::PubSubHubbub::Publisher->new(hub => $config->get('pshb_hub'))
      or die "Constructor failed: $!";
    $pub->publish_update($config->get('url') . "/index.atom")
      or die "Ping failed: " . $pub->last_response->status_line;
  }

  $self->{done} = 1;
}

1;

