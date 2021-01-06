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

SET search_path=gazetteer, public;
SET search_path=gazetteer, public;

CREATE OR REPLACE FUNCTION gaz_searchName(
    p_name_query VARCHAR,
    p_feat_type VARCHAR,
    p_name_status VARCHAR,
    p_limit INT
    )
RETURNS TABLE (
    name_id INT,
    feat_id INT,
    name VARCHAR,
    name_status CHAR(4),
    feat_type CHAR(4),
    rank REAL
    )

AS
$body$
WITH q(query) AS (SELECT to_tsquery('gazetteer.gaz_tsc',$1))
SELECT
   name.name_id,
   feature.feat_id,
   name.name,
   name.status,
   feature.feat_type,
   1.0
FROM
   name
   JOIN feature ON name.feat_id = feature.feat_id
WHERE
   name.name_id=(
       CASE
       WHEN trim($1) ~ E'^\\d{1,7}$' THEN trim($1)::INT
       WHEN trim($1) ~ E'^id=\\d{1,7}$' THEN substring(trim($1) from 4)::INT
       ELSE NULL END)
UNION
SELECT
   name.name_id,
   feature.feat_id,
   name.name,
   name.status,
   feature.feat_type,
   1.0
FROM
   name
   JOIN feature ON name.feat_id = feature.feat_id
WHERE
   name.feat_id=(CASE WHEN trim($1) ~ E'^fid=\\d{1,7}$' THEN substring(trim($1) from 5)::INT ELSE NULL END)
UNION
SELECT
   name.name_id,
   feature.feat_id,
   name.name,
   name.status,
   feature.feat_type,
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

$body$
LANGUAGE sql STABLE
SET search_path FROM CURRENT;


CREATE OR REPLACE FUNCTION gaz_searchName2(
    p_name_query VARCHAR,
    p_feat_type VARCHAR,
    p_name_status VARCHAR,
    p_extents VARCHAR,
    p_not_published BOOLEAN,
    p_limit INT
    )
RETURNS TABLE (
    name_id INT,
    feat_id INT,
    name VARCHAR,
    name_status CHAR(4),
    feat_type CHAR(4),
    rank REAL
    )

AS
$body$
DECLARE
    v_sql TEXT;
    v_where TEXT;
    v_rank TEXT;
    v_src TEXT;
BEGIN
    v_src = 'name JOIN feature on name.feat_id = feature.feat_id';
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
               name.status,
               feature.feat_type,
               $sql$ || v_rank || ' AS rank  FROM ' || v_src;

    v_sql = v_sql || ' WHERE ' || v_where ||
        ' ORDER BY lower(gaz_plainText(name.name))' ||
        ' LIMIT ' || COALESCE(p_limit,1000000)::VARCHAR;

    RAISE NOTICE 'SQL: %', v_sql;
    RETURN QUERY EXECUTE v_sql;
END
$body$
LANGUAGE plpgsql STABLE
SET search_path FROM CURRENT;

GRANT EXECUTE ON FUNCTION gaz_searchName( varchar, varchar, varchar, int ) TO gazetteer_user;
GRANT EXECUTE ON FUNCTION gaz_searchName2( varchar, varchar, varchar, varchar, boolean, int ) TO gazetteer_user;
