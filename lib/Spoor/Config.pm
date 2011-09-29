package Spoor::Config;

use strict;
use Config::Tiny;
use File::Basename;

# Set $SPOOR_HOME to our grandparent directory
my $SPOOR_HOME = dirname dirname dirname $INC{"Spoor/Config.pm"};

sub _init {
  my $self = shift;

  my $config = $self->{config} = Config::Tiny->read( "$SPOOR_HOME/conf/spoor.conf" );
  $self->{tag} = {};
  $self->{typemap} = {};

  for my $section (keys %$config) {
    next if $section eq '_';
    if (! $config->{$section}->{tag}) {
      warn "Config section '$section' has no 'tag' element - skipping\n";
      next;
    }

    my $tag = delete $config->{$section}->{tag};
    $self->{tag}->{$tag} = $config->{$section};

    next unless $config->{$section}->{type};

#   $self->{log}->debug("adding $tag to $config->{$section}->{type} typemap") if $self->{log};
    $self->{typemap}->{ $config->{$section}->{type} }->{ $tag } = 1;
  }
}

sub new {
  my $class = shift;
  my $self = bless { @_ }, $class;
  $self->_init;
# $self->{log}->debug("private_tags: " . join(',', $self->private_tags)) if $self->{log};
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

sub is_private_tag {
  my ($self, $tag) = @_;
  return 1 if ($self->{tag}->{$tag}->{type} || '') eq 'private';
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
  my @tags = sort keys %{ $self->{typemap}->{default} };
  return wantarray ? @tags : \@tags;
}

sub private_tags {
  my $self = shift;
  my @tags = sort keys %{ $self->{typemap}->{private} };
  return wantarray ? @tags : \@tags;
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

