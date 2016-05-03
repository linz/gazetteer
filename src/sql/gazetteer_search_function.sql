-- ###############################################################################
-- 
--  Copyright 2015 Crown copyright (c)
--  Land Information New Zealand and the New Zealand Government.
--  All rights reserved
-- 
--  This program is released under the terms of the new BSD license. See the 
--  LICENSE file for more information.
-- 
-- ###############################################################################

SET search_path=gazetteer, public;
SET search_path=gazetteer, public;

CREATE OR REPLACE FUNCTION gazetteer.gaz_searchname(
	IN p_name_query character varying, 
	IN p_feat_type character varying, 
	IN p_name_status character varying, 
	IN p_limit integer
	)
  RETURNS TABLE(name_id integer, feat_id integer, name character varying, ta character varying, name_status character, feat_type character, rank real) AS
$BODY$
WITH 
q(query) AS (SELECT to_tsquery('gazetteer.gaz_tsc',$1)),
n as
(
SELECT 
   name.name_id,
   1.0 as rank
FROM
   name 
WHERE
   name.name_id=(
       CASE 
       WHEN trim($1) ~ E'^\\d{1,7}$' THEN trim($1)::INT 
       WHEN trim($1) ~ E'^id=\\d{1,7}$' THEN substring(trim($1) from 4)::INT 
       ELSE NULL END)
UNION
SELECT 
   name.name_id,
   1.0 as rank
FROM
   name 
WHERE
   name.feat_id=(CASE WHEN trim($1) ~ E'^fid=\\d{1,7}$' THEN substring(trim($1) from 5)::INT ELSE NULL END)
UNION
SELECT 
   name.name_id,
   ts_rank(to_tsvector('gazetteer.gaz_tsc',gaz_plainText2(name)),q.query) as rank
FROM
   name 
   JOIN feature ON name.feat_id = feature.feat_id,
   q
WHERE
   to_tsvector('gazetteer.gaz_tsc',gaz_plainText2(name)) @@ q.query AND
   ($2 IS NULL OR feature.feat_type=$2) AND
   (($3 IS NULL AND name.status <> 'UDEL') OR name.status=$3)
LIMIT
   COALESCE($4,1000000) 
)
  SELECT
     n.name_id,
     feature.feat_id,
     name.name,
     CASE WHEN ta.ta_name IS NOT NULL THEN ta.ta_name
	ELSE 'Area Outside Territorial Authority'
     END,
     name.status,
     feature.feat_type,
     n.rank
from 
   n
   join name on n.name_id = name.name_id
   join feature on feature.feat_id=name.feat_id
   LEFT JOIN territorial_authority_low_res ta ON ST_Intersects(feature.ref_point, ta.shape)

$BODY$

LANGUAGE sql STABLE
SET search_path FROM CURRENT;
    

CREATE OR REPLACE FUNCTION gazetteer.gaz_searchname2(
	IN p_name_query character varying, 
	IN p_feat_type character varying, 
	IN p_name_status character varying, 
	IN p_extents character varying, 
	IN p_not_published boolean, 
	IN p_limit integer
	)
  RETURNS TABLE(name_id integer, feat_id integer, name character varying, ta character varying, name_status character, feat_type character, rank real) AS
$BODY$
DECLARE
    v_sql TEXT;
    v_where TEXT;
    v_rank TEXT;
    v_src TEXT;
