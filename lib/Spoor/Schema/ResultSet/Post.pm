package Spoor::Schema::ResultSet::Post;

use strict;
use parent qw(DBIx::Class::ResultSet);

sub search_for_index {
  my ($self, $config, $log, $user) = @_;

  my @where = (delete_b => 0);

  # If not logged in, omit posts tagged private
  if (! $user) {
    # TODO: figure out how to do this with bind values
    my $private_tags_list = sprintf q('%s'), join(q(', '), $config->private_tags);
    $log->debug("private_tags_list: $private_tags_list") if $log;
    @where = ( -and => [
      delete_b => 0,
      \["not exists (select 1 from post_tag pt join tag t on (t.id = pt.tag_id)" .
        "where pt.post_id = me.id and t.tag in ( $private_tags_list ))"],
    ]);
  }

  $self->search({
    @where,
  }, {
    order_by    => 'timestamp desc',
    rows        => $config->get('display_limit') || 50,
  });
};

sub search_by_tag {
  my ($self, $tag, $type, $config) = @_;

  $self->search({
    'tag.type'  => $type,
    'tag.tag'   => $tag,
    delete_b    => 0,
  }, {
    order_by    => 'timestamp desc',
    join        => { post_tags => 'tag' },
    rows        => $config->get('display_limit') || 50,
  });
}

1;

