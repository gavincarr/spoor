-- Create tag table

create table tag (
  id                integer primary key,
  type              text not null references tag_type(id),
  tag               text not null,
  unique(type, tag)
);