BEGIN
    v_src = 'name JOIN feature on name.feat_id = feature.feat_id LEFT JOIN territorial_authority_low_res TA ON ST_Intersects(feature.ref_point, TA.shape)';
    v_sql = '';
    v_where = '';
    v_rank = '1.0::REAL';

    IF COALESCE(p_name_query,'') ~ E'\\S' THEN 
        IF trim(p_name_query) ~ E'^\\d{1,7}$' THEN
            v_where = v_where || 'name.name_id = '|| p_name_query || ' AND ';
        ELSIF trim(p_name_query) ~ E'^id=\\d{1,7}$' THEN
            v_where = v_where || 'name.name_id = '|| substring(trim(p_name_query) from 4) || ' AND ';
        ELSIF trim(p_name_query) ~ E'^fid=\\d{1,7}$' THEN
            v_where = v_where || 'name.feat_id = '|| substring(trim(p_name_query) from 5) || ' AND ';
        ELSE
            v_sql = v_sql || 'q(query) AS (SELECT to_tsquery(''gazetteer.gaz_tsc'',' || quote_literal(p_name_query) || ')), ';
            v_src = v_src || ', q';
            v_where = v_where || 'to_tsvector(''gazetteer.gaz_tsc'',gaz_plainText2(name)) @@ q.query AND ';
            v_rank = 'ts_rank(to_tsvector(''gazetteer.gaz_tsc'',gaz_plainText2(name)),q.query)';
        END IF;
    END IF;
 
    IF p_not_published THEN
        v_sql = v_sql || $with$
           wnpub(name_id) as
           (
           SELECT 
              name_id 
           FROM 
              name_annotation 
           WHERE
              annotation_type='NPUB'
           UNION
           SELECT 
              n.name_id
           FROM 
              name n
              JOIN feature_annotation fa ON fa.feat_id=n.feat_id
           WHERE
              fa.annotation_type='NPUB'
           ),
        $with$;
        v_src = v_src || ', wnpub';
        v_where = v_where || 'wnpub.name_id = name.name_id AND ';
    END IF;

    IF COALESCE(p_feat_type,'') ~ E'\\S' THEN
        IF p_feat_type ~ E'\\s' THEN
            v_where = v_where || 'feature.feat_type IN (' || 
                (SELECT array_to_string(array_agg(quote_literal(word)),', ')
                FROM regexp_split_to_table(p_feat_type,E'\\s+') AS word
                WHERE word != '')
                || ') AND ';
        ELSE
            v_where = v_where || 'feature.feat_type = ' || quote_literal(p_feat_type) || ' AND ';
        END IF;
    END IF;

    IF COALESCE(p_name_status,'') ~ E'\\S' THEN
        IF p_name_status ~ E'\\s' THEN
            v_where = v_where || 'name.status IN (' || 
                (SELECT array_to_string(array_agg(quote_literal(word)),', ')
                FROM regexp_split_to_table(p_name_status,E'\\s+') AS word
                WHERE word != '')
                || ') AND ';
        ELSE
            v_where = v_where || 'name.status = ' || quote_literal(p_name_status) || ' AND ';
        END IF;
    ELSE
        v_where = v_where || 'name.status <> ''UDEL'' AND ';
    END IF;

    IF COALESCE(p_extents,'') ~ E'\\S' THEN
        v_sql = v_sql || 'g(geom) AS (SELECT ST_GeomFromText(' ||
                   quote_literal(p_extents) ||
                   ',4167)), ';
        v_src = v_src || ', g';
        v_where = v_where || $where$
            (ST_Intersects(feature.ref_point,g.geom) OR EXISTS (
                SELECT * FROM feature_geometry fg, g WHERE
                fg.feat_id = feature.feat_id AND
                ST_Intersects(fg.shape,g.geom)
            ))
            $where$;
    END IF;


    IF v_sql ~ E'\\S' THEN
        v_sql = 'WITH ' || regexp_replace(v_sql,E'\\,\\s+$',' ');
    END IF;
    
    v_where = regexp_replace( v_where, E'\\s*AND\\s+$','');
    IF v_where = '' THEN
        v_where = 'FALSE';
    END IF;

    v_sql = v_sql || $sql$
            SELECT
               name.name_id,
               feature.feat_id,
               name.name,
               TA.ta_name,
               name.status,
               feature.feat_type,
               $sql$ || v_rank || ' AS rank  FROM ' || v_src;
   
    v_sql = v_sql || ' WHERE ' || v_where ||
        ' ORDER BY lower(gaz_plainText(name.name))' ||
        ' LIMIT ' || COALESCE(p_limit,1000000)::VARCHAR;

    RAISE NOTICE 'SQL: %', v_sql;
    RETURN QUERY EXECUTE v_sql;
END
$BODY$
LANGUAGE plpgsql STABLE
SET search_path FROM CURRENT;
    
GRANT EXECUTE ON FUNCTION gaz_searchName( varchar, varchar, varchar, int ) TO gazetteer_user; 
GRANT EXECUTE ON FUNCTION gaz_searchName2( varchar, varchar, varchar, varchar, boolean, int ) TO gazetteer_user; 
