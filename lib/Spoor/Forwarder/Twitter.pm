package Spoor::Forwarder::Twitter;

use strict;
use parent 'Spoor::Forwarder::Identica';
use Regexp::Common qw(microsyntax);

sub connect {
  my $self = shift;
  $self->SUPER::connect( identica => 0 );
}

# Process post content, returning the content to forward
sub process_post {
  my ($self, $title, $content) = @_;

  $title = $self->SUPER::process_post($title, $content);

  # Convert identica groups to normal hashtags for twitter
  $title =~ s|$RE{microsyntax}{grouptag}{-keep}|#$3|g;

  return $title;
}

1;

