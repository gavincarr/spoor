package Spoor::Schema::Result::PostTag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Spoor::Schema::Result::PostTag

=cut

__PACKAGE__->table("post_tag");

=head1 ACCESSORS

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 tag_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "tag_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 RELATIONS

=head2 tag

Type: belongs_to

Related object: L<Spoor::Schema::Result::Tag>

=cut

__PACKAGE__->belongs_to(
  "tag",
  "Spoor::Schema::Result::Tag",
  { id => "tag_id" },
  { join_type => "LEFT" },
);

=head2 post

Type: belongs_to

Related object: L<Spoor::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "Spoor::Schema::Result::Post",
  { id => "post_id" },
  { join_type => "LEFT" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-07-19 07:37:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kOBbOe5mSfFDCX2s6grAsA

__PACKAGE__->set_primary_key(qw(post_id tag_id));


1;
