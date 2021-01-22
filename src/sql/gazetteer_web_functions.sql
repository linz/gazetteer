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

set search_path=gazetteer_web, public;

-- Convert to plain text...

CREATE OR REPLACE FUNCTION gaz_plainText( string TEXT )
RETURNS TEXT
AS
$body$
    SELECT
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
       replace(
            $1,
            'ó','o'),
            'Ó','O'),
            'ø','o'),
            'Ø','O'),
            'ā','a'),
            'ē','e'),
            'ī','i'),
            'ō','o'),
            'ū','u'),
            'Ā','A'),
            'Ē','E'),
            'Ī','I'),
            'Ō','O'),
            'Ū','U'),
            'é','e'),
            'è','e'),
            'ä','a'),
            'ë','e'),
            'ï','i'),
            'ö','o'),
            'ü','u'),
            'Ä','A'),
            'Ë','E'),
            'Ï','I'),
            'Ö','O'),
            'Ü','U'),
            '’',$$'$$);
$body$
LANGUAGE sql IMMUTABLE;

ALTER FUNCTION gaz_plaintext(text) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_plaintext(text) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_plaintext(text) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_plainText2( string TEXT )
RETURNS TEXT
AS
$body$
     SELECT
       regexp_replace(
       regexp_replace(
       regexp_replace(
       lower(gaz_plaintext($1)),
         E'[\\'']','','g'),  -- Characters to delete
         E'[\\)\\(\\,\\.\\&\\;\\/\\-]',' ','g'), -- Alternative separators
         E'^\\s+',''); -- Leading spaces
$body$
LANGUAGE sql IMMUTABLE
SET search_path FROM CURRENT;

ALTER FUNCTION gaz_plaintext2(text) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_plaintext2(text) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_plaintext2(text) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_plaintextwords(string text, keep_trailing boolean)
  RETURNS text[] AS
$BODY$
      SELECT regexp_split_to_array(
        regexp_replace(
           gaz_plaintext2($1),
           CASE WHEN $2 THEN '$' ELSE E'\\s+$' END,''), -- Trailing spaces
         E'\\s+');
$BODY$
  LANGUAGE sql IMMUTABLE STRICT;
ALTER FUNCTION gaz_plaintextwords(text, boolean) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_plaintextwords(text, boolean) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_plaintextwords(text, boolean) TO gazetteer_user;

-- -------------------------------------------------------------------------
-- Determine if a name is within a spatial view

CREATE OR REPLACE FUNCTION gaz_name_in_view( name_id int, view geometry )
RETURNS boolean
AS
$body$
   SELECT
      $2 ~ extents OR
      ($2 && extents AND
         EXISTS (SELECT id FROM gaz_shape WHERE feat_id=gaz_name.feat_id AND ST_Intersects($2,shape)))
   FROM
      gaz_name
   WHERE
      id=$1;
$body$
LANGUAGE sql STABLE STRICT;
ALTER FUNCTION gaz_name_in_view(int, geometry) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_name_in_view(int, geometry) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_name_in_view(int, geometry) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_make_view( emin FLOAT, emax FLOAT, nmin FLOAT, nmax FLOAT, src_srid INTEGER, view_srid INTEGER )
RETURNS geometry
AS
$body$
   WITH f(x) AS
   (
   SELECT unnest(array[0.0,0.5,1.0])
   ),
   pts(p) AS
   (
     SELECT
       ST_Transform(
          ST_SetSrid(
             ST_Point($1*f1.x+$2*(1-f1.x),$3*f2.x+$4*(1-f2.x)),
             $5),
             $6)
      FROM
          f f1,
          f f2
   )
   SELECT
      ST_SetSrid(
         ST_Extent(
            CASE WHEN ST_X(p) < 0 THEN ST_Translate(p,360,0) ELSE p END
            ),
         $6)
   FROM
      pts;
$body$
LANGUAGE sql STABLE STRICT;
ALTER FUNCTION gaz_make_view(float, float, float, float, integer, integer) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_make_view(float, float, float, float, integer, integer) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_make_view(float, float, float, float, integer, integer) TO gazetteer_user;
-- -------------------------------------------------------------------------
-- Helper functions for a few words in search

CREATE OR REPLACE FUNCTION gaz_dropdown_name1( search_word text, prefix text )
RETURNS TABLE (word text)
AS
$body$
SELECT
   distinct ($2 || substring(word from length($1)+1))
FROM
   gaz_word
WHERE
   word like $1 || '%'
ORDER BY
   1;
$body$
LANGUAGE sql STABLE;
ALTER FUNCTION gaz_dropdown_name1(text, text) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_dropdown_name1(text, text) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_dropdown_name1(text, text) TO gazetteer_user;


CREATE OR REPLACE FUNCTION gaz_dropdown_name1s( search_word text, prefix text, view geometry )
RETURNS TABLE (word text)
AS
$body$
SELECT
   distinct ($2 || substring(word from length($1)+1))
FROM
   gaz_word
