package Spoor::Forwarder::Identica;

use strict;
use base 'Spoor::Forwarder';

use Net::Twitter::Lite::WithAPIv1_1;

sub connect {
  my ($self, %arg) = @_;

  my %nt_config = (
    identica            => 1,
    source              => 'spoor',
    clientname          => 'spoor',
    clienturl           => 'https://github.com/gavincarr/spoor',
    legacy_lists_api    => 0,
    $self->{config}->{endpoint} ? ( apiurl => $self->{config}->{endpoint} ) : (),
    %arg
  );

  # If user and pass are set use Basic Auth, else OAuth
  my $oauth = 0;
  if ($self->{config}->{username} && $self->{config}->{password}) {
    $nt_config{username} = $self->{config}->{username};
    $nt_config{password} = $self->{config}->{password};
  }
  elsif ($self->{config}->{spoor_oauth_key} &&
         $self->{config}->{spoor_oauth_secret}) {
    push @{$nt_config{traits}}, 'OAuth';
    $nt_config{consumer_key}    = $self->{config}->{spoor_oauth_key};
    $nt_config{consumer_secret} = $self->{config}->{spoor_oauth_secret};
    $nt_config{ssl} = 1;
    $oauth = 1;
  }

  $self->{nt} ||= Net::Twitter::Lite::WithAPIv1_1->new( %nt_config )
    or die "Cannot instantiate Net::Twitter::Lite object: $!";

  return unless $oauth;

  if ($self->{config}->{access_token} && 
      $self->{config}->{access_token_secret}) {

    $self->{nt}->access_token($self->{config}->{access_token});
    $self->{nt}->access_token_secret($self->{config}->{access_token_secret});
  }

  unless ($self->{nt}->authorized) {
    printf "Forwarder is not authorized - please do so at %s\nand enter PIN number:\n",
      $self->{nt}->get_authorization_url;
    my $pin = <STDIN>;
    chomp $pin;

    if (my ($access_token, $access_token_secret, $user_id, $screen_name) =
        $self->{nt}->request_access_token(verifier => $pin)) {

      $self->{config}->{access_token} = $access_token;
      $self->{config}->{access_token_secret} = $access_token_secret;

      $self->{config_obj}->write( $self->{config_file} )
        or die "Save access tokens to config file " . $self->{config_file} . " failed: $!";
    }
  }
}

# Process entry, returning true on success (forwarded or skipped)
sub forward_post {
  my ($self, $post, $entry) = @_;

  unless ($self->{noop}) {
    $self->connect;
    my $params = { status => $post };
    if (my $point = $entry->point) {
      my ($lat, $long) = split /\s+/, $point;
      $params->{lat}  = $lat;
      $params->{long} = $long;
    }
    $self->{nt}->update($params)
      or die "Status update failed: " . $self->{nt}->get_error->{error} . "\n";

    return 1;
  }

  return 0;
}

1;

