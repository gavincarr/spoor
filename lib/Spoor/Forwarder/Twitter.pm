package Spoor::Forwarder::Twitter;

use strict;
use base 'Spoor::Forwarder::Identica';
use Text::Microblog qw(replace_groups);

sub connect {
  my $self = shift;
  $self->SUPER::connect( identica => 0 );
}

# Process post content, returning the content to forward
sub process_post {
  my ($self, $title, $content) = @_;
  $title = $self->SUPER::process_post($title, $content);

  return replace_groups($title, sub {
    my $group = shift;
    return '#' . substr($group, 1);
  });
}

1;

