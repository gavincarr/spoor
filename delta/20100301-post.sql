-- Create post table

create table post (
  id                integer primary key,
  post_raw          text not null,
  post_processed    text,
  post_html         text,
  timestamp         integer default CURRENT_TIMESTAMP,
  pause_b           tinyint default 0,
  delete_b          tinyint default 0
);

