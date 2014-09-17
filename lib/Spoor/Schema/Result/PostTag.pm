use utf8;
package Spoor::Schema::Result::PostTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Spoor::Schema::Result::PostTag

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<post_tag>

=cut

__PACKAGE__->table("post_tag");

=head1 ACCESSORS

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 tag_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "tag_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</post_id>

=item * L</tag_id>

=back

=cut

__PACKAGE__->set_primary_key("post_id", "tag_id");

=head1 RELATIONS

=head2 post

Type: belongs_to

Related object: L<Spoor::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "Spoor::Schema::Result::Post",
  { id => "post_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 tag

Type: belongs_to

Related object: L<Spoor::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "Spoor::Schema::Result::Tag",
  { id => "tag_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-09-17 11:57:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/ZCnKlcT1uWOxjnoAMu8CA

__PACKAGE__->set_primary_key(qw(post_id tag_id));


1;
