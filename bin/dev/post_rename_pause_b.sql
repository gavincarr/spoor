-- Rename post.pause_b to post.forward_flag, inverting meaning
-- Unfortunately, sqlite doesn't support alter table rename column :-/

create table post_new (
  id                integer primary key,
  post_raw          text not null,
  post_processed    text,
  post_html         text,
  timestamp         integer default CURRENT_TIMESTAMP,
  forward_flag      tinyint default 1,
  delete_b          tinyint default 0
);

-- Note this UNPAUSES any paused posts you've got
insert into post_new
select id, post_raw, post_processed, post_html, timestamp, 1, delete_b from post;

-- Rename
alter table post rename to post_old;
alter table post_new rename to post;

