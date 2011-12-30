# Quick-and-dirty GeoRSS Simple extension for Atom
#
# Based on Brian Cassidy's XML::Atom::Ext::OpenSearch
#

package XML::Atom::Ext::GeoRSS;

use strict;
use warnings;

use base qw( XML::Atom::Base );
use XML::Atom::Entry;

our $VERSION = '0.01';

BEGIN {
  XML::Atom::Entry->mk_elem_accessors(
    qw(point line polygon box circle featureTypeTag relationshipTag featureName elev floor radius),
    [ XML::Atom::Namespace->new(georss => q(http://www.georss.org/georss)) ],
  );
}

sub element_ns {
  return XML::Atom::Namespace->new(georss => q(http://www.georss.org/georss));
}

1;

