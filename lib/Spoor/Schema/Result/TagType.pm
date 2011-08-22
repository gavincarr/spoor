package Spoor::Schema::Result::TagType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Spoor::Schema::Result::TagType

=cut

__PACKAGE__->table("tag_type");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 tags

Type: has_many

Related object: L<Spoor::Schema::Result::Tag>

=cut

__PACKAGE__->has_many(
  "tags",
  "Spoor::Schema::Result::Tag",
  { "foreign.type" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-07-19 07:37:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Cv/KIqrZ6yTRX7BnJwmWEg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
