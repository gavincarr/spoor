
Introduction
------------

Spoor is a micro-blogging micro-service for personal use. It provides a
simple twitter-like post api, and a lightweight web interface, including
atom feeds. You'd typically run it on some server you control - no root
access is required; all posts go into a sqlite database.

Spoor is intended as a personal micro-blogging hub - you post most/all
of your stuff to it, some of which is intended only for particular
audiences, and some of which may be private. Spoor then forwards posts
out to (multiple) endpoints, depending on how posts are hash-tagged.

For instance, my standard configuration is to forward all my posts to
identi.ca and twitter by default, and to forward urls to my bookmarking
services (delicious and pinboard) if I add a #bm hashtag. Posts
tagged #pri are private and don't get forwarded anywhere. There are also
#i and #t tags if I want to limit a post to identi.ca or twitter,
respectively.


Status
------

Services currently forwarded:

- identi.ca/status.net
- twitter
- delicious
- pinboard

TODO:

- facebook
- google+ (once they have an api)
- diaspora?
- others?


Acknowledgements
----------------

Icons are from the excellent FamFamFam Silk Icons collection:
see http://www.famfamfam.com/lab/icons/silk/.


Author
------

Gavin Carr <gavin@openfusion.com.au>

Copyright 2011 Gavin Carr.


Licence
-------

Spoor is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

