-- Change post_tag fields to not null
-- sqlite doesn't have alter table modify support, so we need to create a new table

alter table post_tag rename to post_tag_old;

create table post_tag (
  post_id integer not null references post(id),
  tag_id  integer not null references tag(id),
  primary key (post_id, tag_id)
);

insert into post_tag select * from post_tag_old where post_id is not null and tag_id is not null;

