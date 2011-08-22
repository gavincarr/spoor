-- Create post_tag table

create table post_tag (
  post_id           integer references post(id),
  tag_id            integer references tag(id)
);

