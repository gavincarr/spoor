-- Create tag_type lookup table

create table tag_type (
  id                text primary key,
  description       text not null
);

insert into tag_type values ('#', 'Hashtag');
insert into tag_type values ('!', 'Group');
insert into tag_type values ('@', 'User');

