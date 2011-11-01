package Spoor::Forwarder::Delicious;

use strict;
use base 'Spoor::Forwarder';

use Net::Delicious;
use LWP::UserAgent;
use HTML::TreeBuilder;
use Regexp::Common qw(microsyntax);
use YAML;

use Spoor::Config;

# Process entry, returning true on success (forwarded or skipped)
sub forward_post {
  my ($self, $post, $entry) = @_;

  # Skip posts without urls
  unless ($post->{url}) {
    print "No url found in post '" . $entry->title . "' - skipping \n" 
      if $self->{verbose};
    return 1;
  }

  unless ($self->{noop}) {
    $self->{delicious} ||= Net::Delicious->new({
      user      => $self->{config}->{username},
      pswd      => $self->{config}->{password},
      $self->{config}->{endpoint} ? ( endpoint  => $self->{config}->{endpoint} ) : (),
    }) or die "Connect to delicious failed\n";
    
    $self->{delicious}->add_post({
      url             => $post->{url},
      description     => $post->{desc},
      tags            => $post->{tags},
      dt              => $entry->published,
    }) or die "Delicious add post failed for post: " . $entry->title . "\n";

    return 1;
  }

  return 0;
}

# Process post content, returning the content to forward
sub process_post {
  my ($self, $post, $content) = @_;
  $post = $self->SUPER::process_post($post, $content);

  # Fetch url to try and expand url shortener links
  my $ua = LWP::UserAgent->new(max_redirect => 20);
  $ua->env_proxy;
  my $title = $post;
  my $url;
  if ($post =~ s/($RE{URI}{HTTP})\S*\s*//) {
    $url = $1;
    my $resp = $ua->get($url);
    if ($resp->is_success) {
      $url = $resp->base->as_string;
      if (my $root = HTML::TreeBuilder->new_from_content($resp->decoded_content)) {
        if (my @t = $root->look_down(_tag => 'title')) {
          $title = $t[0]->as_text;
        }
      }
    }
  }

  # Collate hashtags and groups, ignoring any that are target tags
  my $config = Spoor::Config->new;
  my %target_tag = map { $_ => 1 } $config->tags;
  my @hashtags  = $post =~ m/$RE{microsyntax}{hashtag}/og;
  my @grouptags = $post =~ m/$RE{microsyntax}{grouptag}/og;
  my $tags = join ' ',
             grep { ! $target_tag{$_} }
             map { substr($_, 1) }
             @hashtags, @grouptags;

  return {
    url => $url,
    desc => $title,
    tags => $tags,
  };
}

1;

