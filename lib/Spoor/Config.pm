package Spoor::Config;

use strict;
use Config::Tiny;

sub _init {
  my $self = shift;

  my $config = $self->{config} = Config::Tiny->read( $ENV{SPOOR_HOME} . "/spoor.conf" );
  $self->{tag} = {};
  $self->{default_tags} = [];

  for my $section (keys %$config) {
    next if $section eq '_';
    if (! $config->{$section}->{tag}) {
      warn "Config section '$section' has no 'tag' element - skipping\n";
      next;
    }

    my $tag = delete $config->{$section}->{tag};
    $self->{tag}->{$tag} = $config->{$section};

    next unless $config->{$section}->{type};
    push @{$self->{default_tags}}, $tag
      if $config->{$section}->{type} eq 'default';
  }
}

sub new {
  my $class = shift;
  my $self = bless {}, $class;
  $self->_init;
  return $self;
}

sub get {
  my ($self, $key) = @_;
  $self->{config}->{_}->{$key};
}

sub is_reset_tag {
  my ($self, $tag) = @_;
  return 1 if ($self->{tag}->{$tag}->{type} || '') eq 'reset';
}

sub is_default_tag {
  my ($self, $tag) = @_;
  return 1 if ($self->{tag}->{$tag}->{type} || '') eq 'default';
}

sub is_remove_tag {
  my ($self, $tag) = @_;
  return 1 if ($self->{tag}->{$tag}->{remove} || '') =~ m/^1|yes|true$/i;
}

sub tags {
  my $self = shift;
  my @tags = keys %{$self->{tag}};
  return wantarray ? @tags : \@tags;
}

sub default_tags {
  my $self = shift;
  return wantarray ? @{$self->{default_tags}} : $self->{default_tags};
}

1;

=head1 NAME

Spoor::Config - spoor configuration data

=head1 SYNOPSIS

    use Spoor::Config;

    $config = Spoor::Config->new;

    # Config accessors
    $delay = $config->get('publish_delay');

    # Target tag accessors
    @tags = $config->tags;
    @defaults = $config->default_tags;
    print $config->is_reset_tag($tag);
    print $config->is_remove_tag($tag);

=cut

