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
  my $forwarder = ucfirst $target;

  # Load config
  my $config = Config::Tiny->read( $configfile );

  # Load target config section
  my $config_section;
  if ($config_section = $config->{ $target }) {

    # Check required attributes
    $config_section->{tag}
      or die "Missing required 'tag' attribute in config [ $target ] section\n";
    $forwarder = $config_section->{forwarder} if $config_section->{forwarder};
  }

  # Instantiate and return forwarder class
  my $f = eval "require Spoor::Forwarder::$forwarder; Spoor::Forwarder::${forwarder}->new";
  die $@ if $@;
  $f->init( %arg, ($config_section ? (config => $config_section) : ()) );
  return $f;
}

1;

