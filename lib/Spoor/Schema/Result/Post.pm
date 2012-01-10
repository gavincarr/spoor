package Spoor::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Spoor::Schema::Result::Post

=cut

__PACKAGE__->table("post");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 post_raw

  data_type: 'text'
  is_nullable: 0

=head2 post_processed

  data_type: 'text'
  is_nullable: 1

=head2 post_html

  data_type: 'text'
  is_nullable: 1

=head2 timestamp

  data_type: 'integer'
  default_value: current_timestamp
  is_nullable: 1

=head2 forward_flag

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 delete_b

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 latitude

  data_type: 'real'
  is_nullable: 1

=head2 longitude

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "post_raw",
  { data_type => "text", is_nullable => 0 },
  "post_processed",
  { data_type => "text", is_nullable => 1 },
  "post_html",
  { data_type => "text", is_nullable => 1 },
  "timestamp",
  {
    data_type     => "integer",
    default_value => \"current_timestamp",
    is_nullable   => 1,
  },
  "forward_flag",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "delete_b",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "latitude",
  { data_type => "real", is_nullable => 1 },
  "longitude",
  { data_type => "real", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 post_tags

Type: has_many

Related object: L<Spoor::Schema::Result::PostTag>

=cut

__PACKAGE__->has_many(
  "post_tags",
  "Spoor::Schema::Result::PostTag",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-12-30 13:46:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AF337bUknD7trlyNb3iDKA

use Regexp::Common qw(URI microsyntax);
use HTML::Entities qw(encode_entities);
use Time::Piece;

use Spoor::Config;

=head2 tags

Type: many_to_many

Related object: L<Spoor::Schema::Result::Tag>

=cut

__PACKAGE__->many_to_many(
  "tags",
  "post_tags",
  'tag',
);

# -------------------------------------------------------------------------
# Methods

# Add default post_tag entries for this post
sub add_default_hashtags {
  my ($self, $config) = @_;

  my $schema = $self->result_source->schema;

  for my $hashtag ($config->default_tags) {
    # find_or_create tag
    my $tag = $schema->resultset('Tag')->find_or_create({
      type      => '#', 
      tag       => $hashtag,
    })
    or die "Creating tag '#$hashtag' failed: #!";

    # find_or_create post_tag
    $schema->resultset('PostTag')->find_or_create({
      post_id   => $self->id,
      tag_id    => $tag->id,
    })
    or die "Creating post_tag for post " . $self->id . ", tag '#" . $tag->tag . " failed\n";
  }
}

# Extract hashtags from post_raw, and find_or_create tags and post_tags
sub extract_and_create_hashtags {
  my ($self, %arg) = @_;
  my $config = delete $arg{config} || Spoor::Config->new;
  my $remove_all = delete $arg{remove_all};
  my $schema = $self->result_source->schema;

  # Remove all existing post_tags (but not tags) if $remove_all set
  $self->search_related('post_tags')->delete if $remove_all;

  my $post_processed = $self->post_raw;
  my $reset_tags = 0;
  my @hashtags = ($self->post_raw =~ m/$RE{microsyntax}{hashtag}/og);
  my @groups   = ($self->post_raw =~ m/$RE{microsyntax}{grouptag}/og);
  my @users    = ($self->post_raw =~ m/$RE{microsyntax}{user}/og);
  for my $tag (@hashtags, @groups, @users) {
    my $tag_type = substr($tag, 0, 1);
    my $name = substr($tag, 1);       # omit leading #

    # find_or_create tag
    my $tag = $schema->resultset('Tag')->find_or_create({
      type      => $tag_type,
      tag       => $name,
    })
    or die "Creating tag '$tag' failed: $!";

    # find_or_create post_tag
    $schema->resultset('PostTag')->find_or_create({
      post_id   => $self->id,
      tag_id    => $tag->id,
    })
    or die "Creating post_tag for post " . $self->id . ", tag '$tag' failed\n";

    $reset_tags++ if $config->is_reset_tag($name) || $config->is_default_tag($name);

    # Delete any remove tags from $post_processed
    $post_processed =~ s/\s*$tag\b//g if $config->is_remove_tag($name);
  }

  my $post_html = encode_entities $self->post_raw;
  $post_html =~ s!$RE{URI}{HTTP}{-keep}{-scheme => qr/https?/}!<a class="url" href="$1">$1</a>!g;
  $post_html =~ s!$RE{microsyntax}{hashtag}{-keep}!<a class="tag" href="/tag/$3">$1</a>!og;
  $post_html =~ s!$RE{microsyntax}{grouptag}{-keep}!<a class="gtag" href="/gtag/$3">$1</a>!og;
  $post_html =~ s!$RE{microsyntax}{user}{-keep}!<a class="user" href="/user/$3">$1</a>!og;

  # Set post_processed/post_html
  $self->update({ post_processed => $post_processed, post_html => $post_html });

  # If no reset tags are found, set defaults
  $self->add_default_hashtags($config) if ! $reset_tags;
}

# Override insert to auto-create tags and post_tags on row create
sub insert {
  my $self = shift;
  $self->next::method(@_);
  $self->extract_and_create_hashtags;
  return $self;
}

# Override update to auto-create tags and post_tags when post_raw is updated
sub update {
  my $self = shift;

  my %dirty = $self->get_dirty_columns;
  my %extra = $_[0] && ref $_[0] eq 'HASH' ? %{$_[0]} : ();

  $self->next::method(@_);

  if (exists $dirty{post_raw} || exists $extra{post_raw}) {
    # Remove all existing post_tag records in case some have been removed
    $_->delete foreach $self->post_tags;
    # Extract and create new tags and post_tags
    $self->extract_and_create_hashtags(remove_all => 1);
  }

  return $self;
}

sub ts2tp {
  my $self = shift;
  Time::Piece->strptime($self->timestamp, '%Y-%m-%d %T');
}

1;