WHERE
   word like $1 || '%' AND
   gaz_name_in_view(name_id,$3)
ORDER BY
   1;
$body$
LANGUAGE sql STABLE;
ALTER FUNCTION gaz_dropdown_name1s(text, text, geometry) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_dropdown_name1s(text, text, geometry) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_dropdown_name1s(text, text, geometry) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_dropdown_name2s( search_word1 text, search_word2 text, prefix text, view geometry )
RETURNS TABLE (word text)
AS
$body$
WITH fw( name_id, nword ) AS
(
SELECT
   name_id, nword
FROM
   gaz_word
WHERE
   word = $1
)
SELECT
   distinct ($3 || substring(word from length($2)+1))
FROM
   gaz_word g
   JOIN fw ON g.name_id = fw.name_id AND g.nword <> fw.nword
WHERE
   word like $2 || '%'
   AND ($4 IS NULL OR gaz_name_in_view( g.name_id, $4 ))
ORDER BY
   1;
$body$
LANGUAGE sql STABLE;
ALTER FUNCTION gaz_dropdown_name2s(text, text, text, geometry) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_dropdown_name2s(text, text, text, geometry) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_dropdown_name2s(text, text, text, geometry) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_dropdown_name3s( search_word1 text, search_word2 text, search_word3 text, prefix text, view geometry )
RETURNS TABLE (word text)
AS
$body$
WITH fw( name_id, nword1, nword2 ) AS
(
SELECT
   w1.name_id, w1.nword, w2.nword
FROM
   gaz_word w1
   join gaz_word w2 ON w1.name_id=w2.name_id and w1.nword <> w2.nword
WHERE
   w1.word = $1 and
   w2.word = $2
)
SELECT
   distinct ($4 || substring(g.word FROM length($3)+1))
FROM
   gaz_word g
   JOIN fw ON g.name_id = fw.name_id AND g.nword <> fw.nword1 and g.nword <> fw.nword2
WHERE
   word like $3 || '%' AND
   ($5 is null OR gaz_name_in_view(g.name_id,$5))
ORDER BY
   1;
$body$
LANGUAGE sql STABLE;
ALTER FUNCTION gaz_dropdown_name3s(text, text, text, text, geometry) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_dropdown_name3s(text, text, text, text, geometry) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_dropdown_name3s(text, text, text, text, geometry) TO gazetteer_user;

-- --------------------------------------------------------------

CREATE OR REPLACE FUNCTION gaz_dropdown_names( search_string text, view geometry )
RETURNS TABLE (result text)
AS
$body$
DECLARE
  search_words text[];
  nsearch integer;
  iword integer;
  iwordc varchar;
  match_sql text;
  match_where text;
  match_diff text;
  match_from text;
  l_view geometry;
BEGIN
  search_words = gaz_plaintextwords( search_string, TRUE );
  nsearch = array_length( search_words, 1 );
  IF search_string ~ E'\\s$' AND (nsearch > 1 OR search_words[1] != '') THEN
     search_words = array_append( search_words, '' );
  END IF;
  -- User requirements are that the drop down should show all possible names
  -- disregarding spatial filter.  That way the user can easily search for names
  -- outside the extent and get a message saying they need to zoom out.
  --
  -- IF view IS NOT NULL THEN
  --    l_view = ST_Transform( view, 4167 );
  -- END IF;
  IF nsearch = 1 THEN
     IF search_words[1] = '' THEN
        RETURN;
     ELSIF l_view IS NULL THEN
        RETURN QUERY SELECT * FROM gaz_dropdown_name1( search_words[1], search_string );
     ELSE
        RETURN QUERY SELECT * FROM gaz_dropdown_name1s( search_words[1], search_string, l_view );
     END IF;
  ELSEIF nsearch = 2 THEN
     RETURN QUERY SELECT * FROM gaz_dropdown_name2s( search_words[1], search_words[2], search_string, l_view );
  ELSEIF nsearch = 3 THEN
     RETURN QUERY SELECT * FROM gaz_dropdown_name3s( search_words[1], search_words[2], search_words[3], search_string, l_view );
  ELSIF nsearch > 3 THEN

    match_where = 'w0.word like ' || quote_literal(search_words[nsearch] || '%') ;
    match_from = 'gaz_word w0';
    match_diff = 'w%.nword <> w0.nword';
    FOR iword IN 1..nsearch-1 LOOP
       iwordc = iword::varchar;
       match_from = match_from || ' join gaz_word w' || iwordc ||
                                    ' on w' || iwordc || '.name_id = w0.name_id and ' ||
                                    replace(match_diff,'%',iwordc)
                                    ;
       match_diff = match_diff || ' and w%.nword <> w' || iwordc || '.nword';
       match_where = match_where || ' and w' || iwordc || '.word = ' || quote_literal(search_words[iword]);
    END LOOP;
    iwordc = (length(search_words[nsearch])+1)::varchar;
    match_where = match_where || ' and ($1 is null or gaz_name_in_view(w0.name_id,$1))';
    match_sql = 'SELECT distinct(' || quote_literal(search_string) || ' || substring(w0.word from ' || iwordc ||
                ')) from ' || match_from || ' where ' || match_where || ' order by 1';
    -- RAISE NOTICE 'SQL: %', match_sql;
    RETURN QUERY EXECUTE match_sql USING l_view;
  END IF;
