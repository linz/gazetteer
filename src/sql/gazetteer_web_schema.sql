-- ################################################################################
--
--  New Zealand Geographic Board gazetteer application,
--  Crown copyright (c) 2020, Land Information New Zealand on behalf of
--  the New Zealand Government.
--
--  This file is released under the MIT licence. See the LICENCE file found
--  in the top-level directory of this distribution for more information.
--
-- ################################################################################

-- drop schema gazetteer_web cascade;
set client_min_messages=WARNING;
set client_min_messages=WARNING;

set role postgres;

create schema gazetteer_web;

ALTER USER gaz_web SET search_path=gazetteer_web, public;
ALTER USER gaz_web_dev SET search_path=gazetteer_web, public;


set search_path to gazetteer_web, public;


create table gaz_feature
(
    id integer not null primary key,
    type char(4) not null,
    status char(4) not null,
    description text
);

comment on table gaz_feature is 
$comment$
Table of features that have names.  

id          is the unique identifier for features, referenced as feat_id 
            in the gaz_name, gaz_shape, and gaz_annotation.
type        references code in gaz_code where code_group='FTYP'
status      references code in gaz_code where code_group='FSTS'
description is a description of the geographical feature
$comment$;


create table gaz_name
(
    id integer not null primary key,
    feat_id integer not null,
    name varchar(100) not null,
    ascii_name varchar(100) not null,
    status char(4) not null,
    extents geometry
);

create index gaz_name_feat_id on gaz_name( feat_id );
create index gaz_name_ascii on gaz_name( ascii_name );

comment on table gaz_name is
$comment$
List of names that may be associated with features.

id             is a unique identifier for the name
feat_id        is the feature that the name references
ascii_name     is the ascii version of the name, used for 
               searching/sorting 
name           is the UTF-8 name including diacritical marks
status         references code in gaz_code where code_group='NSTS'
$comment$;

create table gaz_word 
(
    name_id int not null,
    nword int not null,
    word varchar(100) not null,
    primary key (name_id, nword)
);

create index gaz_word_word on gaz_word( word );

comment on table gaz_name is
$comment$
Index of ASCII words used in the names in gaz_name, to assist
searching.

name_id       is the id of the name
nword         is the number of the word in the name (1,2,..)
word          is the word
$comment$;


create table gaz_shape
(
    id serial not null primary key,
    feat_id integer not null,
    min_zoom int not null,
    max_zoom int,
    shape geometry
);

create index gaz_shape_feat_id on gaz_shape( feat_id );
create index gaz_shape_extents on gaz_shape using GIST ( shape );

comment on table gaz_shape is
$comment$
Spatial representation of features.  

Each feature may have multiple spatial
components at multiple resolutions (zoom levels).  Shapes are held in 
geographical (lat/lon) coordinates in the official coordinate system of the 
area in which they apply (eg NZGD2000, RSRGD2000).  The representation of 
feature with id f at a specific zoom level z is obtained by the query
   select shape from gaz_shape where feat_id=f and min_zoom<=z and max_zoom>=z
Zoom levels are based on the google maps levels, where (approximately) 
at zoom level 0 360 degrees is represented in 256 pixels, and the precision
increases by a factor of 2 for each zoom level.
Not all features are represented at lower zoom levels.

id          is a unique identifier for the shape
feat_id     is the feature referenced
min_zoom    is the minimum zoom level at which to use the representation
max_zoom    is the maximum zoom level at which to use the representation
shape       is the geometry object

Note: May want to change the default coordinate system to one more 
suitable for web mapping application.  Also may need reworking to handle
multiple geometry types better.
$comment$;


create table gaz_annotation
(
    id serial not null primary key,
    ref_type char(4) not null,
    ref_id integer not null,
    sequence integer not null,
    list_view char(1) not null,
    details_view char(1) not null,
    selected_detail_view char(1) not null,
    is_html char(1) not null,
    note_type char(4) not null,
    note text
);

comment on table gaz_annotation is
$comment$
Annotation information for the features

id           is a unique identifier for the annotation
ref_type     is the type of object referenced, either 'FEAT' if it is
             information about the feature, or 'NAME' if it is information
             about the name.
ref_id       is the id of the feature or name to which the annotation
             applies
sequence     is used to order the annotations for a specific feature or
             name
list_view    'Y' if the annotation should display in the search results
details_view 'Y' if the annotation should display in the name details view for other names
selected_detail_view 'Y' if the annotation should display in the name details view for the selected name
is_html      'Y' if the annotation is an html fragment.  If not then
              the text should be HTML escaped for displaying
note_type     references code in gaz_code where code_group='ANTP'.  Used
              to find a label for the annotation
note          is the text of the annotation
$comment$;

create index gaz_annotation_ref on gaz_annotation( ref_type, ref_id );


create table gaz_code
(
    code_group char(4) not null,
    code char(4) not null,
    category char(4),
    value varchar(255),
    primary key (code_group, code)
);

comment on table gaz_code is
$comment$
System codes used in the tables;
This defines code lists for each group code_group.  The code_group
'CODE' defines the code groups (!)

code_group  identifies a set of codes
code        is the code 
value       is the value the code represents
$comment$;

create table gaz_web_config
(
    code char(4) not null primary key,
    intval int,
    value text,
    description text
);

grant usage on schema gazetteer_web to gaz_web_reader;
grant all on schema gazetteer_web to gaz_web_developer;

comment on table gaz_web_config is
$comment$
Web application configuration information
code        identifies what the values represent
intval      is an integer value for the configuration item
value       is a text value for the configuration
description is a description of the item (not used by application)
$comment$;

create table gaz_event
(
  event_id integer not null primary key,
  name_id integer,
  event_date date,
  event_type character(4),
  event_reference text
);

CREATE TABLE gaz_all_shapes
(
  feat_id integer NOT NULL,
  geom_type character(1) NOT NULL,
  shape geometry
);

grant select on  gaz_feature to gaz_web_reader;
grant select on  gaz_name to gaz_web_reader;
grant select on  gaz_word to gaz_web_reader;
grant select on  gaz_shape to gaz_web_reader;
grant select on  gaz_annotation to gaz_web_reader;
grant select on  gaz_code to gaz_web_reader;
grant select on  gaz_web_config to gaz_web_reader;
grant select on  gaz_event to gaz_web_reader;
grant select on  gaz_all_shapes to gaz_web_reader;

grant all on  gaz_feature to gaz_web_admin;
grant all on  gaz_name to gaz_web_admin;
grant all on  gaz_word to gaz_web_admin;
grant all on  gaz_shape to gaz_web_admin;
grant all on  gaz_annotation to gaz_web_admin;
grant all on  gaz_code to gaz_web_admin;
grant all on  gaz_event to gaz_web_admin;
grant all on  gaz_all_shapes to gaz_web_admin;

grant all on  gaz_web_config to gaz_web_developer;
