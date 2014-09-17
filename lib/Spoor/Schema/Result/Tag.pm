use utf8;
package Spoor::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Spoor::Schema::Result::Tag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<tag>

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<type_tag_unique>

=over 4

=item * L</type>

=item * L</tag>

=back

=cut

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
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 type

Type: belongs_to

Related object: L<Spoor::Schema::Result::TagType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "Spoor::Schema::Result::TagType",
  { id => "type" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 posts

Type: many_to_many

Composing rels: L</post_tags> -> post

=cut

__PACKAGE__->many_to_many("posts", "post_tags", "post");


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-09-17 11:58:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hO4fmTCRJiH0w79+fPWPiA

1;
