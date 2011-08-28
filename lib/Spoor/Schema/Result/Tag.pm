package Spoor::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Spoor::Schema::Result::Tag

=cut

__PACKAGE__->table("tag");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 type

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "type",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "tag",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("type_tag_unique", ["type", "tag"]);

=head1 RELATIONS

=head2 post_tags

Type: has_many

Related object: L<Spoor::Schema::Result::PostTag>

=cut

__PACKAGE__->has_many(
  "post_tags",
  "Spoor::Schema::Result::PostTag",
  { "foreign.tag_id" => "self.id" },
  {},
);

=head2 type

Type: belongs_to

Related object: L<Spoor::Schema::Result::TagType>

=cut

__PACKAGE__->belongs_to("type", "Spoor::Schema::Result::TagType", { id => "type" }, {});


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-07-19 07:37:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3lc+2G1BKa9hhyYwsu3lkA


=head2 posts

Type: many_to_many

Related object: L<Spoor::Schema::Result::Post>

=cut

__PACKAGE__->many_to_many(
  "posts",
  "post_tags",
  'post',
);


1;
