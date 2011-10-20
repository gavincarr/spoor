# Spoor Forwarder Factory
# 
# Old-school OO class so we don't have to require stuff like Moose
#

package Spoor::ForwarderFactory;

use strict;
use FindBin qw($Bin);
use Config::Tiny;
use Carp;

sub new {
  my ($class, %arg) = @_;

  my $target = $arg{target}
    or die "Missing required 'target' argument\n";

  # Check configfile
  my $configfile = $arg{config} || "$Bin/../conf/forwarder.conf";
  -f $configfile
    or die "Cannot find required config file '$configfile'\n";

  # Load config
  my $config = Config::Tiny->read( $configfile );

  # Load target config section
  my $config_section = $config->{ $target }
    or die "No '$target' section found in '$configfile'\n";

  # Check required attributes
  $config_section->{tag}
    or die "Missing required 'tag' attribute in config [ $target ] section\n";
  my $forwarder = $config_section->{forwarder}
    or die "Missing required 'forwarder' attribute in config [ $target ] section\n";

  # Instantiate and return forwarder class
  my $f = eval "require Spoor::Forwarder::$forwarder; Spoor::Forwarder::${forwarder}->new";
  die $@ if $@;
  $f->init( %arg, config => $config_section );
  return $f;
}

1;