END
$body$
LANGUAGE plpgsql STABLE;

ALTER FUNCTION gaz_dropdown_names(text, geometry) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_dropdown_names(text, geometry) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_dropdown_names(text, geometry) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_matching_names( search_string text, view geometry )
RETURNS TABLE (name_id int)
AS
$body$
DECLARE
  search_words text[];
  nsearch integer;
  iword integer;
  iwordc varchar;
  match_sql text;
  match_where text;
  match_diff text;
  match_from text;
  l_view geometry;
BEGIN
  search_words = gaz_plaintextwords( search_string, FALSE );
  nsearch = array_length( search_words, 1 );
  IF view IS NOT NULL THEN
     l_view = ST_Transform( view, 4167 );
  END IF;

    match_where = 'w0.word = ' || quote_literal(search_words[nsearch]) ;
    match_from = 'gaz_word w0';
    match_diff = 'w%.nword <> w0.nword';
    FOR iword IN 1..nsearch-1 LOOP
       iwordc = iword::varchar;
       match_from = match_from || ' join gaz_word w' || iwordc ||
                                    ' on w' || iwordc || '.name_id = w0.name_id and ' ||
                                    replace(match_diff,'%',iwordc)
                                    ;
       match_diff = match_diff || ' and w%.nword <> w' || iwordc || '.nword';
       match_where = match_where || ' and w' || iwordc || '.word = ' || quote_literal(search_words[iword]);
    END LOOP;
    iwordc = (length(search_words[nsearch])+1)::varchar;
    match_where = match_where || ' and ($1 is null or gaz_name_in_view(w0.name_id,$1))';
    match_sql = 'SELECT distinct w0.name_id from ' || match_from || ' where ' || match_where || ' order by 1';
    RAISE NOTICE 'SQL: %', match_sql;
    RETURN QUERY EXECUTE match_sql USING l_view;
END
$body$
LANGUAGE plpgsql STABLE;

ALTER FUNCTION gaz_matching_names(text, geometry) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_matching_names(text, geometry) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_matching_names(text, geometry) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_matching_names_missed( search_string text, view geometry )
RETURNS boolean
AS
$body$
DECLARE
  search_words text[];
  nsearch integer;
  iword integer;
  iwordc varchar;
  match_sql text;
  match_where text;
  match_diff text;
  match_from text;
  l_view geometry;
  l_nameid INT;
BEGIN
  IF view IS NULL THEN
     RETURN FALSE;
  END IF;
  search_words = gaz_plaintextwords( search_string, FALSE );
  nsearch = array_length( search_words, 1 );
  l_view = ST_Transform( view, 4167 );

  match_where = 'w0.word = ' || quote_literal(search_words[nsearch]) ;
  match_from = 'gaz_word w0';
  match_diff = 'w%.nword <> w0.nword';
  FOR iword IN 1..nsearch-1 LOOP
       iwordc = iword::varchar;
       match_from = match_from || ' join gaz_word w' || iwordc ||
                                    ' on w' || iwordc || '.name_id = w0.name_id and ' ||
                                    replace(match_diff,'%',iwordc)
                                    ;
       match_diff = match_diff || ' and w%.nword <> w' || iwordc || '.nword';
       match_where = match_where || ' and w' || iwordc || '.word = ' || quote_literal(search_words[iword]);
  END LOOP;
  iwordc = (length(search_words[nsearch])+1)::varchar;
  match_where = match_where || ' and not gaz_name_in_view(w0.name_id,$1)';
  match_sql = 'SELECT w0.name_id from ' || match_from || ' where ' || match_where || ' limit 1';
  RAISE NOTICE 'SQL: %', match_sql;
  EXECUTE match_sql INTO l_nameid USING l_view;
  RETURN l_nameid IS NOT NULL;
END
$body$
LANGUAGE plpgsql STABLE;

ALTER FUNCTION gaz_matching_names_missed(text, geometry) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_matching_names_missed(text, geometry) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_matching_names_missed(text, geometry) TO gazetteer_user;

CREATE OR REPLACE FUNCTION gaz_transform_null(p_geom geometry, p_srid integer)
   RETURNS geometry AS
$body$
BEGIN
   RETURN st_transform(p_geom, p_srid);
EXCEPTION WHEN internal_error THEN
   RETURN NULL;
END;
$body$
   LANGUAGE 'plpgsql' IMMUTABLE STRICT
   COST 100;

ALTER FUNCTION gaz_transform_null(geometry, integer) OWNER TO gaz_owner;
GRANT EXECUTE ON FUNCTION gaz_transform_null(geometry, integer) TO gaz_web_reader;
GRANT EXECUTE ON FUNCTION gaz_transform_null(geometry, integer) TO gazetteer_user;
